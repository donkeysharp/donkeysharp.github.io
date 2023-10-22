---
title: "Using Serverless Framework with AWS SSO"
url: "serverless-aws-sso"
date: 2023-10-22T17:51:02-04:00
draft: false
---

In this post, I will present a solution (one I personally find quite tidy) to a problem I encountered with AWS SSO and the Serverless Framework.

[Serverless Framework](https://www.serverless.com/framework/docs) is one of my favorite tools when I need to work with AWS Lambda and other serverless services, it is an alternative to [AWS SAM](https://aws.amazon.com/serverless/sam/), but personally, I prefer Serverless Framework due to its support for various cloud providers and plugins. Previously, I had used Serverless to access AWS API by configuring my `~/.aws/credentials` file. However this time I was using [AWS Single Sign-On](https://aws.amazon.com/what-is/sso/) to access AWS API from my local computer. Unfortunately, when I wanted to deploy some Lambda functions using the `sls` CLI, I was not able to do it, it shows a message saying the AWS profile I was using was not configured, even I logged in successfully a couple minutes ago.

```
$ export AWS_PROFILE='some-aws-sso-profile'
$ aws sso login
# Logs in successfully
$ sls deploy --stage dev
DOTENV: Loading environment variables from .env:
Deploying some-random-lambda to stage dev (us-east-1)

✖ Stack some-random-lambda failed to deploy (64s)
Environment: linux, node 18.16.0, framework 3.33.0 (local) 3.33.0v (global), plugin 6.2.3, SDK 4.3.2
Docs:        docs.serverless.com
Support:     forum.serverless.com
Bugs:        github.com/serverless/serverless/issues

Error:
AWS profile "some-aws-sso-profile" doesn't seem to be configured
```

So after some googling I discovered that Serverless [does not support](https://github.com/serverless/serverless/issues/7567) AWS SSO, it appears that `sls` expects the `~/.aws/credentials` file to be configured, but AWS SSO doesn't require storing credentials locally since it generates temporary credentials each time you log in.

I read that I can install a Serverless plugin named [Better Credentials](https://www.npmjs.com/package/serverless-better-credentials). However, I personally prefer to avoid installing and versioning a plugin that's only useful for local development.

## How AWS SSO store credentials
After you login successfully, an access token is stored in a JSON file located at `~/.aws/sso/cache`. Fortunately, this access token can be used to obtain the actual ACCESS KEY and ACCESS SECRET KEY, which can be used added to the `~/.aws/credentials` file, which is the one `sls` CLI expects to be configured.

The content of this JSON file looks like:

```
{"startUrl": "https://<some-id>.awsapps.com/start#/", "region": "us-east-1", "accessToken": "<an-access-token>", "expiresAt": "2023-10-20T05:58:17Z"}
```

Additionally, my `~/.aws/config` file includes the next SSO configuration:

```
[profile some-aws-sso-profile]
sso_start_url = https://<some-id>.awsapps.com/start#/
sso_region = us-east-1
sso_account_id = 123456789012
sso_role_name = MyRoleName
region = us-east-1
```

In order to retrieve the actual ACCESS KEY and ACCESS SECRET KEY execute the next command:

```
$ export SSO_TOKEN='token-from-the-json-file'
$ aws sso get-role-credentials --access-token $SSO_TOKEN --role-name MyRoleName --account-id 123456789012

{
    "roleCredentials": {
        "accessKeyId": "an-access-key",
        "secretAccessKey": "a-secret-access-key",
        "sessionToken": "a-session-token"
        "expiration": 1698038986000
    }
}
```

This information can be added to the `~/.aws/credentials` file using the same AWS profile name, which will make the `sls` CLI work as expected.

## Introducing `aws-sso-creds-helper` util
Although the solution previously mentioned will work, it involves several manual steps. Fortunately there is a utility that automates this process. It is a JS utility known as [aws-sso-creds-helper](https://www.npmjs.com/package/aws-sso-creds-helper).

```
$ npm install -g aws-sso-creds-helper
```

## Putting it all together
The final step is integrating all these elements. To make the entire solution work, all you need to do is execute the `ssocreds` command immediately after using AWS SSO login.

```
$ export AWS_PROFILE='some-aws-sso-profile'
$ aws sso login
# Logs in successfully
$ ssocreds -p $AWS_PROFILE
# Adds the temporal credentials to the ~/.aws/credentials file
$ sls deploy --stage dev
# It deploys successfully
```

## Final thoughts
Despite the introduction of an extra tool to work with AWS SSO, I find this solution to be elegant as it eliminates the need to modify or add extra dependencies to the project solely for local development purposes.
