---
title: "Nuke'em all! Using AWS Nuke to clean your AWS accounts"
url: "intro-to-aws-nuke"
date: 2025-07-13T18:20:13-04:00
tags: ["AWS"]
draft: false
---
![alt text](/img/aws-nuke.png)

## Introducing AWS Nuke!
In this post I will give you a quick introduction to [AWS Nuke](https://aws-nuke.ekristen.dev/), a tool developed in Golang that aims to delete all resources in an AWS account. This tool helped me a lot.

## Use Cases
### Cleaning Free Tier AWS Account
This was a personal use-case, I created a free tier AWS Account some months ago and I've been using it for different purposes, some of the resources I created were via Terraform which made it simpler to delete the resources I created after using them, on the other hand, I created other resources manually without tracking them, some of them were costing me money!. So I prefered to delete everything in this account as I use it for learning purposes only. AWS Nuke is a great fit for this task.

> **Note on new free plan accounts:** [AWS announced their new free tier plans](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/free-tier-plans.html), instead of giving you free usage of some services during the free tier period they give you accounts with 100 USD instead for six months which I personally think is better for new people coming to AWS, as the previous free tier didn't include some resources and using them costed money e.g. NAT Gateway. So still, if you don't want to burn your 100 USD quickly, AWS Nuke can help you!

### Cleaning Research Accounts
It is very common that some companies have accounts that are used for research, where engineers can try new services, proof of concepts, etc. Depending on how the resources were created it can be simple or not to remove and keep track of all of them. The good thing is that these research accounts are not supposed to have running production-infrastructure, hence deleting the resources to save some money is a perfect case for AWS Nuke as well.

> **Warning:** The two use cases for AWS Nuke I mentioned, consider temporal or ephemeral accounts only. It is important to note that using Infrastructure As Code tools or at least having a good tagging convention (so it is simple to identify which AWS resources exist) can prevent the need of this tool, which in my opinion is similar to using `kill -9` in Unix systems, i.e. use it as your last option.

## Using AWS Nuke
### Requirements
Before moving forward, make sure your AWS Account has an alias associated with it, it is a **MUST** have. For this, log into your account, go to the IAM service and in the right section there is an "Account" section where you can edit the alias.

![](/img/iam-account-alias.png)

Since this tool can be very destructive, it is important that you know what you are doing and mainly what you are about to delete. Anyway the tool runs in dry-run mode by default i.e. it will not apply any changes until you add a specific flag and add some extra confirms. Fortunately, you can be as specific as possible on what you want to delete. From specific resources of certain kind to all resources of one or multiple kinds.

Something I loved about how it is programmed, is that it will fail if the alias of you AWS account has the `prod` string in it, which in my opinion is a very important validation to prevent any execution by mistake.

For downloading and installing follow its [documentation page](https://aws-nuke.ekristen.dev/installation/). Once installed, you can continue with the next steps.

In addition to the tool, it is expected that you already have CLI access to AWS.

### Configuring your YAML file
AWS Nuke needs a configuration file where you can specifiy which accounts will be impacted, which resources will be included excluded, etc. This file is in YAML format.

In my case, what I wanted to do was to delete all resources in my AWS Account, except the default VPC, IAM User I used for admin, its access keys and MFA configuration.

This is the configuration file I used.

```yml
# aws-nuke-config.yml
regions:
- us-east-1 # only delete in us-east-1
- global

resource-types:
  excludes:
    # Some optimizations, for instance do not delete each S3 Object
    # or DynamoDBTable record, internally aws nuke will empty the bucket anyway
    - OSPackage
    - S3Object
    - DynamoDBTableItem
    # Keep for default VPC
    - EC2DefaultSecurityGroupRule
    # Do not remove IAM User and its dependencies
    - IAMUser
    - IAMLoginProfile
    - IAMUserAccessKey
    - IAMVirtualMFADevice
    - IAMUserPolicyAttachment

blocklist:
- "999999999999" # aws nuke always requires to have an account blocklist

accounts:
  "123456789777": # my account
    filters:
      # Exclude all resources that have the DefaultVPC or the IsDefault properties
      EC2DHCPOption:
      - property: DefaultVPC
        value: "true"
      EC2InternetGateway:
      - property: DefaultVPC
        value: "true"
      EC2InternetGatewayAttachment:
      - property: DefaultVPC
        value: "true"
      EC2RouteTable:
      - property: DefaultVPC
        value: "true"
      EC2Subnet:
      - property: DefaultVPC
        value: "true"
      EC2VPC:
      - property: IsDefault
        value: "true"
      # END: Filter all default VPC resources
```

## Executing AWS Nuke!
Executing is very simple, once AWS Nuke is installed you only need to run as follows in order to have a dry-run plan of what is about to be deleted.

```
$ aws-nuke nuke --config ./aws-nuke-config.yml
```

This will give a plan and as the screenshot, the records that are to be deleted have the `would be removed` string.

![aws nuke plan](/img/aws-nuke-plan.png)

### I encourage you to try it
Try removing or modifying your YAML configuration file and see what changes in the plan.

### The Last Step, Nuke'em All!
After you are happy with the deletion plan, you can run:

```sh
$ aws-nuke nuke --config ./aws-nuke-config.yml --no-dry-run-mode
```

Which will ask for your alias and confirm that you really want to delete the resources for that account.

## Final Thoughts
I hope you find this post useful. AWS Nuke helped me a lot with a personal account I use for learning purposes, so I can save some dollars. But never forget that this is a destructive tool, you **MUST** be very careful while using it.
