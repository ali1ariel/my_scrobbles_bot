#!/bin/bash
docker-compose -f _docker/docker-compose.yml up -d && docker attach docker_bff_api_1