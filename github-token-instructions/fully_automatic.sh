#!/bin/bash

if [ -z ${GITHUB_USERID+x} ]; then
     echo "GITHUB_USERID is unset, exitting";
     exit 1
else
    echo "GITHUB_USERID is set to '$GITHUB_USERID'"
fi

if [ -z ${GITHUB_AUTH_TOKEN+x} ]; then
     echo "GITHUB_AUTH_TOKEN is unset, so making one for you.";


GITHUB_URL="https://api.github.com/authorizations"
curl https://api.github.com/authorizations \

# store the whole response with the status at the and
HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" \
--user "${GITHUB_USERID}" \
--data '{"scopes":["repo"],"note":"Minikube-Jenkins-Demo"}' \
$GITHUB_URL)

# extract the body
HTTP_BODY=$(echo "$HTTP_RESPONSE" | sed -e 's/HTTPSTATUS\:.*//g')

# extract the status
HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

# print the body
echo "$HTTP_BODY"

# example using the status
if [ $HTTP_STATUS -eq 401  ]; then
  echo "Recieved 401, so trying again with Multifactor Auth OTP"
  echo -n "Enter Multi-Factor Auth code for $GITHUB_USERID: "
  read -s GITHUB_OTP
  echo ""
  HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" \
  -H "X-GitHub-OTP: ${GITHUB_OTP}" \
  --user "${GITHUB_USERID}" \
  --data '{"scopes":["repo"],"note":"Minikube-Jenkins-Demo4"}' \
  $GITHUB_URL)

  # extract the body
  HTTP_BODY=$(echo "$HTTP_RESPONSE" | sed -e 's/HTTPSTATUS\:.*//g')

  # extract the status
  HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
fi

if [ ! $HTTP_STATUS -eq 201  ]; then
  echo "Error [HTTP status: $HTTP_STATUS]"
  echo "RESPONSE:"
  echo "$HTTP_BODY"
  exit 1
fi

GITHUB_AUTH_TOKEN=$(echo "$HTTP_BODY" | jq -r .token)
export GITHUB_AUTH_TOKEN
echo 'export GITHUB_AUTH_TOKEN="'"$GITHUB_AUTH_TOKEN"'"' > secret_token.sh
chmod u+x secret_token.sh
git ignore secret_token.sh
echo "Wrote GITHUB_AUTH_TOKEN to secret_token.sh"

else
    echo "GITHUB_AUTH_TOKEN is already set."
fi
