#!/bin/bash

# Run the agent (for aws-vpcmode)
sudo /usr/bin/docker run \
  --name ecs-agent \
  --init \
  --restart=on-failure:10 \
  --volume=/var/run:/var/run \
  --volume=/var/log/ecs/:/log:Z \
  --volume=/var/lib/ecs/data:/data:Z \
  --volume=/etc/ecs:/etc/ecs \
  --volume=/sbin:/host/sbin \
  --volume=/lib:/lib \
  --volume=/lib64:/lib64 \
  --volume=/usr/lib:/usr/lib \
  --volume=/usr/lib64:/usr/lib64 \
  --volume=/proc:/host/proc \
  --volume=/sys/fs/cgroup:/sys/fs/cgroup \
  --net=host \
  --env-file=/etc/ecs/ecs.config \
  --cap-add=sys_admin \
  --cap-add=net_admin \
  --env ECS_CLUSTER='ret_de_test_ecs' \
  --env ECS_ENABLE_TASK_ENI=true \
  --env ECS_UPDATES_ENABLED=true \
  --env ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=1h \
  --env ECS_DATADIR=/data \
  --env ECS_ENABLE_TASK_IAM_ROLE=true \
  --env ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true \
  --env ECS_LOGFILE=/log/ecs-agent.log \
  --env ECS_AVAILABLE_LOGGING_DRIVERS='["json-file","awslogs","syslog","none"]' \
  --env ECS_LOGLEVEL=info \
  --detach \
  amazon/amazon-ecs-agent:latest