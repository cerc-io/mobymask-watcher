# mobymask-watcher

## Setup

* Update the `upstream.ethServer` endpoints in [mobymask-watcher config file](./watcher-ts/mobymask-watcher.toml) to point to ipld-eth-server.

  ```toml
  [upstream]
    [upstream.ethServer]
      gqlApiEndpoint = "http://host.docker.internal:8083/graphql"
      rpcProviderEndpoint = "http://host.docker.internal:8082"
  ```

## Run

* Start `watcher-db` service:

  ```bash
  docker-compose up -d --build watcher-db
  ```

* Uncompress `watcher-db` data dump:

  ```bash
  tar -xzvf watcher-ts/mobymask-watcher-db.tar.gz -C watcher-ts/
  ```

* Check that `watcher-db` is up and healthy:

  ```bash
  docker-compose ps
  ```

* Import indexed data for old blocks in `mobymask-watcher` database:

  ```bash
  docker-compose exec -T watcher-db psql -U vdbm mobymask-watcher < watcher-ts/mobymask-watcher-db.sql
  ```

* Intialize and start all services:

  ```bash
  docker-compose up -d --build
  ```

* Optionally, to follow the container logs:

  ```bash
  docker-compose logs -f
  ```

* The `isMember` map should be indexed with old mainnet blocks. Check the mobymask-watcher database table `is_member`:

  ```bash
  docker-compose exec watcher-db psql -U vdbm mobymask-watcher -c "SELECT block_hash, block_number, contract_address, key0, value FROM is_member"
  ```

* Get the latest block using the following query in [GraphQL endpoint](http://127.0.0.1:3001/graphql):

  ```graphql
  query {
    latestBlock {
      hash
      number
    }
  }
  ```

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
