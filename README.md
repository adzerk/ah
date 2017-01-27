# ah

Deployment automation tool.

## Install

`Ah` requires the following packages:

1. GNU coreutils
1. GNU make
1. git
1. AWS command line tool

To install in `/usr/local` do:

```bash
sudo make install
```

To install in a different location:

```bash
sudo make PREFIX=/foo/bar install
```

## Getting Help

[The `ah` manual][manpage] contains complete descriptions of the various
commands and features of the program:

```bash
man ah
```

## Getting Started

The following sections will take you thorough some basic setup and create a
new `ah` application and environments.

### Create the Master Bucket

The first thing to do after installing the program is to create a S3 bucket
for `ah` to store things. You only need to do this once.

> **Note:** you want to make sure this bucket is only accessible by users who
> will be authorized to manage and deploy `ah` applications.

After the bucket is created add an environment variable to your shell:

```bash
export AH_BUCKET=your-bucket-name
```

### Create a Default Org

"Orgs" contain basic settings that span multiple applications. They are used
as templates to configure default values at the application and environment
levels. You can create as many orgs as you like, but you need at least one.

```bash
ah putorg default
```

You will be asked a number of questions:

* **AWS region** &mdash; the AWS region (eg. `us-east-1`).
* **SGs for default ingress rules** &mdash; these security groups will be added
  as ingress rules allowing full access to instances in ASGs created by `ah`.
  Multiple SGs can be separated by spaces or commas, eg. `sg-a0a1c9b7,sg-a0a1c9b8`
  or `sg-a0a1c9b7 sg-a0a1c9b8`.
* **Availability zones** &mdash; availability zones in which ASGs created by
  `ah` will launch instances. Multiple AZs can be separated with spaces or
  commas, eg. `a,b,e` or `a b e`.

It's okay if you leave things blank or make a mistake, you can fix it later or
override the org settings when you create applications and environments.

> You can use `ah getorg default` to download the org settings, or `ah orgs`
> to see a list of org names.

### Create an Application

Applications represent some service that will run on instances in AWS. An `ah`
application must be associated with a git repository, and will contain settings
that will be used as default values for environments that are created for it.

#### Prepare the Git Repo

First create the new application's project directory. We'll name this one
`hello-ah`:

```bash
mkdir hello-ah && cd hello-ah
```

Here is a good start for a `.gitignore` file for `ah` application repos:

```
/.ah/env
/target/
```

Those two directories have special meaning to `ah`:

* `.ah` &mdash; this is where `ah` will store application configuration info.
  There won't be anything secret in there.
* `target` &mdash; this is where compiled artifacts will go if you will not be
  building your application on the instance. You can also put anything in here
  that you want to have shipped to instances but don't want to commit to your
  application's git repo.

And the project Makefile (every `ah` application must have a Makefile):

```make
.PHONY: provision deploy

provision:
    echo "i am an instance, and i am being provisioned now"

deploy:
    echo "i am an instance, and i am being deployed to now"
```

This Makefile comprises the minimum viable `ah` application. `Ah` expects the
following targets to be defined:

* `provision` &mdash; used to configure newly launched instances (install
  software, configure operating system). This target is run on new instances
  launched in an ASG automatically by the ASGs launch configuration user data
  script.
* `deploy` &mdash; used to prepare the application for service, start or
  restart it, and do any other things that might need to be done to get it
  going and fully operational. This target is run automatically (after the
  `provision` task) on new instances launched in an ASG. Also run when
  performing a "hot deploy" to an existing instance via `ah-client deploy`.

Now that we have a workable `ah` application let's commit our code to git:

```bash
git init && git add . && git commit -m "first commit ever"
```

#### Initialize the `Ah` Application

The `init` command configures some application defaults and allocates the AWS
resources that are shared by all of the environments for this application:

```bash
ah init
```

Again, there will be questions. This time they are mostly related to tags that
will be created on AWS resources associated with the application:

* **App name** &mdash; recommend something alphanumeric, plus dashes and/or
  underscores. Resources will be tagged with `AhApplication` set to this.
* **Billing group** &mdash; resources will be tagged with `BillingGroup` set
  to this.
* **Billing project** &mdash; resources will be tagged with `BillingProject`
  set to this.

The application name is the only really important information, so make sure you
at least fill that one in properly.

#### Push a Version to `Ah` S3 Bucket

In order to deploy this application to instances on AWS we must push the
desired commit to `ah`'s S3 bucket:

```bash
ah push
```

This will upload a tarball of `HEAD` &mdash; you can configure `ah` ASGs to
deploy this SHA to instances later.

> **Note:** you can use `ah shas` to see which commits have been pushed to S3.

### Create an Environment

[manpage]: http://htmlpreview.github.io/?https://raw.githubusercontent.com/adzerk/ah/master/doc/ah.1.html
