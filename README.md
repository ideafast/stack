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

cd core

# If no .env exists copy/edit zammad's as a base. see /instances/.env.example
cp zammad/.env .env

docker-compose up -d

cd ../instances

docker-compose -f ./zammad/docker-compose.yml  -f docker-compose.yml up -d
```

### Notes

- A reverse proxy is used to override `zammad-nginx` to expose the zammad
  servers to traefik. See the [docker-compose.yml](./instances/docker-compose.yml).
