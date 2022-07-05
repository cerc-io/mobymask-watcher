#!/bin/sh

echo "Beginning the eth-statediff-fill-service process"

echo running: eth-statediff-fill-service ${VDB_COMMAND} --config=./eth-statediff-fill-service/environments/example.toml
eth-statediff-fill-service ${VDB_COMMAND} --config=./eth-statediff-fill-service/environments/example.toml
rv=$?

if [ $rv != 0 ]; then
  echo "eth-statediff-fill-service startup failed"
  exit 1
fi
