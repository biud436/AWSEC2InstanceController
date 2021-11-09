#!/bin/bash

echo "Setting up the environment..."
SETUP_FILE_PATH="./bin/setup-aws-cli.sh"
BIN_FILE_PATH="./bin/run.sh"
bash "$SETUP_FILE_PATH"
bash "$BIN_FILE_PATH"