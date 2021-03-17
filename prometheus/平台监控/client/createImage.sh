#!/usr/bin/env bash

docker build -t ecs-mointor-client:1.0 .

docker tag ecs-mointor-client:1.0 192.168.12.124:7080/exporter/ecs-monitor-client:1.0

docker push 192.168.12.124:7080/exporter/ecs-monitor-client:1.0
