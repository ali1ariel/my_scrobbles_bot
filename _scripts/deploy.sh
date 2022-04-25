#!/bin/bash
VERSION=$1
docker build -f _docker/Dockerfile.prod -t softaliza/cieb . && 
docker tag softaliza/cieb softaliza/cieb:$VERSION && 
docker --config ~/hub_softaliza push softaliza/cieb &&
docker --config ~/hub_softaliza push softaliza/cieb:$VERSION
