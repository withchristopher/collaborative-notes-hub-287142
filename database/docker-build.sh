#!/usr/bin/env bash
set -euo pipefail

# Simple, non-interactive build script for the database container.
# This script intentionally does NOT cd into any optional directories such as db_visualizer.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="${IMAGE_NAME:-collab-notes-db}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" "${SCRIPT_DIR}"

echo "Build complete."
