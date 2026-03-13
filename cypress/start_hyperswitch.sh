#!/bin/bash

REPO="https://github.com/juspay/hyperswitch"
IMAGE="juspaydotin/hyperswitch-router"
MAX_TRIES=5

git clone --depth 1 $REPO hyperswitch || true
cd hyperswitch

git fetch --tags --quiet

# install docker compose once
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

attempt=0

for tag in $(git tag --sort=-creatordate); do
  [ $attempt -ge $MAX_TRIES ] && break

  echo "==== Trying tag: $tag ===="

  # check docker image exists
  if ! docker manifest inspect $IMAGE:$tag >/dev/null 2>&1; then
    echo "Docker image not available for $tag"
    attempt=$((attempt+1))
    continue
  fi

  echo "Checking out tag $tag..."
  git reset --hard
  git checkout --quiet $tag

  sed "s|juspaydotin/hyperswitch-router:standalone|$IMAGE:${tag}|g" docker-compose.yml > docker-compose.tmp
  mv docker-compose.tmp docker-compose.yml

  # Specify the correct file path to the TOML file
  toml_file="config/docker_compose.toml"

  # Ensure the file exists
  if [[ ! -f "$toml_file" ]]; then
    echo "Error: File $toml_file not found!"
    exit 1
  fi

  # Use sed to remove the [network_tokenization_service] section and all its keys
  sed '/^\[network_tokenization_service\]/,/^\[.*\]/d' "$toml_file" > temp.toml
  mv temp.toml "$toml_file"

  echo "Starting docker compose..."
  
  # Start Docker Compose services in detached mode
  docker-compose up -d pg redis-standalone migration_runner hyperswitch-server hyperswitch-web mailhog || {
    echo "Docker compose failed for tag $tag - cleaning up and trying next tag"
    docker rm -f hyperswitch-mailhog-1 || true
    docker rm -f hyperswitch-migration_runner-1 || true
    docker rm -f hyperswitch-hyperswitch-web-1 || true
    docker rm -f hyperswitch-hyperswitch-server-1 || true
    docker rm -f hyperswitch-redis-standalone-1 || true
    docker rm -f hyperswitch-pg-1 || true
    docker network rm hyperswitch_router_net || true
    attempt=$((attempt+1))
    continue 
  }

  if docker ps --format '{{.Names}}' | grep -q hyperswitch-server; then
      echo "SUCCESS: Working version -> $tag"
      exit 0
  else
      echo "FAILED: $tag"
      docker-compose logs
      docker-compose down
  fi

  attempt=$((attempt+1))

done

echo "No working tag found in last $MAX_TRIES attempts"
exit 1
