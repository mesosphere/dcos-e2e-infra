# DC/OS E2E environment preparation

This repo holds some automation scripts that create an AWS EC2 instance using
CloudFormation and prepares it to run DC/OS e2e tests.

# How to use

Configuration is provided using the `config.sh` file. You will also need an SSH
key pair for accessing your EC2 instance.

1. Create an EC2 key pair and download the private key. https://console.aws.amazon.com/ec2/v2/home#KeyPairs
1. Prepare your shell to access AWS services using the CLI. https://aws.amazon.com/cli/
1. Clone this repo and put the EC2 private key in the same folder as the rest of
   the files from this repo. The name of the file must be `ssh-key.pem`.
1. Create the file `config.sh` and provide a complete configuration (see example
   below). The file must reside in the folder containing this repo's contents.
1. Run `./stack status` to see whether everything is prepared. It should tell
   you that no stack with the given name exists, yet.
1. Create your CloudFormation stack: `./stack create`
1. When everything's worked fine, you'll find yourself SSH'd into the machine
   after some minutes.
1. Type `cd e2e/dcos/test-e2e` and then run a test, e.g. `pytest
   test_service_account.py`

# Command reference

The `stack` command has several sub-commands:

## `./stack create`

Creates the CloudFormation stack, prepares an e2e test environment and logs you
into the machine.

## `./stack delete`

Deletes the CloudFormation stack completely.

## `./stack status [-f]`

Checks the status of the CloudFormation stack. If the `-f` flag is provided,
queries the status every 500ms until a final status is returned (a status is
treated as final when it doesn't end with `_IN_PROGRESS`).

## `./stack outputs`

Lists all the outputs from the CloudFormation stack such as the public IPv4
address.

## `./stack ssh`

Opens an SSH session on the EC2 machine. This way you don't have to find out the
machine's IP address and/or user name.

# Example configuration

Here's a sample `config.sh` file:

```sh
# This is the name of the CloudFormation stack created for you
STACK_NAME=makkes-e2e
# This is the name of the key pair used for the EC2 instance. This key pair
# must exist prior to creating the CloudFormation stack. The private key must
# reside in a file called `ssh-key.pem` in the current directory.
KEYPAIR_NAME=makkes-e2e
# Do you want to test Open Source DC/OS or Enterprise? 'open' or 'ee'
VARIANT=ee
```
