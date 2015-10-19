# IGUANA Docker

Docker container for [IGUANA](https://github.com/AKSW/IGUANA), which is both a program and an API framework for benchmarking SPARQL Endpoints.

### Build

To build the container execute:

`docker build -t iguana .`

### Deploy

Execute this on your terminal to deploy the container:

`docker run -v /tmp/iguana-results:/iguana/results -ti iguana:latest /bin/bash`

Using `-v` enables the usages of folders in the host. We use that here, to tell Docker to save IGUANAs results in a
certain folder. Replace `/tmp/iguana-results` with a different path, if necessary.
