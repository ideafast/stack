> This repo is a docker-compose stack to run the core services for idea-fast WP3.

There are a couple of services defined here:

- [core](./core) is the base services, e.g. reverse proxy.
- [instances](./instances) are the instances of services we run, e.g. zammad.

```
docker network create web

cd core

docker-compose up -d

cd ../instances

docker-compose -f ./zammad/docker-compose.yml  -f docker-compose.yml up -d
```

### Notes

- A reverse proxy is used to override `zammad-nginx` to expose the zammad
  servers to traefik. See the [docker-compose.yml](./instances/docker-compose.yml).
- A `.env` inside `/instances/zammad` overrides zammads default settings.
