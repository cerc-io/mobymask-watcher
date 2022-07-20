# Demo

* Start the core services:

  ```bash
  docker-compose up --build -d
  ```

* Deploy the contract:

  ```bash
  docker-compose exec mobymask yarn deploy
  # deploying "PhisherRegistry" (tx: 0xaebeb2e883ece1f679304ec46f5dc61ca74f9e168427268a7dfa8802195b8de0)...: deployed at <MOBY_ADDRESS> with 2306221 gas
  # $ hardhat run scripts/publish.js
  # ✅  Published contracts to the subgraph package.
  # Done in 14.28s.
  ```
  
  Export the address of the deployed contract to a shell variable for later use:

  ```bash
  export MOBY_ADDRESS="<MOBY_ADDRESS>"
  ```

* Update `isPhisher` and `isMember` maps in the deployed contract with names:

  ```bash
  docker-compose exec -w /app/packages/hardhat  mobymask yarn claimPhisher --contract $MOBY_ADDRESS --name oldPhisher
  ```

  ```bash
  docker-compose exec -w /app/packages/hardhat mobymask yarn claimMember --contract $MOBY_ADDRESS --name oldMember
  ```

* Stop the docker services and reset the indexer database to demonstrate statediffing only for the watched address. The database will later be filled by `eth-statediff-fill-service` with data only for the watched address. 

  ```bash
  # Stop the docker services
  docker-compose stop

  # Remove the indexer database
  docker-compose rm -f ipld-eth-db
  docker volume rm mobymask-watcher_indexer_db_data
  ```

* Start all the services (core and watcher) now: 

  ```bash
  docker-compose --profile watcher up --build -d
  ```

  Geth will start indexing from the block where it last stopped. So the previous blocks can be filled by `eth-statediff-fill-service`.

* Set the deployed MobyMask contract as the watched address in Geth. This will invoke gap filling by `eth-statediff-fill-service`.

  * Get the block at which it was deployed. We can get this information from a JSON file created on deploying the contract:

    ```bash
    docker-compose exec -w /app/packages/hardhat mobymask cat deployments/localhost/PhisherRegistry.json | grep blockNumber
    ```

    Set the MobyMask contract deployment block number:

    ```bash
    export DEPLOY_BLOCK_NUMBER="<DEPLOY_BLOCK_NUMBER>"
    ```

  * Make a CURL request to Geth to watch the address:

    ```bash
    curl http://localhost:8545 -H "Content-Type: application/json" -d '{ "jsonrpc":"2.0", "method":"statediff_watchAddress", "params":["add",[{ "Address":"'"$MOBY_ADDRESS"'", "CreatedAt": '"$DEPLOY_BLOCK_NUMBER"' }]], "id":1 }'
    ```

    The output for successful CURL request should be:

    ```
    {"jsonrpc":"2.0","id":1,"result":null}
    ```

* Check that the `eth-statediff-fill-service` has started gap filling for the watched address.

  ```bash
  docker-compose logs -f eth-statediff-fill-service
  ```

  A message for running gap filler should appear at the end. Example:
  
  ```bash
  eth-statediff-fill-service_1    | time="2022-07-05T09:17:59Z" level=info msg="running watched address gap filler for block range: (30, 137)"
  ```

* Run the following GQL mutation in GraphQL endpoint http://127.0.0.1:3001/graphql to start watching the contract in mobymask-watcher:

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

* Run the following GQL query in GraphQL endpoint:

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

  This query lazily fetches the contract data from `ipld-eth-server`.

* Run the following GQL subscription in generated watcher [GraphQL endpoint](http://127.0.0.1:3001/graphql) to watch for events:

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

* Update contract `isPhisher` and `isMember` maps with new names:

  ```bash
  docker-compose exec -w /app/packages/hardhat mobymask yarn claimPhisher --contract $MOBY_ADDRESS --name newPhisher 
  ```

  ```bash
  docker-compose exec -w /app/packages/hardhat mobymask yarn claimMember --contract $MOBY_ADDRESS --name newMember
  ```

* The events should be visible in the subscription at GQL endpoint. Note down the event blockHash from result.

* The `isMember` and `isPhisher` maps should be indexed. Check the mobymask-watcher database tables `is_phisher` and `is_member`:

  ```bash
  docker-compose exec watcher-db psql -U vdbm mobymask-watcher -c "SELECT block_hash, block_number, contract_address, key0, value FROM is_phisher"
  ```

  ```bash
  docker-compose exec watcher-db psql -U vdbm mobymask-watcher -c "SELECT block_hash, block_number, contract_address, key0, value FROM is_member"
  ```

  There should be entries for the event blockHash with `value` set to true. The data is indexed in `handleEvent` method in the [hooks file](https://github.com/vulcanize/watcher-ts/blob/main/packages/mobymask-watcher/src/hooks.ts).

* Query with event blockHash and check `isPhisher` and `isMember` in GraphQL playground for the new names:

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

* To stop the services running in background run:

  ```bash
  docker-compose down -v
  ```
