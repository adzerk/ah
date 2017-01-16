#!/bin/bash

export AH_APP=$AH_APP
export AH_ENV=$AH_ENV
export AH_REGION=$AH_REGION
export AH_BUCKET=$AH_BUCKET

# install packages

if ! (which make && which aws) > /dev/null; then
  apt-get update
  apt-get -y upgrade
  apt-get -y install make python python-pip
  pip install awscli
fi

# setup initial AWs config file

if [[ ! -e /root/.aws/config ]]; then
  mkdir -m 0700 -p /root/.aws
  cat <<EOT > /root/.aws/config
[default]
region = $AH_REGION
EOT
  chmod 0600 /root/.aws/config
fi

# install ah-client

pushd /usr/local/bin
  cat <<EOT >> ah-client
#!/usr/bin/env bash

export AH_REGION=$AH_REGION
export AH_BUCKET=$AH_BUCKET
export AH_APP=$AH_APP
export AH_ENV=$AH_ENV

EOT
  aws s3 cp s3://$AH_BUCKET/bin/ah-client - >> ah-client
  chmod 755 ah-client
popd

# provision and deploy application on first boot

ah-client provision deploy
