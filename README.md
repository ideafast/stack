> This repo is a docker-compose stack to run the core services for idea-fast WP3.

There are a couple of services defined here:

- [core](./core) is the base services, e.g. reverse proxy.
- [instances](./instances) are the instances of services we run, e.g. zammad.


[Zammad](https://github.com/zammad/zammad-docker-compose) is used as a
submodule to simplify working with their compose file. When you first download
the repo the `/instances/zammad` folder will be empty and you'll need to
initialise it:

```
git submodule update --init --recursive
```

## Deploying Stack

```
docker network create web
docker network create database
docker network create ideafast-etl

# Starting core services: traefik, sql, etc.

cd core

# Prepare file for certification via letsencrypt

touch acme.json
chmod 600 acme.json

# Create usersfile (to create user/password, see https://docs.traefik.io/middlewares/basicauth/)

touch usersfile
vim usersfile

docker-compose up -d

# Start instances of services: zammad, snipeit, etc.

cd ../instances

# If no .env exists copy/edit zammad's as a base. see /instances/.env.example
cp zammad/.env .env

docker-compose -f ./zammad/docker-compose.yml  -f docker-compose.yml up -d

cd supportdocs/

git clone git@github.com:ideafast/ideafast-devicesupportdocs-web.git docs

chmod 755 jekyll-build.sh && ./jekyll-build.sh

docker-compose up -d

cd ../

cd surveys/

docker-compose up -d

cd ../

cd api/

docker-compose up -d

cd ../

cd inventory/

cp .snipeit.env.example .snipeit.env

docker pull snipe/snipe-it:v4.9.2

docker-compose up -d

docker exec -it snipeit sh

php artisan key:generate

# Replace APP_KEY in .env with outputted value

docker-compose up -d
```

## Support Docs Redeployment

The Support Docs are currently redeployed once a day using the crontab command from within the supportdocs folder
```
0 0 * * * ~/stack/instances/supportdocs/redeploy-docs.sh
```

## Deploying/Testing Locally

1. Disable HTTP/S redirects and SSL by temporarily [deleting the associated traefik config](https://github.com/ideafast/stack/blob/master/core/traefik.toml#L5-L10).
2. Update traefik hosts, e.g. from `inventory.ideafast.eu` to `inventory.localhost` [see here](https://github.com/ideafast/stack/blob/master/instances/docker-compose.yml#L19).

### Notes

- A reverse proxy is used to override `zammad-nginx` to expose the zammad
  servers to traefik. See the [docker-compose.yml](./instances/docker-compose.yml).
