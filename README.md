# dev-containers

Dev-Containers is a repository that contains files and tools
for building and managing a development environment inside a
container (podman for the moment) for various programming languages
and software. Based on Arch Linux for its excellent package
manager and AUR repository.

The `Containerfile` with the details of what is installed
is found in `archdev-container` folder.

Set the `DEVUSER` environment variable to match with the host machine:

``` Dockerfile
ENV DEVUSER <user>  # Change <user>
```

### Manage Container (MC)

Helper script for managing the container(s):

``` bash
mc help
mc m s arch  # start the pod.
mc e arch    # enter the pod.
mc m p arch  # pause the pod.
mc mse arch  # start and then enter the pod.
```
