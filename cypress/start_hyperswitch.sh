#!/bin/bash

git clone --depth 1 https://github.com/juspay/hyperswitch
cd hyperswitch
today=$(date +'%Y.%m.%d')
git fetch --tags
latest_tag=$(git tag --sort=-creatordate | grep "^$today" | head -n 1)
git checkout "$latest_tag"

curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sed 's|juspaydotin/hyperswitch-router:standalone|juspaydotin/hyperswitch-router:nightly|g' docker-compose.yml > docker-compose.tmp
mv docker-compose.tmp docker-compose.yml


# Specify the correct file path to the TOML file
toml_file="config/docker_compose.toml"  # Adjust the path if necessary

# Ensure the file exists
if [[ ! -f "$toml_file" ]]; then
  echo "Error: File $toml_file not found!"
  exit 1
fi

# Use sed to remove the [network_tokenization_service] section and all its keys
sed '/^\[network_tokenization_service\]/,/^\[.*\]/d' "$toml_file" > temp.toml
mv temp.toml "$toml_file"
echo "[network_tokenization_service] section removed from $toml_file."

# Start Docker Compose services in detached mode
chmod +x /usr/local/bin/docker-compose
docker-compose up -d pg redis-standalone migration_runner hyperswitch-server hyperswitch-web mailhog || {
    echo "Docker Compose failed to start services";
    docker logs hyperswitch-pg-1;
    docker logs hyperswitch-hyperswitch-server-1;
    docker logs hyperswitch-hyperswitch-web-1;
    exit 1;
}