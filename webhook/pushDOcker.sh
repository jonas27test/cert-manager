#!/bin/bash
docker build . -t jonas27test/webhook:v0.0.2
docker push jonas27test/webhook:v0.0.2