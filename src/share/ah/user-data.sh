#!/bin/bash

die() {
  exec 1>&2
  [[ $# -gt 0 ]] && echo "$(basename "${BASH_SOURCE[0]}"): $(printf "$@")"
  exit 1
}

export AH_APP=$AH_APP
export AH_ENV=$AH_ENV
export AH_BUCKET=$AH_BUCKET
export AH_MASTER_REGION=$AH_MASTER_REGION
export AH_REGION=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}')

# install packages

if which apt-get > /dev/null; then
  if ! (which make && which aws) > /dev/null; then
    apt-get update
    apt-get -y install make python python-pip
    pip install awscli
  fi
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

cat <<EOT >> /etc/ah-client.conf
export AH_MASTER_REGION=$AH_MASTER_REGION
export AH_REGION=$AH_REGION
export AH_BUCKET=$AH_BUCKET
export AH_APP=$AH_APP
export AH_ENV=$AH_ENV
EOT

AWS_DEFAULT_REGION=$AH_MASTER_REGION aws s3 cp s3://$AH_BUCKET/bin/ah-client4 /usr/local/bin/ah-client
chmod 755 /usr/local/bin/ah-client

# provision and deploy application on first boot

/usr/local/bin/ah-client provision deploy
