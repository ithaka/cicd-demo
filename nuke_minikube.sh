#!/usr/bin/env bash

minikube stop
minikube delete
docker stop "$(docker ps -aq)"
rm -r ~/.kube
rm -r -f ~/.minikube
sudo rm /usr/local/bin/localkube /usr/local/bin/minikube
systemctl stop '*kubelet*.mount'
sudo rm -rf /etc/kubernetes/
docker system prune -af --volumes
