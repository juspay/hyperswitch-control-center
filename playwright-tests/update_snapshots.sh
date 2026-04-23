#!/bin/bash
set -euo pipefail

# ---------------------------------------------------------------------------
# update_snapshots.sh
#
# Runs Playwright visual tests inside a Linux Docker container (matching CI)
# to generate / update snapshots that will pass on ubuntu-latest CI runners.
#
# Prerequisites:
#   1. Docker is installed and running
#   2. Backend services started via:  ./playwright-tests/start_hyperswitch.sh
# ---------------------------------------------------------------------------

NETWORK="hyperswitch_router_net"
PLAYWRIGHT_VERSION="v1.58.2"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONTAINER_NAME="playwright-snapshot-updater"
FE_PORT=9000

# Detect architecture for the correct Playwright image
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)  IMAGE="mcr.microsoft.com/playwright:${PLAYWRIGHT_VERSION}-noble" ;;
  aarch64) IMAGE="mcr.microsoft.com/playwright:${PLAYWRIGHT_VERSION}-noble-arm64" ;;
  arm64)   IMAGE="mcr.microsoft.com/playwright:${PLAYWRIGHT_VERSION}-noble-arm64" ;;
  *)       echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# ── Helpers ────────────────────────────────────────────────────────────────

fail() { echo "ERROR: $1"; exit 1; }
info() { echo "-- $1"; }
ok()   { echo "   OK: $1"; }

# ── 1. Verify Docker prerequisites ────────────────────────────────────────

info "Checking Docker prerequisites..."

docker info >/dev/null 2>&1 || fail "Docker is not running."

docker network inspect "$NETWORK" >/dev/null 2>&1 \
  || fail "Docker network '$NETWORK' not found. Run: ./playwright-tests/start_hyperswitch.sh"

# Check that hyperswitch-server container is running
if ! docker ps --format '{{.Names}}' | grep -q "hyperswitch-server"; then
  fail "hyperswitch-server container is not running. Run: ./playwright-tests/start_hyperswitch.sh"
fi
ok "Docker network and backend containers are running."

# ── 2. Build webapp on the host (faster than inside Docker) ───────────────

cd "$PROJECT_DIR"

if [ ! -d "node_modules" ]; then
  info "Installing npm dependencies..."
  npm install --force
else
  ok "node_modules already exists."
fi

if [ ! -d "dist" ]; then
  info "Building webapp (npm run build:test)..."
  npm run build:test
else
  ok "dist/ already exists. To rebuild, delete dist/ and re-run."
fi

# ── 3. Verify backend is reachable from the Docker network ────────────────

info "Checking backend health from Docker network..."

docker run --rm --network "$NETWORK" "$IMAGE" \
  sh -c 'for i in 1 2 3 4 5; do
    if curl -sf http://hyperswitch-server:8080/health >/dev/null 2>&1; then
      exit 0
    fi
    sleep 2
  done
  echo "Backend not reachable at http://hyperswitch-server:8080"; exit 1' \
  || fail "Backend is not reachable from the Docker network."

ok "Backend is healthy and reachable."

# ── 4. Run Playwright inside Docker ───────────────────────────────────────
#
# - Mount the project so Playwright can read dist/ and write snapshots.
# - Start the FE server inside the container (pointing API at the BE container).
# - Run Playwright with --update-snapshots.
# ---------------------------------------------------------------------------

info "Starting Playwright snapshot update in Docker ($IMAGE)..."

# Remove stale container if exists
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

EXIT_CODE=0
docker run --rm \
  --name "$CONTAINER_NAME" \
  --network "$NETWORK" \
  --ipc=host \
  --init \
  -v "${PROJECT_DIR}:/workspace" \
  -w /workspace \
  -e HYPERSWITCH_API_URL=http://hyperswitch-server:8080 \
  -e MAIL_URL=http://mailhog:8025 \
  -e PLAYWRIGHT_USERNAME="${PLAYWRIGHT_USERNAME:-playwright@test.com}" \
  -e PLAYWRIGHT_PASSWORD="${PLAYWRIGHT_PASSWORD:-Playwright00#}" \
  "$IMAGE" \
  bash -c '
    # Start FE server in background — point API at the backend container
    export default__endpoints__api_url=http://hyperswitch-server:8080
    export default__features__email=true
    node dist/server/server.js &
    FE_PID=$!

    # Wait for FE server to be ready
    echo "-- Waiting for FE server on port '"$FE_PORT"'..."
    for i in $(seq 1 30); do
      if curl -sf http://localhost:'"$FE_PORT"' >/dev/null 2>&1; then
        echo "   OK: FE server is ready."
        break
      fi
      if ! kill -0 $FE_PID 2>/dev/null; then
        echo "ERROR: FE server process died."
        exit 1
      fi
      sleep 2
    done

    if ! curl -sf http://localhost:'"$FE_PORT"' >/dev/null 2>&1; then
      echo "ERROR: FE server did not start within 60 seconds."
      exit 1
    fi

    # Run Playwright to update snapshots
    npx playwright test playwright-tests/visual-testing --update-snapshots \
      --config=playwright.config.ts \
      --reporter=list

    TEST_EXIT=$?

    # Stop FE server
    kill $FE_PID 2>/dev/null || true
    wait $FE_PID 2>/dev/null || true

    exit $TEST_EXIT
  ' || EXIT_CODE=$?

# ── 5. Report results ────────────────────────────────────────────────────

echo ""
echo "=========================================="
if [ $EXIT_CODE -eq 0 ]; then
  echo "Snapshot update completed successfully."
else
  echo "Playwright exited with code $EXIT_CODE."
  echo "Check test-results/ and playwright-report/ for details."
fi

# Show which snapshots were modified
echo ""
echo "Modified snapshots:"
CHANGED=$(git diff --name-only -- '*.png' 2>/dev/null || true)
UNTRACKED=$(git ls-files --others --exclude-standard -- '*.png' 2>/dev/null || true)
ALL_CHANGED=$(printf '%s\n%s' "$CHANGED" "$UNTRACKED" | grep -v '^$' | sort -u || true)

if [ -n "$ALL_CHANGED" ]; then
  echo "$ALL_CHANGED" | while read -r f; do echo "  $f"; done
else
  echo "  (no snapshot changes detected)"
fi

exit $EXIT_CODE
