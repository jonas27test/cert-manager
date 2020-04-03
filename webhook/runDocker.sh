#!/bin/bash
docker build . -t localhost:32000/webhook
docker push localhost:32000/webhook 