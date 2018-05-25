#!/bin/bash -e


# usage: ./set_me_up.sh <service-account> <namespace (stg|prod)>"
# brew install kubectl kubernetes-helm

SERVICE_ACCOUNT_NAME=${1:-tiller}
TILLER_NAMESPACE=${2:-kube-system}

echo "creating service account ${SERVICE_ACCOUNT_NAME} in namespace ${TILLER_NAMESPACE}"
# If the namespace does not exist this will not work.
# If the service account exists already, this will also not work.
kubectl create sa "${SERVICE_ACCOUNT_NAME}" -n ${TILLER_NAMESPACE}

echo "Adding RBAC for Jobs for service account ${SERVICE_ACCOUNT_NAME} in namespace ${TILLER_NAMESPACE}"
cat <<EOTILLERRBAC | kubectl create -f -
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: ${SERVICE_ACCOUNT_NAME}-role
  namespace: ${TILLER_NAMESPACE}
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["*"]
  verbs: ["*"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: ${SERVICE_ACCOUNT_NAME}-binding
  namespace: ${TILLER_NAMESPACE}
subjects:
- kind: ServiceAccount
  name: ${SERVICE_ACCOUNT_NAME}
  namespace: ${TILLER_NAMESPACE}
roleRef:
  kind: Role
  name: ${SERVICE_ACCOUNT_NAME}-role
  apiGroup: rbac.authorization.k8s.io
EOTILLERRBAC


echo "Installing dashboard"
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

cat <<EODASH | kubectl create -f -
---
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard-nodeport
  namespace: kube-system
spec:
  ports:
  - port: 8443
    protocol: "TCP"
    targetPort: 8443
    nodePort: 31234
  selector:
    k8s-app: kubernetes-dashboard
  sessionAffinity: None
  type: NodePort
EODASH



echo "Installing Helm with Service account ${SERVICE_ACCOUNT_NAME} into tiller-namespace ${TILLER_NAMESPACE}"
helm init --service-account "${SERVICE_ACCOUNT_NAME}" --tiller-namespace "${TILLER_NAMESPACE}"
helm repo update
echo "Installing Jenkins Helm Chart"
helm install --name jenkins stable/jenkins --values jenkins/values.yaml --tiller-namespace="${TILLER_NAMESPACE}"

kubectl create sa kube-system-superadmin -n kube-system
kubectl create clusterrolebinding kube-system-superadmin \
  --clusterrole=cluster-admin \
  --serviceaccount=kube-system:kube-system-superadmin

SUPER_SECRET=$(kubectl get sa kube-system-superadmin -n kube-system -o jsonpath='{.secrets[0].name}')
TOKEN=$(kubectl get secret  "${SUPER_SECRET}" -n kube-system -o go-template='{{ index .data.token }}' | base64 -D)

printf '%s' "$TOKEN" | pbcopy;
echo "Token copied to clipboard, please paste it in when prompted";
open "https://localhost:31234/"

echo "Getting jenkins for you"
JENKINS_PORT=$(kubectl get service jenkins -o jsonpath="{.spec.ports[0].nodePort}")
open "https://localhost:${JENKINS_PORT}/"
