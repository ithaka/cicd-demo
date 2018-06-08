#!/bin/bash -e
# usage: ./set_me_up.sh <service-account> <namespace (stg|prod)>"

if [ -z ${GITHUB_USERID+x} ]; then
     echo "GITHUB_USERID is unset, exitting";
     exit 1
else
    echo "GITHUB_USERID is set to '$GITHUB_USERID'"
fi

if [ -z ${GITHUB_AUTH_TOKEN+x} ]; then
     echo "GITHUB_AUTH_TOKEN is unset, exitting";
     exit 1
else
    echo "GITHUB_AUTH_TOKEN is set, so using that."
fi

# echo "Attempting to reinstall stuff you probably have and start minikube"
# set +e
# brew install kubectl kubernetes-helm
# minikube config set disk-size 40000MB
#
# minikube start
# #minikube start --extra-config=apiserver.authorization-mode=RBAC
# #kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
# set -e

#
eval "$(minikube docker-env)"
minikube status


SERVICE_ACCOUNT_NAME=${1:-tiller}
TILLER_NAMESPACE=${2:-kube-system}

# echo "creating service account ${SERVICE_ACCOUNT_NAME} in namespace ${TILLER_NAMESPACE} with ClusterRoleBinding"
# # If the namespace does not exist this will not work.
# # If the service account exists already, this will also not work.
# echo "Adding RBAC for Tiller for service account ${SERVICE_ACCOUNT_NAME} in namespace ${TILLER_NAMESPACE}"
# cat <<EOTILLERRBAC | kubectl create -f -
# ---
# apiVersion: v1
# kind: ServiceAccount
# metadata:
#   name: ${SERVICE_ACCOUNT_NAME}
#   namespace: ${TILLER_NAMESPACE}
# ---
# apiVersion: rbac.authorization.k8s.io/v1beta1
# kind: ClusterRoleBinding
# metadata:
#   name: ${SERVICE_ACCOUNT_NAME}
# roleRef:
#   apiGroup: rbac.authorization.k8s.io
#   kind: ClusterRole
#   name: cluster-admin
# subjects:
#   - kind: ServiceAccount
#     name: ${SERVICE_ACCOUNT_NAME}
#     namespace: ${TILLER_NAMESPACE}
# EOTILLERRBAC


# echo "Installing dashboard"
# kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
#
# cat <<EODASH | kubectl create -f -
# ---
# apiVersion: v1
# kind: Service
# metadata:
#   labels:
#     k8s-app: kubernetes-dashboard
#   name: kubernetes-dashboard-nodeport
#   namespace: kube-system
# spec:
#   ports:
#   - port: 8443
#     protocol: "TCP"
#     targetPort: 8443
#     nodePort: 31234
#   selector:
#     k8s-app: kubernetes-dashboard
#   sessionAffinity: None
#   type: NodePort
# EODASH


# echo "Installing Helm with Service account ${SERVICE_ACCOUNT_NAME} into tiller-namespace ${TILLER_NAMESPACE}"
# helm init --service-account "${SERVICE_ACCOUNT_NAME}" --tiller-namespace "${TILLER_NAMESPACE}" --wait
# helm repo update
# echo "Installing Jenkins Helm Chart"

sed -e "s/{REPLACE_WITH_GITHUB_TOKEN}/$GITHUB_AUTH_TOKEN/g" \
 -e "s/{REPLACE_WITH_GITHUB_USERID}/$GITHUB_USERID/g" \
 ./jenkins/values-template.yaml >./jenkins/values.yaml


helm install --name jenkins stable/jenkins --values jenkins/values.yaml --tiller-namespace="${TILLER_NAMESPACE}"

# kubectl create sa kube-system-superadmin -n kube-system
# kubectl create clusterrolebinding kube-system-superadmin \
#   --clusterrole=cluster-admin \
#   --serviceaccount=kube-system:kube-system-superadmin
#
# SUPER_SECRET=$(kubectl get sa kube-system-superadmin -n kube-system -o jsonpath='{.secrets[0].name}')
# TOKEN=$(kubectl get secret  "${SUPER_SECRET}" -n kube-system -o go-template='{{ index .data.token }}' | base64 -D)
#
# printf '%s' "$TOKEN" | pbcopy;
# echo "Token copied to clipboard, please paste it in when prompted";
# open "https://localhost:31234/"
minikube dashboard

echo "Getting jenkins for you"
# JENKINS_PORT=$(kubectl get service jenkins -o jsonpath="{.spec.ports[0].nodePort}")
# open "https://localhost:${JENKINS_PORT}/"
open "$(minikube service jenkins --url)"
