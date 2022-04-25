#!/bin/bash
docker-compose -f _docker/docker-compose.yml run -e MIX_ENV=test bff_api mix test $@