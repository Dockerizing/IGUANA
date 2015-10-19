# IGUANA Docker

Docker container for [IGUANA](https://github.com/AKSW/IGUANA), which is both a program and an API framework for benchmarking SPARQL Endpoints.

Please contact the IGUANA guys, if you have troubles with IGUANA itself, because we only provide the Docker container.

## Docker related

### Pull

To pull, just use:

`docker pull aksw/dld-present-iguana`

### Deploy

Execute this on your terminal to deploy the container:

`docker run -v /tmp/iguana-results:/iguana/results -ti aksw/dld-present-iguana:latest`

Using `-v` enables the usages of folders in the host. We use that here, to tell Docker to save IGUANAs results in a
certain folder. Replace `/tmp/iguana-results` with a different path, if necessary.

## Usage

To use it, just run it as stated above. You will be logged into it. Navigate to `/iguana/` and execute `./start.sh` to start a basic benchmark asking Dbpedia. If you want to adapt the configuration or query list, please have a look into `/iguana/config_test.xml` and `/iguana/queries.txt`.
