# Demo

* Follow the instructions in [Setup](./README.md#setup).

* Start the core services:

  ```bash
  docker-compose up -d
  ```

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

* Update isPhiser and isMember lists with names

  ```bash
  yarn claimPhisher --contract $MOBY_ADDRESS --name oldPhisher
  ```

  ```bash
  yarn claimMember --contract $MOBY_ADDRESS --name oldMember
  ```

* Stop the docker services and reset the indexer database.

  ```bash
  # In mobymask-watcher repo
  docker-compose stop

  # Remove container to remove the volume used
  docker-compose rm -f ipld-eth-db

  # Remove the volume
  docker volume rm mobymask-watcher_indexer_db_data
  ```

* Start all the services (core and watcher) now: 

  ```bash
  docker-compose --profile watcher up -d
  ```

* Set the deployed MobyMask contract as the watched address in Geth.

  * Get the block at which it was deployed by checking the `packages/hardhat/deployments/localhost/PhisherRegistry.json` file in MobyMask repo. In the JSON file the block number at which contract was deployed at is set in `receipt.blockNumber`.

    Set the deployment block number:

    ```bash
    export DEPLOY_BLOCK_NUMBER="<DEPLOY_BLOCK_NUMBER>"
    ```

  * Make CURL request to set the watched address:

    ```bash
    curl http://localhost:8545 -H "Content-Type: application/json" -d '{ "jsonrpc":"2.0", "method":"statediff_watchAddress", "params":["add",[{ "Address":"'"$MOBY_ADDRESS"'", "CreatedAt": '"$DEPLOY_BLOCK_NUMBER"' }]], "id":1 }'
    ```

* Check that the eth-statediff-fill-service has started gap filler for watched address.

  ```bash
  docker-compose logs -f eth-statediff-fill-service
  ```

  A message for running gap filler should appear at the end. Example:
  
  ```bash
  eth-statediff-fill-service_1    | time="2022-07-05T09:17:59Z" level=info msg="running watched address gap filler for block range: (30, 137)"
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
      key0: "TWT:oldphisher"
    ) {
      value
      proof {
        data
      }
    }
    isMember(
      blockHash: "LATEST_BLOCK_HASH"
      contractAddress: "MOBY_ADDRESS"
      key0: "TWT:oldmember"
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

* Update isPhiser and isMember lists with new names

  ```bash
  yarn claimPhisher --contract $MOBY_ADDRESS --name newPhisher 
  ```

  ```bash
  yarn claimMember --contract $MOBY_ADDRESS --name newMember
  ```

* The events should be visible in the subscription at GQL endpoint. Note down the event blockHash from result.

* The isMember and isPhisher lists should be indexed. Check the moby-mask-watcher database tables `is_phisher` and `is_member`, there should be entries at the event blockHash and the value should be true. The data is indexed in `handleEvent` method in the [hooks file](./src/hooks.ts).

  NOTE: The credentials for moby-mask-watcher database can be taken from `watcher-db` service in [docker-compose.yml](./docker-compose.yml) file

* Query with event blockHash and check isPhisher and isMember in GraphQL playground for the new names:

  ```graphql
  query {
    isPhisher(
      blockHash: "EVENT_BLOCK_HASH"
      contractAddress: "MOBY_ADDRESS",
      key0: "TWT:newphisher"
    ) {
      value
      proof {
        data
      }
    }
    
    isMember(
      blockHash: "EVENT_BLOCK_HASH"
      contractAddress: "MOBY_ADDRESS",
      key0: "TWT:newmember"
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
