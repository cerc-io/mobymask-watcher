#!/bin/sh

curl http://$GETH_HTTP_PATH -H "Content-Type: application/json" -d '{ "jsonrpc":"2.0", "method":"statediff_watchAddress", "params":["add",[{ "Address":"'"$MOBY_ADDRESS"'", "CreatedAt": '"$DEPLOY_BLOCK_NUMBER"' }]], "id":1 }'
