#!/bin/bash

echo "Installing aws-cli using docker....."
docker run --rm -it amazon/aws-cli --version

echo "Setting up the file named .bashrc"
echo alias aws='docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/aws amazon/aws-cli' >> ~/.bashrc
source ~/.bashrc