# mobymask-watcher

## Setup

* Update `CHAINDATA_DIR` variable in [.env](./.env) file to point to Geth LevelDB directory.

* Set the MobyMask contract address to `MOBY_ADDRESS` variable and the block number at which it was deployed to `DEPLOY_BLOCK_NUMBER` variable in [.env](./.env) file:

  ```
  MOBY_ADDRESS=0xB06E6DB9288324738f04fCAAc910f5A60102C1F8
  DEPLOY_BLOCK_NUMBER=14869713
  ```

## Run

* Start watcher-db service:

  ```bash
  docker-compose up -d --build watcher-db
  ```

* Dump indexed data for old mainnet blocks in mobymask-watcher database:

  ```bash
  psql -U vdbm -h 127.0.0.1 -p 15432 mobymask-watcher < watcher-ts/mobymask-watcher-db.sql
  ```

  *NOTE: For the password prompt above use `password`*

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

## Demos

* [Mainnet demo](./demo/mainnet.md)
* [Local demo](./demo/local.md)
