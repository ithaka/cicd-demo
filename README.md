# cicd-demo

Notes:
eval $(minikube docker-env) - tells minikube to use local docker daemon, which allows it to use local images.


To build images and run tests: 
cd hello-world
docker-compose up --build