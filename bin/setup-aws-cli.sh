#!/bin/bash

docker run --rm -it amazon/aws-cli --version
echo alias aws='docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/aws amazon/aws-cli' >> ~/.bashrc
source .bashrc