# mobymask-watcher

## Setup

* Update `CHAINDATA_DIR` variable in [.env](./.env) file to point to Geth LevelDB directory.

* Set the MobyMask contract address to `MOBY_ADDRESS` variable and the block number at which it was deployed to `DEPLOY_BLOCK_NUMBER` variable in [.env](./.env) file:

  ```
  MOBY_ADDRESS=0xB06E6DB9288324738f04fCAAc910f5A60102C1F8
  DEPLOY_BLOCK_NUMBER=14869713
  ```

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
  tar -xzvf ipld-eth-db/mainnet-indexer-db.tar.gz -C ipld-eth-db/

  tar -xzvf watcher-ts/mobymask-watcher-db.tar.gz -C watcher-ts/
  ```

* Import statediff data for old blocks in `indexer` database:

  ```bash
  docker-compose exec ipld-eth-db psql -U vdbm indexer -c "SELECT timescaledb_pre_restore();"

  docker-compose exec -T ipld-eth-db psql -U vdbm indexer < ipld-eth-db/mainnet-indexer-db.sql

  docker-compose exec ipld-eth-db psql -U vdbm indexer -c "SELECT timescaledb_post_restore();"
  ```

* Import indexed data for old blocks in `mobymask-watcher` database:

  ```bash
  docker-compose exec -T watcher-db psql -U vdbm mobymask-watcher < watcher-ts/mobymask-watcher-db.sql
  ```

* The `isMember` and `isPhisher` maps should be indexed with old mainnet blocks. Check the mobymask-watcher database tables `is_member` and `is_phisher`:

  ```bash
  docker-compose exec watcher-db psql -U vdbm mobymask-watcher -c "SELECT block_hash, block_number, contract_address, key0, value FROM is_member"
  ```

  ```bash
  docker-compose exec watcher-db psql -U vdbm mobymask-watcher -c "SELECT block_hash, block_number, contract_address, key0, value FROM is_phisher"
  ```

* Intialize and start all services:

  ```bash
  docker-compose up -d --build
  ```

* Optionally, to follow the container logs:

  ```bash
  docker-compose logs -f
  ```

* Run the following GQL mutation [GraphQL endpoint](http://127.0.0.1:3001/graphql) to start watching the contract in mobymask-watcher:

  ```graphql
  mutation {
    watchContract(
      address: "0xB06E6DB9288324738f04fCAAc910f5A60102C1F8"
      kind: "PhisherRegistry"
      checkpoint: true
    )
  }
  ```

* Get latest blockHash in [GraphQL endpoint](http://127.0.0.1:3001/graphql):

  ```graphql
  query {
    latestBlock {
      hash
      number
    }
  }
  ```

* Run the following GQL query in [GraphQL endpoint](http://127.0.0.1:3001/graphql) with the existing phisher or member names:

  ```graphql
  query {
    isPhisher(
      blockHash: "LATEST_BLOCK_HASH"
      contractAddress: "0xB06E6DB9288324738f04fCAAc910f5A60102C1F8"
      key0: "PHISHER_NAME"
    ) {
      value
      proof {
        data
      }
    }
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
