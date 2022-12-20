# Base Project Odoo

This is a template repository to standardize and simplify our odoo projects.

# Local Development Setup

To develop locally for this project, you need to prepare your local setup. To do this, you just need to do a few things:

1. [Login to ghcr.io if you haven't previously](https://github.com/blooparksystems/bloopark-ci/pkgs/container/bloopark-ci%2Fpy3.9-odoo15.0#how-to-use-odoo-enterprise-docker-images-hosted-on-ghcrio).
2. Set/Select venv in your IDE for your project
    - This is very important step. If your IDE already has virtual env setup then you can skip.
    - The best practice is to create individual venv for each project. But the choice is yours whether to use for each project or one for everything or nothing at all. In case of later, then make sure python command is alias of python3 (or python2) if your project requires it.
    - The advice is to use venv as you don't want to either overwrite your OS's packages or add project's packages to your OS.
    - Refer to https://code.visualstudio.com/docs/python/environments
3. <span style="color:darkorange;">Only for the project devops.</span> Update the environment variables (see the [environment section](#environment) for more details) in `dev/setup.sh` and .git-hooks as per the project needs
4. run the following command to prepare your dev tools
```bash
./dev/setup.sh <PROJECT_CODE> <ODOO_PORT>
```
PROJECT_CODE is used in some configurations such as naming the containers.
EG: PROJECT_CODE = lorem and ODOO_PORT = 8070
```bash
./dev/setup.sh lorem 8070
```
If you want interactive version of this command then use:
```bash
./dev/setup.sh -i
```
<i style="color:forestgreen;">It will ask you to input all the variables.</i>

This will create and run 3 containers:
 * odoo: odoo server running under http://localhost:8069
 * postgres: database server
 * pgadmin: database administration tool running under http://localhost:8099

After docker finish the initialization of the containers, you can open a browser and go to http://localhost:8069 to start using odoo

## Submodules
This project uses git submodules to handle dependencies and track third party repos. They are tracked inside `addons_repos_ext` directory and initialized as part of the setup procedure described before but in case you need to get changes on the submodules repos you can use the following command.
```bash
git submodule update --recursive
```
Follow this [doc](https://git-scm.com/book/en/v2/Git-Tools-Submodules) more info on submodule.

### Add any third party repos as follows:
Format for submodule code is:
```bash
git submodule add -b <branch> --depth 1 <git@yourprovider.com>:<username/repository.git> <path>
```

Let's see how you can add l10n-germany and its dependency repos from oca as submodules.

- Go to project root directory
```bash
git submodule add -b 14.0 --depth 1 git@github.com:OCA/l10n-germany.git external-repos/OCA/.l10n-germany
git submodule add -b 14.0 --depth 1 git@github.com:OCA/partner-contact.git external-repos/OCA/.partner-contact
```

### Use symlinks to only add modules you need
Let's add `l10n_de_country_states` module and its dependency to our external-addons folder.
```bash
cd addons_ext
ln -s ../external-repos/OCA/.l10n-germany/l10n_de_country_states ./l10n_de_country_states
ln -s ../external-repos/OCA/.partner-contact/base_country_state_translatable ./base_country_state_translatable
```
And now commit your changes.
```bash
git commit -a && git push -u <remote> <branch>
```

Replace
- `<remote>` by the repository on which you want to push your changes. For a standard Git setup, this is origin.
- `<branch>` by the branch on which you want to push your changes. Most likely the branch you used git checkout on in the first step.

### Ignore Modules
If you’re adding a repository that contains a lot of modules, you may want to ignore some of them in case there are any that are installed automatically. To do so, you can prefix your submodule folder with a `.`. The platform will ignore this folder and you can hand pick your modules by creating symlinks to them from another folder.

### Quick Note
Just to avoid any time wasting in a team who has different OSs. The symlinks created from either mac or linux system works in all but windows system. On the other hand, the symlinks created in windows system works only in itself.

## Database Access

To get direct access to the database content you can use the pgadmin tool with the following credentials

* url: http://localhost:8099
* user: dev@bloopark.de
* password: 1234

Once you have logged in, you will see the Odoo server, if you are prompt for the password, type odoo

## Environment

If you need to change any of the default configurations of the docker setup you can create a .env file in the root of the project and set the environment variables according to your needs.
* ODOO_PORT: to change the port where odoo will be running (default 8069)
* PGADMIN_PORT: to change the port where pgadmin will be running (default 8099)
* PROJECT_CODE: to define the string used to identify tickets of the project. This will be used to check git branches names and commit messages.
* DEV_BRANCH: used as default checkout branch. Set this variable especially if you want to use ./dev.sh
* INITIAL_ADDONS: will be installed by default when using ./dev.sh

Just remember to rebuild the containers after changes the environment variables, for the changes to take effect.

## Odoo configurations

You can change odoo configurations using the config file in config/odoo.conf.

## Accessing into the containers

Access into the pgadmin container if you want to import or export your configurations:

```bash
docker exec -it pgadmin sh
```

Access into the Odoo container:

```bash
docker exec -it odoo bash
```

### Pre-commit-config

#### Installation

```
$ pip install pre-commit
```

#### Using homebrew:
```
$ brew install pre-commit
```

```
$ pre-commit --version
pre-commit 2.10.0
```

#### Install the git hook scripts

```
$ pre-commit install
```

#### Run against all the files
```
pre-commit run --all-files
pre-commit run --show-diff-on-failure --color=always --all-files
```

#### Update package rev in pre-commit yaml
```bash
pre-commit autoupdate
pre-commit run --show-diff-on-failure --color=always --all-files
```
And then commit and make PR. Then merge to master-dev.

## Testing

To run unit tests of your code you can use the following command sequence:

```commandline
docker-compose up -d
docker-compose stop
```

And then, if you want to test your module in a clean database you can use:

```commandline
docker-compose run odoo --test-enable --stop-after-init -d new_database_name -i module_name
```

Otherwise, you can use the following:
```commandline
docker-compose run odoo --test-enable --stop-after-init -d database_name -u module_name
```

## Debugging
### PDB
To use pdb just run `docker exec <container_name> or <container_id>`.
For eg: `docker exec RONBA-odoo` or `docker exec 023113488`

### Visual Studio Code

If you are using Visual Studio Code you will be able to debug following this steps

1. Create a launch.json file with the following configuration
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Odoo: Attach",
            "type": "python",
            "request": "attach",
            "port": 8879,
            "debugServer": 8888,
            "host": "localhost",
            "pathMappings": [
                {
                    "localRoot": "${workspaceFolder}/addons_bp",
                    "remoteRoot": "/mnt/addons_bp", //path to custom addons inside docker
                },
                {
                    "localRoot": "${workspaceFolder}/addons_ext",
                    "remoteRoot": "/mnt/addons_ext", //path to external addons inside docker
                },
                {
                    "localRoot": "${workspaceFolder}/addons_enterprise",
                    "remoteRoot": "/mnt/enterprise", //path to enterprise addons inside docker
                }
            ],
            "logToFile": true
        }
    ]
}
```
2. Run docker with the following command sequence

```commandline
docker-compose up -d
docker-compose stop
docker-compose run --rm -p 8888:3001 -p 8069:8069 odoo /usr/bin/python3 -m debugpy --listen 0.0.0.0:3001 /usr/bin/odoo --db_user=odoo --db_host=db --db_password=odoo
```
You can use `./dev/debug.sh` instead of the above long command.
Example:
`./dev/debug.sh -d test -u sale`

3. Use the debug button in vscode
