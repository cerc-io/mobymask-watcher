# Local Web App Demo

Demo for running MobyMask react app locally with mobymask-watcher

* Start the core services:

  ```bash
  docker-compose up --build -d
  ```

* Deploy the MobyMask contract and get the invite link for app:

  ```bash
  docker-compose exec -w /app/packages/server -e ENV=PROD mobymask yarn start
  ```

  An invite link should be generated after running the command above, that can be used in the React app.

* In a new terminal start the watcher and react app services:

  ```bash
  docker-compose --profile watcher up --build -d
  ```

*  Open the invite link generated above.

* [Configure Metamask browser extension to be connected to the local Geth network](https://community.metamask.io/t/how-to-add-custom-networks-to-metamask-like-binance-and-polygon-matic/3634#how-to-add-a-custom-network-on-metamask-10). Use the following config:
  * New RPC URL: http://localhost:8545
  * ChainID: 41337
  * Symbol: ETH

* Import an account in Metamask that has balance in the local Geth network. The private key for the account is available in [this file](../geth/keys/0xDC7d7A8920C8Eecc098da5B7522a5F31509b5Bfc.prv).

* In the [React app](http://localhost:3000/#/members) check for a phisher name. It should say that it is not a registered phisher as there are no reports yet.

* Before making transactions, it may be required to [reset account in Metamask](https://metamask.zendesk.com/hc/en-us/articles/360015488891-How-to-reset-your-account).

* Report a phishing attempt using the app. Multiple phishers can be reported and submitted in a single batch.

* After the transaction is confirmed check the status for the reported phisher names.

* The check for phishers in the app is done using mobymask-watcher GraphQL API. The code can be seen [here](https://github.com/cerc-io/MobyMask/blob/use-laconic-watcher-as-hosted-index/packages/react-app/src/PhisherCheck.jsx#L31).

* The same steps can be performed for checking member status and endorsing new members.

* Generate an invite link by clicking on `Create new invite link` button.

* Use the link generated in a different browser profile. We should be able to see the [members page](http://localhost:3000/#/members).

* The same operations for reporting phishers and endorsing members can be performed from this browser.

* Revoke the invitation from the previous browser profile. The section for revoking invitations should be below `Create new invite link` button.

* After transaction is confirmed the browser using the invitation should not be able to report new phishers or endorse members.

## Reset / Clean up

* To stop the services running in background run:

  ```bash
  docker-compose down -v
  ```
