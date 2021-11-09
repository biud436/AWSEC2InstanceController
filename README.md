# Introduction

This project allows you to print inbound rules and add a new CIDR IP to AWS EC2 Security Group.

# Installation

To install this tool, note that you must install ruby or aws-sdk and then setup a gem named 'aws-sdk-ec2' using rubygem.
if you didn't install ruby language on your system such as 'ubuntu server and macOS', try out below solution.

```sh
chmod +x ./setup.sh
chmod +x ./bin/run.sh

./setup.sh
sudo apt-get install ruby-full
ruby --version
```

or try out these commands. however it is not stable because docker's file system is specially. To resolve this issue, you have to specify the volume of host file system. But this example is not set the volume in your computer. so it is not stable.

```bash
sudo docker pull ruby
vi ~/.bashrc

alias irb='sudo docker run -it ruby'
source ~/.bashrc
```

and next install a new gem named `aws-sdk-ec2`

```sh
gem install aws-sdk-ec2
```

# How to start

```sh
cd ~
git clone https://github.com/HarvenDev/AWSEC2InstanceController.git
cd ./AWSEC2InstanceController
touch config.yml
vi config.yml
```

if you do not have the file called `config.yml` in your root directory, it is created as follows.

```sh
access_id: "<access_id>"
secret_access_key: "<secret_access_key>"
security_group_id: "<security_group_id>"
```

to set these value, you can create a new IAM user in your aws root account and then next the value named `security_group_id` means security group's id string of the AWS EC2 instance. you can try to these steps in your terminal.

```sh
cd ~
docker run --rm -it amazon/aws-cli --version
vi .bashrc

alias aws='docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/aws amazon/aws-cli'
source .bashrc

aws configure
```

finally, try to do below command

# Usage

```sh
Usage: aws_ec2_simple_connector [options]
    -c, --crc                        CRC 체크를 통해 인바운드 규칙을 추가합니다.
    -p, --print                      인바운드 규칙을 출력합니다.
    -h, --help                       Displays Help
```

# Link

[https://docs.aws.amazon.com/sdk-for-ruby/v3/api/index.html](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/index.html)
