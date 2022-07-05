#!/bin/sh

# TODO: Move values to variables.

geth \
	--networkid "41337" \
	--datadir "./data" \
	init genesis.json

geth account import \
	--datadir ./data \
	--password ./keys/password.txt \
	./keys/0xDC7d7A8920C8Eecc098da5B7522a5F31509b5Bfc.prv
