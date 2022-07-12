# mobymask-watcher

## Setup

* Update `CHAINDATA_DIR` variable in [.env](./.env) file to point to Geth LevelDB directory.

* Set the MobyMask contract address to `MOBY_ADDRESS` variable and the block number at which it was deployed to `DEPLOY_BLOCK_NUMBER` variable in [.env](./.env) file:

  ```
  MOBY_ADDRESS=0xB06E6DB9288324738f04fCAAc910f5A60102C1F8
  DEPLOY_BLOCK_NUMBER=14869713
  ```

## Run

* Intialize servers:

  ```bash
  docker-compose up -d --build
  ```

* Optionally, to follow the container logs:

  ```bash
  docker-compose logs -f
  ```

* Check that `eth-statediff-fill-service` has indexed [all blocks for MobyMask contract](https://etherscan.io/address/0xb06e6db9288324738f04fcaac910f5a60102c1f8). Query for the last MobyMask contract block using ipld-eth-server:

  ```graphql
  {
    block(number: 14885755) {
      hash
    }
  }
  ```

  If the block is not indexed, instead of getting blockHash value, error message will be returned:

  ```
  "message": "sql: no rows in result set",
  ```

* Index the blocks in mobymask-watcher.

  * Watch the contract:

    ```bash
    docker-compose exec mobymask-watcher yarn watch:contract --address 0xB06E6DB9288324738f04fCAAc910f5A60102C1F8 --kind PhisherRegistry --checkpoint true --starting-block 14869713
    ```
  
  * Index the [mainnet blocks for MobyMask contract](https://etherscan.io/address/0xb06e6db9288324738f04fcaac910f5a60102c1f8):

    ```
    docker-compose exec mobymask-watcher yarn index-block --block <BLOCK_NUMBER>
    ```

* The `isMember` and `isPhisher` maps should be indexed. Check the mobymask-watcher database tables `is_phisher` and `is_member`:

  ```bash
  docker-compose exec watcher-db psql -U vdbm mobymask-watcher -c "SELECT block_hash, block_number, contract_address, key0, value FROM is_phisher"
  ```

  ```bash
  docker-compose exec watcher-db psql -U vdbm mobymask-watcher -c "SELECT block_hash, block_number, contract_address, key0, value FROM is_member"
  ```

* Start the mobymask-watcher job-runner and server in active mode:

  ```bash
  docker-compose --profile active-watcher up -d --build
  ```

  The watcher will start indexing blocks at head.

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
