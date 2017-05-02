ah(1) -- simple, service oriented management of AWS resources
=============================================================

## SYNOPSIS

`ah` <command> [<OPTIONS>...]

## DESCRIPTION

**Ah** is a tool for managing the infrastructure resources associated with
services hosted on Amazon Web Services (AWS).

## COMMANDS

Commands are organized by scope: global, application, and environment.

### Global Commands

These commands are not specific to any application. They may be executed from
any directory.

  * `orgs`:
    Print a listing of existing org names.

  * `getorg` <org>:
    Print the config settings associated with <org>.

  * `putorg` <org>:
    Create or update the org named <org>, starting with a copy of <template> if
    provided. Input may be provided interactively from the terminal or via
    <stdin>. See **FIlES** below for a description of the expected format.

  * `rmorg` <org>:
    Deletes the org named <org>.

  * `upgrade`:
    Update static `ah` bootstrapping files on S3. Needed when `ah` itself is
    updated to a new version.

  * `putsecret` <secret>:
    Create or update the S3 secret file for the variable <secret>. The value is
    read from <stdin>. **NOTE: the value must be explicitly quoted if it
    contains spaces, newlines, etc.**

  * `rmsecret` <secret>:
    Delete the S3 secret file for the variable <secret>.

  * `grants` [`-u`]:
    Print the table of S3 secret variable and **ah** environment names for all
    environments that have been granted access to S3 secret variable files. The
    `-u` option updates the grants index for the current environment (should
    not be necessary unless the index has somehow gotten out of sync with the
    secrets granted).

### Application Commands

These commands operate at the application level and must be executed from an
application git directory. The `init` command must be executed to initialize
the application before any other application or environment scope commands
are attempted.

  * `init`:
    Configure a new application and create associated AWS resources. Input may
    be provided interactively from the terminal or via <stdin>. See **FILES**
    below for a description of the expected format.

  * `region` [<region>]:
    Set the default AWS region to <region> if <region> is specified, or print
    the current default region name.

  * `push`:
    Push the `HEAD` of the current application git repo and the contents of
    the target directory to S3.

  * `shas`:
    Print the list of SHAs that have been uploaded via the `push` command for
    the current application.

  * `envs` [`-a`]:
    Print the list of environments associated with the current application. If
    the `-a` option is provided print the table of **ah** application and
    environment names for all environments.

  * `status`:
    Print status info for instances associated with this application.

### Environment Commands

These commands operate at the environment level and must be executed from the
application git directory. The `env` command must be used to set the current
environment before any other environment scope commands are attempted.

  * `env` [<env>]:
    Set the default environment to <env> if <env> is specified, or print the
    current environment name.

  * `putvars`:
    Update the current environment's application config variables, read from
    <stdin>. See **FILES** below for a description of the expected format.

  * `getvars`:
    Print the application config variables stored for the current environment
    by the last `putvar`.

  * `putsha` [<rev>]:
    Set the configured deploy SHA for the current environment to the SHA
    associated with git revision <rev> (or `HEAD` if not provided). See the
    `SPECIFYING REVISIONS` section of the `git-rev-parse`(1) manual for details.

  * `getsha`:
    Print the currently configured deploy SHA for the current environment.

  * `launch`:
    Interactive command to create AWS resources for a new environment.

  * `terminate`:
    Destroy all AWS resources associated with the current environment. Only
    resources managed by `ah` will be affected.

  * `secrets` [`-a`]:
    Print all S3 secrets to which the current environment has access, or if
    the `-a` option is specified print all secrets to which the current user
    has access. See **FILES** below for a description of the output format.

  * `grant` <secret>:
    Grant permission for the current environment's instances to access the S3
    secret file for the variable <secret>.

  * `revoke` <secret>:
    Revoke permission for the current environment's instances to access the S3
    secret file for the variable <secret>.

## ENVIRONMENT

The following environment variables must be set before using `ah`:

  * `AH_BUCKET`:
    The name of the S3 bucket allocated for use by `ah`. This bucket must be
    created before using `ah`.

## CONFIG

  * `ah` will source `$HOME/.ah/config`. This is used to set ah environment
    variables and extend the functionality of ah.
  * A convenience function `ah_load_extension repo ref` is provided. This will
    install ah extensions from the specified repo at the specified revision to
    `$HOME/.ah/extensions`. For example:
    `ah_load_extension git@github.com:yourorg/cool-ah-extensions 2.0`

## FILES

The following configuration files are used to configure the `ah` environment.
The format of these files is one <NAME>=<value> pair per line, suitable for
eval by the `bash`(1) shell.

  * <$APPDIR>`/.ah/ah.conf`:
    This file contains the application configuration, as set by the `init`
    command. Settings in this file only apply to this application. This file
    **must** be committed to the git repository for the application.

  * <$APPDIR>`/.ah/env`:
    This file contains the name of the current default environment, as set by
    the `env` command.

  * <$APPDIR>`/.ah/region`:
    This file contains the name of the current default AWS region, as set by
    the `region` command.

## COPYRIGHT

Copyright &copy; 2017 Adzerk `<engineering@adzerk.com>`, distributed under the
Eclipse Public License, version 1.0. This is  free  software: you  are free to
change and redistribute it. There is NO WARRANTY, to the extent permitted by
law.

## SEE ALSO

`ah`(8), `aws`(1), `git`(1)
