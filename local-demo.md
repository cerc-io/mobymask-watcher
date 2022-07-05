# Demo

* Follow the instructions in [Setup](./README.md#setup) to start the watcher along with the core services.

* Clone the [MobyMask](https://github.com/vulcanize/MobyMask) repo.

* Checkout to the branch with changes for using this watcher:

  ```bash
  # In MobyMask repo.
  git checkout use-laconic-watcher-as-hosted-index
  ```

* Run yarn to install the packages

  ```bash
  yarn
  ```

* Deploy the contract:

  ```bash
  cd packages/hardhat

  yarn deploy
  # deploying "PhisherRegistry" (tx: 0xaebeb2e883ece1f679304ec46f5dc61ca74f9e168427268a7dfa8802195b8de0)...: deployed at <MOBY_ADDRESS> with 2306221 gas
  # $ hardhat run scripts/publish.js
  # ✅  Published contracts to the subgraph package.
  # Done in 14.28s.
  ```
  
  Export the address of the deployed contract to a shell variable for later use:

  ```bash
  export MOBY_ADDRESS="<MOBY_ADDRESS>"
  ```

* Run the following GQL mutation in watcher GraphQL endpoint http://127.0.0.1:3001/graphql

  ```graphql
  mutation {
    watchContract(
      address: "MOBY_ADDRESS"
      kind: "PhisherRegistry"
      checkpoint: true
    )
  }
  ```

* Get the latest block

    ```graphql
    query {
      latestBlock {
        hash
        number
      }
    }
    ```

* Run the following GQL query in GraphQL endpoint

  ```graphql
  query {
    isPhisher(
      blockHash: "LATEST_BLOCK_HASH"
      contractAddress: "MOBY_ADDRESS"
      key0: "TWT:phishername"
    ) {
      value
      proof {
        data
      }
    }
    isMember(
      blockHash: "LATEST_BLOCK_HASH"
      contractAddress: "MOBY_ADDRESS"
      key0: "TWT:membername"
    ) {
      value
      proof {
        data
      }
    }
  }
  ```

* Run the following GQL subscription in generated watcher GraphQL endpoint:

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

* Update isPhiser and isMember lists with names

  ```bash
  yarn claimPhisher --contract $MOBY_ADDRESS --name phisherName 
  ```

  ```bash
  yarn claimMember --contract $MOBY_ADDRESS --name memberName
  ```

* The events should be visible in the subscription at GQL endpoint. Note down the event blockHash from result.

* The isMember and isPhisher lists should be indexed. Check the moby-mask-watcher database tables `is_phisher` and `is_member`, there should be entries at the event blockHash and the value should be true. The data is indexed in `handleEvent` method in the [hooks file](./src/hooks.ts).

  NOTE: The credentials for moby-mask-watcher database can be taken from `watcher-db` service in [docker-compose.yml](./docker-compose.yml) file

* Update the the previous query with event blockHash and check isPhisher and isMember in GraphQL playground

  ```graphql
  query {
    isPhisher(
      blockHash: "EVENT_BLOCK_HASH"
      contractAddress: "MOBY_ADDRESS",
      key0: "TWT:phishername"
    ) {
      value
      proof {
        data
      }
    }
    
    isMember(
      blockHash: "EVENT_BLOCK_HASH"
      contractAddress: "MOBY_ADDRESS",
      key0: "TWT:membername"
    ) {
      value
      proof {
        data
      }
    }
  }
  ```

  The data is fetched from watcher database as it is already indexed.

## Reset / Clean up

* Reset and clear deployments in MobyMask repo:

  ```bash
  cd packages/hardhat

  # Remove previous deployments in local network if any
  cd deployments
  git clean -xdf
  ```

* To stop the services running in background run:

  ```bash
  docker-compose down -v
  ```
