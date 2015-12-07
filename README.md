# IGUANA Docker

Docker container for [IGUANA](https://github.com/AKSW/IGUANA), which is both a program and an API framework for benchmarking SPARQL Endpoints.

Please contact the IGUANA guys, if you have troubles with IGUANA itself, because we only provide the Docker container.

## Usage

To pull, just use:

`docker pull aksw/dld-present-iguana`

To deploy the container and save the results of a basic benchmark asking Dbpedia use:

`docker run -e "STORE_1=uri=>http://dbpedia.org/sparql" -v $PWD/iguana-results:/iguana/results aksw/dld-present-iguana:latest`

With the `-e` parameter stores can be passed to the container.

The `-v` parameter gives a volume. You can change the local path `$PWD/iguana-results` if necessary.

## Configuration

You can add your own stores to test as `-e`-parameter or in a configuration file. The test-queries can only written into a queries file.

### Parameter

Stores can added as Docker environment variables from your command line with parameter `-e`. Each store must be a new `-e` and prefixed as STORE_X, while X is an incremented number, starting with 1. Example:

```
docker run -e "STORE_1=uri=>http://dbpedia.org/sparql" \
    -e "STORE_2=uri=>http://example.com/sparql" \
    aksw/dld-present-iguana
```

Beside the uri you can give a user and password. Example:

`docker run -e "STORE_1=uri=>http://localhost:8890/sparql user=>dba pwd=>dba" aksw/dld-present-iguana`

### Configurationfile

To use your own configuration or query file, please adopt the example files [config.xml](https://github.com/Dockerizing/IGUANA/blob/master/config.xml) and [queries.txt](https://github.com/Dockerizing/IGUANA/blob/master/queries.txt) and create a local copy.

The config.xml structure is basically:

```
<iguana>
    <databases>
    ..
    </databases>
    <suite>
    ...
    </suite>
</iguana>
```

To add a store, you have to add a database in section `<databases>`:

```
<database id="my_store" type="impl">
    <endpoint uri="http://example.com/sparql" />
    <user value="username" />
    <pwd value="password" />
</database>
```

This database-ID must be referenced at section `suite->test-db` as: `<db id="my_store" />`.

To pass your own configuration and/or query file, they must mounted to the Docker container as:

```
docker run -v $PWD/my_config.xml:/iguana/config.xml \
    -v $PWD/my_queries.txt:/iguana/queries.txt \
    aksw/dld-present-iguana:latest
```

change the local paths `$PWD/my_config.xml` and `$PWD/my_queries.txt` to your requirements.