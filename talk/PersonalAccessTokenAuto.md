## Manually Create Personal Access tokens

You can manually check them out here https://github.com/settings/tokens and create a new one with "repo" scope. Save it somewhere because you can't get it again (but you can delete and recreate it).

### Automatically Create Personal Access tokens

The next few steps follows the API's instructions at http://developer.github.com/v3/oauth/ under the sections "Non-Web Application Flow" and "Create a new authorization" to become authorized.

Note: This uses Basic Auth once to create an token http://developer.github.com/v3/oauth/#oauth-authorizations-api

Set your GitHub userName as an environment variable. Change the below example from "replaceme" to your github account id:

    export GITHUB_USERID=replaceme

Ready? I recommend you copy your GitHub password so you can paste it when prompted:

    curl https://api.github.com/authorizations \
    --user "${GITHUB_USERID}" \
    --data '{"scopes":["repo"],"note":"Minikube-Jenkins-Demo"}'

This will prompt you for your GitHub password, which you can paste in.
If you have Multi-Factor Auth (aka MFA, 2FA, OTP) enabled, you will get this response:

```
{
  "message": "Must specify two-factor authentication OTP code.",
  "documentation_url": "https://developer.github.com/v3/auth#working-with-two-factor-authentication"
}
```

Then you have to send this header along (change 123456 to your OTP code):

    curl -H "X-GitHub-OTP: 123456" \
    https://api.github.com/authorizations \
    --user "${GITHUB_USERID}" \
    --data '{"scopes":["repo"],"note":"Minikube-Jenkins-Demo"}'


This will again prompt you for your GitHub password and now return your token in the response. It will also create a new Authorized application in your account settings https://github.com/settings/applications

The response should look something like this (some bits redacted):

```
{
  "id": 123456789,
  "url": "https://api.github.com/authorizations/123456789",
  "app": {
    "name": "Minikube-Jenkins-Demo",
    "url": "https://developer.github.com/v3/oauth_authorizations/",
    "client_id": "00000000000000000000"
  },
  "token": "1234567890123456789012345678901234567890",
  "hashed_token": "1234567890123456789012345678901234567890123456789012345678901234",
  "token_last_eight": "12345678",
  "note": "Minikube-Jenkins-Demo",
  "note_url": null,
  "created_at": "2018-05-18T18:01:44Z",
  "updated_at": "2018-05-18T18:01:44Z",
  "scopes": [
    "repo"
  ],
  "fingerprint": null
}
```

Save the "token" bit in an environment variable like this (yours will be different):

```
export GITHUB_AUTH_TOKEN=1234567890123456789012345678901234567890
```

Now that you have the token there are two ways to use the token to make requests that require authentication (replace "GITHUB_AUTH_TOKEN" with your actual token)

    curl https://api.github.com/user/repos?access_token=${GITHUB_AUTH_TOKEN}
    curl -H "Authorization: token ${GITHUB_AUTH_TOKEN}" https://api.github.com/user/repos

List the authorizations you already have:

    curl --user "${GITHUB_USERID}" https://api.github.com/authorizations
