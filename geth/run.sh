#!/bin/sh

geth \
	--datadir ./data \
	--syncmode full \
	--gcmode archive \
	--cache 10000 \
	--cache.database 50 \
	--cache.trie 50 \
	--cache.gc 0 \
	--statediff \
	--statediff.writing \
	--statediff.db.type postgres \
	--statediff.db.driver sqlx \
	--statediff.db.nodeid "1" \
	--statediff.db.clientname "client1" \
	--statediff.db.host=$DB_HOST \
	--statediff.db.port=$DB_PORT \
	--statediff.db.name=$DB_NAME \
	--statediff.db.user=$DB_USER \
	--statediff.db.password=$DB_PASSWORD \
	--verbosity "3" \
	--mainnet \
	--http \
	--http.addr "0.0.0.0" \
	--http.port "8545" \
	--http.corsdomain "*" \
	--http.api "web3,eth,statediff,net,debug" \
	--http.vhosts "*" \
	--ws \
