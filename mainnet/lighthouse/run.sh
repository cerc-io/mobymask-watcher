#!/bin/bash

# Start a beacon node.
lighthouse \
	--debug-level info \
	--network mainnet \
	beacon_node \
	--execution-endpoint http://geth:8551 \
	--execution-jwt /root/.lighthouse/jwtsecret \
	--http \
	--http-address 0.0.0.0 \
	--metrics \
	--metrics-address 0.0.0.0
