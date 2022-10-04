#!/bin/sh
openssl rand -hex 32 | tee jwtsecret > /dev/null
