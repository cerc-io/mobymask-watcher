# Demo

* Follow the instructions in [Setup](../README.md#setup).

* Copy the mainnet Geth LevelDB data to [eth-chaindata](../eth-chaindata/) directory or assign the path containing LevelDB data to `GETH_DATA` variable in [.env](../.env) file.

* Start the services:

  ```bash
  docker-compose --profile watcher up -d
  ```

* Set the deployed MobyMask contract as the watched address in Geth. This will invoke gap filling by `eth-statediff-fill-service`.

  * Set the MobyMask contract address and the block number at which it was deployed:

    Set the MobyMask contract deployment block number:

    ```bash
    export MOBY_ADDRESS="<MOBY_ADDRESS>"

    export DEPLOY_BLOCK_NUMBER="<DEPLOY_BLOCK_NUMBER>"
    ```

  * Make a CURL request to Geth to watch the address:

    ```bash
    curl http://localhost:8545 -H "Content-Type: application/json" -d '{ "jsonrpc":"2.0", "method":"statediff_watchAddress", "params":["add",[{ "Address":"'"$MOBY_ADDRESS"'", "CreatedAt": '"$DEPLOY_BLOCK_NUMBER"' }]], "id":1 }'
    ```

* Check that the `eth-statediff-fill-service` has started gap filling for the watched address.

  ```bash
  docker-compose logs -f eth-statediff-fill-service
  ```

  A message for running gap filler should appear at the end. Example:
  
  ```bash
  eth-statediff-fill-service_1    | time="2022-07-05T09:17:59Z" level=info msg="running watched address gap filler for block range: (30, 137)"
  ```

* Run the following GQL mutation GraphQL endpoint http://127.0.0.1:3001/graphql to start watching the contract in moby-mask-watcher:

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

* Run the following GQL query in GraphQL endpoint with the existing phisher or member names:

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

## Reset / Clean up

* To stop the services running in background run:

  ```bash
  docker-compose down -v
  ```
