#!/bin/sh

# Check if database is reachable
if curl -s http://db:5432 | grep -q 'PostgreSQL'; then
  exit 0
else
  exit 1
fi