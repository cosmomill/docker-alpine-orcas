Alpine Orcas (Oracle adaptive schemas) Docker image
===================================================

This image is based on Alpine GNU C library image ([cosmomill/alpine-gradle](https://hub.docker.com/r/cosmomill/alpine-gradle/)), which is only a 150MB image, and provides a docker image for [Orcas](http://opitzconsulting.github.io/orcas/) (Oracle adaptive schemas).

Prerequisites
-------------

If you want to build this image, you will need to download:
- [Oracle Instant Client for Linux x86-64 (12.2.0.1.0) - Basic Package](http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html)
- [Oracle Instant Client for Linux x86-64 (12.2.0.1.0) - SQL*Plus](http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html)
- [Oracle Instant Client for Linux x86-64 (12.2.0.1.0) - JDBC Supplement](http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html)
- [Oracle Application Express 5.1.1 - All languages](http://www.oracle.com/technetwork/developer-tools/apex/downloads/index.html)
- [Oracle Database 10g Release 2 (10.2.0.5) JDBC Drivers - classes12.jar](http://www.oracle.com/technetwork/apps-tech/jdbc-10201-088211.html)


Usage Example
-------------

This image is intended to be a base image for your projects, so you may use it like this:

```Dockerfile
FROM cosmomill/alpine-orcas
```

```sh
$ docker build -t my_app . --build-arg ORACLE_INSTANTCLIENT_FILE="instantclient-basic-linux.x64-12.2.0.1.0.zip" --build-arg ORACLE_SQLPLUS_FILE="instantclient-sqlplus-linux.x64-12.2.0.1.0.zip" --build-arg ORACLE_JDBC_FILE="instantclient-jdbc-linux.x64-12.2.0.1.0.zip" --build-arg ORACLE_JDBC12_FILE="classes12.jar" --build-arg APEX_FILE="apex_5.1.1.zip"
```

```sh
$ docker run -d -P -v orcas_home:/home -e DATABASE_HOSTNAME="db" -e SCHEMA="SCOTT" -e SCHEMA_USERNAME="SCOTT" -e SCHEMA_PASSWORD="TIGER" my_app
```

Database Schema files
---------------------

The target state will be stored in separate SQL files in ```/home/orcas/<schema>/db``` which are based on the CREATE / ALTER TABLE syntax.
