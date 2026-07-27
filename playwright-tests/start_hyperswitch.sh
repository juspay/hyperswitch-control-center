#!/usr/bin/env bash
#
# Boots the Hyperswitch backend (router, postgres, redis, web, mailhog) from the most recent published Docker image tag, for use by the Playwright suite.

set -u

REPO="https://github.com/juspay/hyperswitch"
IMAGE_REPO="juspaydotin/hyperswitch-router"
REGISTRY="docker.juspay.io"
IMAGE="${REGISTRY}/${IMAGE_REPO}"
MAX_TRIES=5

# Optional override: pin a known-good tag and skip auto-discovery.
# Useful when all of the most-recent tags fail to boot but an older tag is known to work.
#   HYPERSWITCH_TAG=2026.06.16.0 ./start_hyperswitch.sh
OVERRIDE_TAG="${HYPERSWITCH_TAG:-}"

# ---------------------------------------------------------------------------
# Preflight: docker engine + compose
# ---------------------------------------------------------------------------

if ! command -v docker >/dev/null 2>&1; then
  echo "Error: 'docker' CLI not found on PATH." >&2
  echo "Install Docker Desktop, OrbStack, or Docker Engine and retry." >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Error: Docker daemon is not running / not reachable." >&2
  echo "Start Docker Desktop / OrbStack (or 'colima start') and retry." >&2
  exit 1
fi

# Require the Compose v2 plugin ('docker compose'). Legacy standalone 'docker-compose' (v1) is EOL/unmaintained and is not supported.
if ! docker compose version >/dev/null 2>&1; then
  echo "Error: Docker Compose v2 ('docker compose') not found." >&2
  echo "It is bundled with Docker Desktop / OrbStack / Colima." >&2
  echo "On Linux install it with: 'sudo apt-get install docker-compose-plugin'." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Source checkout
# ---------------------------------------------------------------------------

# Idempotent across repeat runs: reuse an existing checkout but scrub it back to a
# pristine upstream tree, otherwise clone fresh. Refusing a non-git ./hyperswitch
# avoids silently operating on an unrelated directory.
if [ -d hyperswitch/.git ]; then
  echo "Reusing existing ./hyperswitch checkout (refreshing)..."
  cd hyperswitch || { echo "Error: failed to enter ./hyperswitch" >&2; exit 1; }
  # Undo any compose/toml edits and remove leftover *.tmp files from a previous run.
  git reset --hard --quiet || true
  git clean -fdq || true
elif [ -e hyperswitch ]; then
  echo "Error: ./hyperswitch exists but is not a git checkout. Remove it and retry." >&2
  exit 1
else
  git clone --depth 1 "$REPO" hyperswitch || { echo "Error: git clone failed" >&2; exit 1; }
  cd hyperswitch || { echo "Error: failed to enter ./hyperswitch" >&2; exit 1; }
fi

git fetch --tags --quiet

# ---------------------------------------------------------------------------
# Boot a single tag. Returns 0 on success, non-zero otherwise.
# ---------------------------------------------------------------------------

try_tag() {
  tag="$1"
  echo "==== Trying tag: $tag ===="

  # Skip tags that have no published router image.
  if ! docker manifest inspect "$IMAGE:$tag" >/dev/null 2>&1; then
    echo "Docker image not available for $tag"
    return 1
  fi

  echo "Checking out tag $tag..."
  git reset --hard
  git checkout --quiet "$tag"

  # Pin the router image to the resolved tag.
  sed "s|${IMAGE_REPO}:standalone|${IMAGE_REPO}:${tag}|g" \
    docker-compose.yml > docker-compose.tmp && mv docker-compose.tmp docker-compose.yml

  # Remap host ports that clash with other services on a shared host.
  sed -e 's|"5432:5432"|"25432:5432"|g' \
      -e 's|"6379:6379"|"26379:6379"|g' \
      -e 's|"8081:8080"|"28081:8080"|g' \
      -e 's|"9050:9050"|"29050:9050"|g' \
    docker-compose.yml > docker-compose.tmp && mv docker-compose.tmp docker-compose.yml

  sed 's|apk add --no-cache curl jq yq && sh /seed_superposition.sh|apk add --no-cache curl jq yq bash \&\& bash /seed_superposition.sh|g' \
    docker-compose.yml > docker-compose.tmp && mv docker-compose.tmp docker-compose.yml

  # The upstream migration runner installs `just` by resolving its latest release
  # through the unauthenticated GitHub API. That request can be rate-limited (403),
  # especially from local Docker networks. `just migrate` only delegates to the
  # Diesel CLI here, so run the equivalent command directly.
  sed -e '/      if ! command -v just >\/dev\/null 2>\&1; then/,/      fi \&\&/d' \
      -e 's|      just migrate"|      diesel migration run --migration-dir /app/migrations --config-file /app/diesel.toml"|' \
    docker-compose.yml > docker-compose.tmp && mv docker-compose.tmp docker-compose.yml

  echo "Starting docker compose..."

  # Start the required services in detached mode.
  docker compose up -d pg redis-standalone migration_runner hyperswitch-server hyperswitch-web mailhog || {
    echo "Docker compose failed for tag $tag - cleaning up and trying next tag"
    docker compose down -v --remove-orphans || true
    docker rm -f hyperswitch-mailhog-1 || true
    docker rm -f hyperswitch-migration_runner-1 || true
    docker rm -f hyperswitch-hyperswitch-web-1 || true
    docker rm -f hyperswitch-hyperswitch-server-1 || true
    docker rm -f hyperswitch-redis-standalone-1 || true
    docker rm -f hyperswitch-pg-1 || true
    docker rm -f hyperswitch-superposition-1 || true
    docker rm -f hyperswitch-init-1 || true
    docker network rm -f hyperswitch_router_net || true
    return 1
  }

  if docker ps --format '{{.Names}}' | grep -q hyperswitch-server; then
      echo "SUCCESS: Working version -> $tag"
      return 0
  fi

  echo "FAILED: $tag"
  docker compose logs
  docker compose down
  return 1
}

# ---------------------------------------------------------------------------
# If HYPERSWITCH_TAG is set, boot exactly that tag and skip auto-discovery.
# ---------------------------------------------------------------------------

if [ -n "$OVERRIDE_TAG" ]; then
  echo "HYPERSWITCH_TAG override set -> using tag $OVERRIDE_TAG (skipping auto-discovery)"
  if try_tag "$OVERRIDE_TAG"; then
    exit 0
  fi
  echo "Override tag $OVERRIDE_TAG failed to boot"
  exit 1
fi

# ---------------------------------------------------------------------------
# Try the most recent tags until one boots successfully.
# ---------------------------------------------------------------------------

attempt=0

for tag in $(git tag --sort=-creatordate); do
  [ "$attempt" -ge "$MAX_TRIES" ] && break

  if try_tag "$tag"; then
    exit 0
  fi

  attempt=$((attempt+1))

done

echo "No working tag found in last $MAX_TRIES attempts"
exit 1
