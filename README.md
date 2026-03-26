# Usage examples

Build the image first:
`$ docker build -t docker_isg:latest .`

Example on how to run the image:
```
$ docker run -it \
    --env ICONIK_URL="https://app.iconik.io/" \
    --env AUTH_TOKEN="my_auth_token" \
    --env APP_ID="my_app_id" \
    --env STORAGE_ID="my_storage_id" \
    --env REDLINE_ARGS="--useMeta" \
    -v /mnt/my_nas:/mnt/mynas \
    -v /home/my_user/isg_local_data:/var/iconik/iconik_storage_gateway/data \
    docker_isg:latest
```

you could also use external `config.ini` instead:
```
docker run -it \
    -v /mnt/my_nas:/mnt/mynas \
    -v /home/my_user/isg_local_data:/var/iconik/iconik_storage_gateway/data \
    -v /home/my_user/isg_custom_config:/my_isg_config \
    docker_isg:latest iconik_storage_gateway --config=/my_isg_config/config.ini
```

`/home/my_user/isg_local_data` - custom preferred location on host
for the ISG local database. It is important to mount it as an external
volume in order to make local database persistent.

## Updating the iconik version

When a new version of iconik Storage Gateway is released, a new Docker image needs to be built and pushed to Docker Hub. The `apt-get install -y iconik-storage-gateway` in the Dockerfile installs the latest available version automatically, so no Dockerfile changes are needed unless the base OS needs upgrading.

### Requirements
- A Linux **AMD64** machine for building (Apple Silicon Macs cause emulation issues with this image).
- Docker installed and logged in to Docker Hub with access to the `xpresshd` account.

### Steps

**1. Build the new image**

Tag it with the next version number following the existing convention (e.g. `1_11`, `1_12`):

```bash
docker login
docker build -t xpresshd/iconik-storage-gateway-docker-with-redline:1_XX .
docker push xpresshd/iconik-storage-gateway-docker-with-redline:1_XX
```

**2. Update the compose file on the server**

SSH into the server and edit the compose file:

```bash
ssh root@office-server
vim /mnt/app-pool-1/office-server-compose/services/iconik-storage-gateway/docker-compose.yml
```

Change the image tag to the new version, e.g.  

`image: xpresshd/iconik-storage-gateway-docker-with-redline:1_XX`  

then run docker compose from location `/mnt/app-pool-1/office-server-compose`:

```bash
cd /mnt/app-pool-1/office-server-compose
docker compose pull iconik-storage-gateway
docker compose up -d iconik-storage-gateway
```

**3. Verify**

- Check the container is running: `docker ps | grep iconik`
- Check logs look clean: `docker logs office-iconik-storage-gateway-1`
- Go to https://app.iconik.io/ -> Admin → Storages -> `office-truenas` and confirm the ISG Version and Scanner Status show as Active and the new version is reflected.

### Rollback

If there are issues with the new image, revert the compose file to the previous tag and run docker compose:

`vim /mnt/app-pool-1/office-server-compose/services/iconik-storage-gateway/docker-compose.yml`

set previous version

`image: xpresshd/iconik-storage-gateway-docker-with-redline:1_XX` 

and

```bash
cd /mnt/app-pool-1/office-server-compose
docker compose up -d iconik-storage-gateway
```

### Notes

- **Docker Hub**: Images are stored at https://hub.docker.com/r/xpresshd/iconik-storage-gateway-docker-with-redline