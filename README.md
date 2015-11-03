# IGUANA Docker

Docker container for [IGUANA](https://github.com/AKSW/IGUANA), which is both a program and an API framework for benchmarking SPARQL Endpoints.

Please contact the IGUANA guys, if you have troubles with IGUANA itself, because we only provide the Docker container.

## Docker related

### Pull

To pull, just use:

`docker pull aksw/dld-present-iguana`

### Deploy

To deploy the container and save the results of a basic benchmark asking Dbpedia use:

`docker run -v $PWD/iguana-results:/iguana/results aksw/dld-present-iguana:latest`

You can change `$PWD/iguana-results` if necessary.

To use your own configuration and query file, please adopt the example files [config.xml](https://github.com/Dockerizing/IGUANA/blob/master/config.xml) and [queries.txt](https://github.com/Dockerizing/IGUANA/blob/master/queries.txt), create a local copy and mount these to the container:

```
docker run -v $PWD/iguana-results:/iguana/results -v $PWD/my_config.xml:/iguana/config.xml -v $PWD/my_queries.txt:/iguana/queries.txt aksw/dld-present-iguana:latest
```
