#!/bin/bash
# GitLab Shared Runner Container Escape PoC
# Reference: H1 #1442118, Pulse Security OMGCICD
# Tests if DIND/privileged runners allow container escape
#
# WARNING: Only test on YOUR OWN GitLab instance or authorized targets
#
# USAGE: Push this as .gitlab-ci.yml to a test project
# and check if the runner is shared + privileged
#
# Paste this entire file as your .gitlab-ci.yml:

: '
image: alpine:latest

stages:
  - test

container-escape-test:
  stage: test
  script:
    - |
      echo "[*] Checking if we can escape..."
      
      # Check if privileged
      cat /proc/1/status | grep -i cap
      ip link
      
      # Check cgroup mount
      mkdir -p /tmp/cgrp
      mount -t cgroup -o rdma cgroup /tmp/cgrp 2>/dev/null && echo "[!] CGROUP MOUNTABLE - likely escapeable" || echo "[*] CGROUP not mountable - probably safe"
      
      # Check Docker socket
      ls -la /var/run/docker.sock 2>/dev/null && echo "[!] DOCKER SOCKET FOUND" || echo "[*] No docker socket"
      
      # Check /dev devices
      ls -la /dev/dm* 2>/dev/null
      
      echo "[*] Test complete"
'

echo ""
echo "=== GitLab Container Escape Test ==="
echo ""
echo "This script is a REFERENCE for testing your own runners."
echo "To use:"
echo "  1. Copy the YAML section above into .gitlab-ci.yml"
echo "  2. Push to a test project on your GitLab instance"
echo "  3. Check pipeline output for [!] indicators"
echo ""
echo "If '[!] CGROUP MOUNTABLE' appears -> runner is vulnerable to escape"
echo "If '[!] DOCKER SOCKET FOUND' appears -> runner has Docker access"
echo ""
echo "Full escape payload reference in: workflows/06-gitlab-hunt.md (Attack 2.3)"
