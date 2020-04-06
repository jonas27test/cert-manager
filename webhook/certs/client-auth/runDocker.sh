#!/bin/bash
docker build . -t localhost:32000/webhooktest
docker push localhost:32000/webhooktest