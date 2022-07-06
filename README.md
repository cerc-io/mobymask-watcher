# mobymask-watcher

## Setup

* [Create a GitHub PAT (personal access token)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token#creating-a-token) with `repo` scope.

* Update the `GIT_TOKEN` variable in [.env](./.env) file with the GitHub PAT. This is used to access the private `graph-watcher-ts` repo.

* Update `CHAINDATA_DIR` variable in [.env](./.env) file to point to Geth LevelDB directory.

* Set the MobyMask contract address to `MOBY_ADDRESS` variable and the block number at which it was deployed to `DEPLOY_BLOCK_NUMBER` variable in [.env](./.env) file.

## Run

* Intialize servers:

  ```bash
  docker-compose up -d
  ```

* Optionally, to follow the container logs:

  ```bash
  docker-compose logs -f
  ```

* Run the following GQL query in [GraphQL endpoint](http://127.0.0.1:3001/graphql) with the existing phisher or member names:

  ```graphql
  query {
    isPhisher(
      blockHash: "LATEST_BLOCK_HASH"
      contractAddress: "MOBY_ADDRESS"
      key0: "PHISHER_NAME"
    ) {
      value
      proof {
        data
      }
    }
    isMember(
      blockHash: "LATEST_BLOCK_HASH"
      contractAddress: "MOBY_ADDRESS"
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

* Run the following GQL mutation in [GraphQL endpoint](http://127.0.0.1:3001/graphql) to start watching the contract in moby-mask-watcher:

  ```graphql
  mutation {
    watchContract(
      address: "MOBY_ADDRESS"
      kind: "PhisherRegistry"
      checkpoint: true
    )
  }
  ```

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
