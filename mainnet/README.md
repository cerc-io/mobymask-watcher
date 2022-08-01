# Mainnet Deployment

## Setup

* Update `CHAINDATA_DIR` variable in [.env](./.env) file to point to Geth LevelDB directory.

## Run

* Start `ipld-eth-db` and `watcher-db` services:

  ```bash
  docker-compose up -d --build ipld-eth-db watcher-db
  ```

* Check that services `ipld-eth-db` and `watcher-db` are up and healthy:

  ```bash
  docker-compose ps
  ```

* Uncompress data dumps:

  ```bash
  tar -xzvf ../common/ipld-eth-db/mainnet-indexer-db.tar.gz -C ../common/ipld-eth-db/

  tar -xzvf ../common/watcher-ts/mobymask-watcher-db.tar.gz -C ../common/watcher-ts/
  ```

* Import statediff data for old blocks in `indexer` database:

  ```bash
  docker-compose exec ipld-eth-db psql -U vdbm indexer -c "SELECT timescaledb_pre_restore();"

  docker-compose exec -T ipld-eth-db psql -U vdbm indexer < ../common/ipld-eth-db/mainnet-indexer-db.sql

  docker-compose exec ipld-eth-db psql -U vdbm indexer -c "SELECT timescaledb_post_restore();"
  ```

* Import indexed data for old blocks in `mobymask-watcher` database:

  ```bash
  docker-compose exec -T watcher-db psql -U vdbm mobymask-watcher < ../common/watcher-ts/mobymask-watcher-db.sql
  ```

* Intialize and start core services:

  ```bash
  docker-compose up -d --build
  ```

* Optionally, to follow the container logs:

  ```bash
  docker-compose logs -f
  ```

* Check if new block at chain head has been indexed by Geth. Run the following query in `ipld-eth-server` GraphQL [endpoint](http://127.0.0.1:8083/graphiql) to get the latest block:

  ```graphql
  query {
    block {
      hash
      number
    }
  }
  ```

  Confirm that a new block is returned i.e. it should be different from the previously indexed block for MobyMask contract:

  ```graphql
  # Should not be equal to this result (block number 15234194)
  {
    "data": {
      "block": {
        "hash": "0x1f1f9ddf5435def50e966563a68afc302b1d43b1ead0c15a3b3397a17c452eb9",
        "number": "0xe87492"
      }
    }
  }
  ```

  **NOTE**: The new block returned is the block from which Geth has started indexing. Running the GQL queries below with blocks before the returned block number will not return results in the watcher.

* Run the watcher:

  ```bash
  docker-compose --profile watcher up -d --build
  ```

* The `isMember` map should be indexed with old mainnet blocks. Check the mobymask-watcher database table `is_member`:

  ```bash
  docker-compose exec watcher-db psql -U vdbm mobymask-watcher -c "SELECT block_hash, block_number, contract_address, key0, value FROM is_member"
  ```

  **NOTE**: The GQL query below will also work with the block hashes returned above.

* Run the following GQL query in [GraphQL endpoint](http://127.0.0.1:3001/graphql) with the existing member names:

  ```graphql
  query {
    isMember(
      blockHash: "LATEST_BLOCK_HASH"
      contractAddress: "0xB06E6DB9288324738f04fCAAc910f5A60102C1F8"
      key0: "MEMBER_NAME"
    ) {
      value
      proof {
        data
      }
    }
  }
  ```

  This query lazily fetches the contract data from `ipld-eth-server`.

* Run the following GQL subscription in [GraphQL endpoint](http://127.0.0.1:3001/graphql) to watch for events:

  ```graphql
  subscription {
    onEvent {
      event {
        __typename
        ... on PhisherStatusUpdatedEvent {
          entity
          isPhisher
        },
        ... on MemberStatusUpdatedEvent {
          entity
          isMember
        }
      },
      block {
        number
        hash
      }
    }
  }
  ```

## Reset

* Reset databases:

  ```bash
  docker-compose down -v
  ```
