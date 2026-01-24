#!/bin/bash

# Clone the repo
git clone --depth 1 https://github.com/juspay/hyperswitch
cd hyperswitch

# Fetch the latest tags from GitHub
git fetch --tags

# Get the latest 5 tags in the format YYYY.MM.DD.N
tags=$(git tag --sort=-creatordate | grep -E '^[0-9]{4}\.[0-9]{2}\.[0-9]{2}\.[0-9]+$' | head -n 5)

# Query Docker Hub for tags
docker_tags=$(curl -s "https://hub.docker.com/v2/repositories/juspaydotin/hyperswitch-router/tags/" | jq -r '.results[].name')

# Initialize the matched tag
matched_tag=""

# Loop through the GitHub tags and find a match on Docker Hub
for tag in $tags; do
    if echo "$docker_tags" | grep -q "^$tag$"; then
        matched_tag=$tag
        break
    fi
done

# If no match is found, fallback to the latest GitHub tag
if [ -z "$matched_tag" ]; then
    matched_tag=$(echo "$tags" | head -n 1)
    echo "No match found. Falling back to latest GitHub tag: $matched_tag"
fi

# Checkout the matched tag
git checkout "$matched_tag"

curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sed "s|juspaydotin/hyperswitch-router:standalone|juspaydotin/hyperswitch-router:nightly|g" docker-compose.yml > docker-compose.tmp
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
    docker logs hyperswitch-hyperswitch-server-1;
    docker logs hyperswitch-hyperswitch-web-1;
    exit 1;
}