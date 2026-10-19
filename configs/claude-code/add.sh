#!/bin/sh
# Adds Artifact Publisher to Claude Code (local scope by default).
# Set ARTIFACT_PUBLISHER_KEY in your shell first; the key is never written to this file.
# Add --scope user to make it available in all your projects.
claude mcp add --transport http artifact-publisher https://app.artifactpublisher.com/mcp \
  --header "Authorization: Bearer ${ARTIFACT_PUBLISHER_KEY}"
