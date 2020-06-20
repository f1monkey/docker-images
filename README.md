# RoadRunner-PHP
Docker image based on [php:7.4-cli-alpine](https://hub.docker.com/_/php?tab=tags&page=1&name=7.4-cli-alpine)
* Integrated [RoadRunner](https://roadrunner.dev/)
* Integrated [wait-for-it](https://github.com/vishnubob/wait-for-it) script

### Usage
* Install [RoadRunner](https://github.com/spiral/roadrunner) composer package
* Create `.rr.yaml` and `.rr.dev.yaml` in your project root (i.e. install [Roadrunner Bundle](https://github.com/Baldinof/roadrunner-bundle for Symfony and use its config files)

Basic `docker-compose.yml` example:
```yaml
services:
    php:
        image: cyradin/php-roadrunner:latest
        environment:
            DEV_MODE: 1 # 1 - start "dev" server which uses .rr.dev.yaml, 0 - start "prod" server
        restart: always
        volumes:
            - .:/srv:rw
```
`docker-compose.yml` example with wait-for-it:
```yaml
services:
    php:
        image: cyradin/php-roadrunner:latest
        environment:
            DEV_MODE: 1 # 1 - start "dev" server which uses .rr.dev.yaml, 0 - start "prod" server
            WAIT_FOR_HOST: postgres # url or docker container name to check for availability
            WAIT_FOR_PORT: 5432 # port to check for availability
            WAIT_FOR_TIMEOUT: 30 # Seconds to wait, default 30
        restart: always
        volumes:
            - .:/srv:rw
```