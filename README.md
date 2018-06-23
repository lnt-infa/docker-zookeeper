# Apache Zookeeper  3.4.11 Docker image

# Build the image

If you'd like to try directly from the Dockerfile you can build the image as:

```
docker build  -t lnt-infa/zookeeper-docker:3.4.11 .
```
# Pull the image

The image is also released as an official Docker image from Docker's automated build repository - you can always pull or refer the image when launching containers.

```
docker pull lnt-infa/zookeeper-docker:3.4.11
```

# Start a container

In order to use the Docker image you have just build or pulled use:

```
docker run -it lnt-infa/zookeeper-docker:3.4.11 /etc/bootstrap.sh -bash
```

