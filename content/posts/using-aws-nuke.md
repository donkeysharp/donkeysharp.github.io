---
title: "Nuke em all! Using AWS Nuke to clean your AWS accounts"
url: "intro-to-aws-nuke"
date: 2024-08-13T18:20:13-04:00
draft: true
---

## Introducing AWS Nuke!
In this post I will give you a quick introduction to [AWS Nuke](https://github.com/rebuy-de/aws-nuke), a cool project developed in Golang that aims to delete all resources in an AWS account.

## Use Cases
### Cleaning Free Tier AWS Account
This was my case, I created a free tier AWS Account some months ago and I've been using it for different purposes, some of the resources I created were via Terraform which made it simpler to delete the resources I created after using them, on the other hand I created other resources manually without tracking them, some of them were costing me money!. So I prefered to delete everything in this account as I use it for learning purposes only, AWS Nuke was a great fit for this task.

### Cleaning Research Accounts
It is very common that some companies have accounts that are used for research, where engineers can try new services, proof of concepts, etc. Depending on how the resources were created it can be simple or not to remove and keep track of all of them. The good thing is these research accounts are not supposed to have running production-infrastructure, hence deleting the resources to save some money is a perfect case for AWS Nuke.

> **Warning:** The two use cases for AWS Nuke I mentioned, consider temporal or ephemeral accounts only. It is important to note that using Infrastructure As Code tools or at least having a good tagging convention (so it is simple to identify which AWS resources exist) can prevent the need of this tool, which in my opinion is similar to using `kill -9` in Unix systems, i.e. use it as your last option.

## Using AWS Nuke
Before moving forward, make sure your AWS Account has an alias associated with it, it is a **must** have. For this log in to your account, go to the IAM service and in the right section there is an "Account" section where you can edit the alias.

<!-- Add image of this part -->

Since this tool can be very destructive, it is important that you know what you are doing and mainly what you are about to delete. Anyway the tool runs in dry-run mode by default i.e. it will not apply any changes until you add a specific flag and add some extra confirms. Fortunately you can be as specific as possible on what you want to delete, between specific resources of a kind or all resources of one or multiple kinds.

Something I loved about how it is programmed, is that it will fail if the alias of you AWS account has the `prod` string in it, which in my opinion is a very important validation to prevent any execution by mistake.

For downloading and installing follow its [documentation page](https://github.com/rebuy-de/aws-nuke/tree/main?tab=readme-ov-file#install). Once installed, you can continue with the next steps.

### Configuring your YAML file
AWS Nuke needs a configuration file where you can specifiy which accounts will be impacted, which resources will be included excluded, etc. This file is in YAML format.

At least for me the documentation was not very clear on the format of this configuration file, although it has [some examples](link to examples), there are some things I needed to google to have it the way I want it.

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

account-blocklist:
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
$ aws-nuke --config ./aws-nuke-config.yml
```

This will give a plan and as the screenshot, the records that are to be deleted have the `would be removed` string.

### I encourage you to play
Try removing or modifying your YAML configuration file and see what changes in the plan

### The Laste Step, Nuke'em All!
After you are happy with the deletion plan, you can run
```
$ aws-nuke --config ./aws-nuke-config.yml --no-dry-run-mode
```
Which will ask your alias and confirm that you really want to delete the resources

## Final Thoughts
I hope you find this post useful, in my case it was used
<!-- Add the steps to execute with some flags --include --exclude etc -->
