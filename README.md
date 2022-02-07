> _This repo is a docker-compose stack to run the core services for idea-fast WP3._

## Global setup

There are a couple of services defined here:

- [core](./core) is the reverse proxy using [traefik](https://doc.traefik.io/traefik/).
- [instances](./instances) are the instances of services we run.

The stack relies on three manually created docker networks. Check if these already exist, and, if not, create them:

```shell
docker network list

docker network create web
docker network create database
docker network create ideafast-etl
```

## Local deployment/development

1. **Do not setup the TLS certification** as indicated below.
1. Disable HTTP/S redirects and SSL by temporarily commenting the [associated Traefik config](https://github.com/ideafast/stack/blob/master/core/traefik.toml#L5-L10) in the [core/traefik.toml](core/traefik.toml) file on lines 5 - 10.
1. _For each individual service you want to test_:
    1. Update Traefik hosts labels to your local host in the `docker-compose.yml` files . For example, for the api, change `api.wp3.ideafast.eu` to `api.localhost`.
    1. Comment out the Traefik `tls` and `entrypoint` labels: 
        - `entrypoints=websecure`, 
        - `tls=true`, and 
        - `tls.certresolver=leresolver`.

Spin up the reverse proxy and the service you want to test from their respective directories (as indicated below)

### Reverse-proxy

To setup [Treafik](https://doc.traefik.io/traefik/) for the reverse proxy, we need to enable TLS certification (via [Let's Encrypt](https://letsencrypt.org/)) to serve over HTTP**S**. Navigate to the [core](/core) directory, create a `acme.json` file with proper access permissions:

```shell
cd core 
touch acme.json
chmod 600 acme.json
```

At this stage, the [supportdocs](/supportdocs) website uses basic authentication with a `usersfile` in the core directory. Differently, the [api](/api) uses environmental variables to handle this. Either way, until the support documentation website is deprecated, we need to create a `usersfile` and add usernames and password for access. In the [core](/core) directory, create a `usersfile` document, and add usernames and passwords (see how to create these on [the Treafik documentation](https://docs.traefik.io/middlewares/basicauth/)): 

```shell
touch usersfile
nano usersfile # or vim, or something else
# add username:passwords, save, and exit
```

Finally, spin up the reverse proxy:

```shell
docker-compose up -d
```

### Submodules and dependencies

The [IDEAFAST/ETL pipeline](https://github.com/ideafast/ideafast-etl) is used as a submodule to simplify working with their compose file. When you first download the repo the `/instances/pipeline/ideafast_etl` folder will be empty and you'll need to initialise it:

```shell
git submodule update --init --recursive
```

Updating submodules can be done by entering the following command. **Note, however,** that this _does not_ merges the update (i.e., the reference to a specific commit of the submodule) into the current directory. You can add `--merge` to this command, but unless you update this `stack` git repository, this will start to diverge. Alternatively, use the `--merge` parameter and push the changes to the repository, or execute this command on your local machine, push changes and pull down the overall `ideafast/stack` repository to achieve the same result.

```shell
git submodule update --remote # --merge
```

## Deploying and updating services

Each instance slightly differs in the setup due to the dependency on an image, submodule or environmental variables. Please see instructions how to start and update each service below:

**For each service**, navigate (`cd`) into the directory and follow the steps below

### WP3-API

To setup the service, the service needs some environmental variables to be set, and an `ssh` key to acces the private documentation repository.

- Get the `ssh` keys onto the server (using, for example `scp`), as outlined in the [ideafast/wp3-api](https://github.com/ideafast/wp3-api) README.
- copy the example file and fill in the environmental variables
  ```shell
  cp .env.example .env
  # fill in the environmental variables in the created .env file
  ```
- spin up the container
  ```shell
  docker-compose up -d
  ```

#### Updating

To get the latest updates to the [ideafast/wp3-api](https://github.com/ideafast/wp3-api) on the server:
- in your local [ideafast/wp3-api](https://github.com/ideafast/wp3-api) repository, build a docker image and push to docker hub
  ```
  poetry run bump -b patch # or minor, or major
  poetry run build
  poetry run publish
  ```
- then, in this repository, navigate to the [instances/api](instances/api) directory, pull down the latest image and restart the container
  ```shell
  docker pull ideafast/wp3-api
  docker-compose up -d
  ```

### Study Dashboard

At this point, the study dashboard is a simple HTML placeholder. Deploy it by running"

```shell
docker-compose up -d
```

### Inventory

> Once the FS finishes, the inventory will be deprecated. 

Set up can be achieved as follows _(instructions taken from prior documentation)_:

```
cp .snipeit.env.example .snipeit.env
docker-compose up -d
```
Once the service is running, enter the container, create an artisan key:
```
docker exec -it snipeit sh
php artisan key:generate
```
Copy this value , store this in the `.snipeit.env` and restart the container:
```
docker-compose up -d
```

### Middleware

> Once the FS finishes, the middleware will be deprecated. 

Duplicate the environmental variable files and fill in as appropriate
```
cp .consumer.env.example .consumer.live.env
cp .dtransfer.env.example .dtransfer.live.env
```
Spin up the service
```
docker-compose up -d
```
The MongoDB requires some slight configuration if spun up the first time. See the [intances/middleware/README](intances/middleware/README.md) for more details.

### ETL Pipeline

The ETL Pipeline uses [ideafast/ideafast-etl](https://github.com/ideafast/ideafast-etl) as a submodule, particularly due to its depdency on Python scripts that are _not_ exported into the docker image. First, we need to set some required environmental variables and initial values for the pipeline. Copy the (nested) example files and fill appropriately:

```shell
cp .env.example .env
cp /init/connections.yaml.example /init/connections.yaml
cp /init/variables.json.example /init/variables.json
```

The `docker-compose.yaml` file inside the submodule sets up the pipeline for us, though we need to alter some (network) settings slightly, for which we have an additional docker-compose.yaml file to override these. Spin up the service with:

```shell
docker-compose -f ideafast_etl/docker-compose.yaml --env-file .env -f docker-compose.yaml up -d
```
As we explicitely indicate the file to use (with the `-f` parameter), _shutting down_ the services requires the same:
```shell
docker-compose -f ideafast_etl/docker-compose.yaml --env-file .env -f docker-compose.yaml down
```

#### Updating

If you want to update any environmental variables, connections or variables (as in the /init folder), simply apply the changes and run the same docker command as above. If you want to pull in changes to the Python scripts made in the [ideafast/ideafast-etl](https://github.com/ideafast/ideafast-etl), run:

```shell
git submodule update --remote
```

### Support Documentation

> Once the FS finishes, the support system will be deprecated. 

Set up can be achieved as follows _(instructions taken from prior documentation)_:

```
git clone git@github.com:ideafast/ideafast-devicesupportdocs-web.git docs
chmod 755 jekyll-build.sh && ./jekyll-build.sh
docker-compose up -d
```

### Surveys

```
docker-compose up -d
```