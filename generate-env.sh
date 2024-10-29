# I use Alpine Linux docker image
#   node:20.17.0-alpine3.20 / OS: Apline Linux 3.20.3 / node:1000:1000:sh / npm 10.8.2 / yarn 1.22.22
USERID=$(id -u)
GROUPID=$(id -g)
STRAPI_PORT=1337

cat <<EOF > .env
# generated_at: $(date +%Y/%m/%d) $(date +%H:%M:%S)
# generated by generate-env.sh
USERID=${USERID}
GROUPID=${GROUPID}
EOF

# create Dockerfile: strapi.dockerfile
cat <<EOF > strapi.dockerfile
# syntax=docker/dockerfile:1
# generated_at: $(date +%Y/%m/%d) $(date +%H:%M:%S)
# generated by generate-env.sh
FROM node:20.17.0-alpine3.20 AS build

# install packages
#   shadow: to use usermod, groupmod
#   bash: bash(Alpine Linux default shell: sh)
RUN apk upgrade --update-cache && \
    apk add openssl bash shadow git && \
    rm -rf /var/cache/apk/*

WORKDIR /src

RUN groupmod -g ${USERID} node && \
    usermod -u ${GROUPID} node && \
    chown -R node:node /src

USER node
EOF

# create docker-compose.yml
cat <<EOF > docker-compose.yml
# generated_at: $(date +%Y/%m/%d) $(date +%H:%M:%S)
# generated by generate-env.sh
services:
  strapi-app:
    image: strapi-app:latest
    container_name: strapi-app
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
      - ./strapi-data:/src
    ports:
      - "${STRAPI_PORT}:1337"
    command: "npm run develop --port 1337"
    stdin_open: true
    tty: true

  astro-app:
    image: astro-app:latest
    container_name: astro-app
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
      - ./astro-data:/src
    ports:
      - "80:3000"
    command: "npm run dev -- --host 0.0.0.0 --port 3000"
    stdin_open: true
    tty: true
EOF

# create docker image: strapi-app:latest from strapi.dockerfile
#   execute docker build command
echho "-----"
echo "create strapi-app:latest docker image ...."
docker build --no-cache -t strapi-app:latest -f strapi.dockerfile .

STRAPI_DATA="./strapi-data"
if [ ! -e ${STRAPI_DATA} ]; then
    mkdir ./${STRAPI_DATA}
    echo "-----"
    echo "./${STRAPI_DATA} directory is created."
else
    echo "-----"
    echo "./${STRAPI_DATA} directory arleady existed."
    echo "if ./${STRAPI_DATA} is not empty, back up ./${STRAPI_DATA} and create ./${STRAPI_DATA} empty directory"
fi
docker image ls | grep strapi

# execute docker compose command to install strapi
echo "-----"
echo "install strapi for docker container in ./strapi-data directory."
docker compose run --rm strapi-app npx create-strapi@latest /src --no-run

# create docker image: astro-app:latest from astro.dockerfile
#   execute docker build command
echo "-----"
echo "create astro-app:latest docker image ...."
docker build --no-cache -t astro-app:latest -f astro.dockerfile .

STRAPI_DATA="./astro-data"
if [ ! -e ${ASTRO_DATA} ]; then
    mkdir ./${ASTRO_DATA}
    echo "-----"
    echo "./${ASTRO_DATA} directory is created."
else
    echo "-----"
    echo "./${ASTRO_DATA} directory arleady existed."
    echo "if ./${ASTRO_DATA} is not empty, back up ./${ASTRO_DATA} and create ./${ASTRO_DATA} empty directory"
fi
docker image ls | grep astro

# execute docker compose command to install strapi
echo "-----"
echo "install astro for docker container in ./astro-data directory."
docker compose run --rm atro-app npx create-strapi@latest /src

# execute docker compose command to boot up strapi-app container
echo "-----"
echo "Hey! execute to boot up strapi-app container"
docker compose up -d
docker compose ps -a
echo ""
echo "Successfully! Script is installed!"
echo "access to admin login: http://localhost:${STRAPI_PORT}/admin / http://localhost:${STRAPI_PORT}"
echo ""
echo "Successfully! astro is installed!"
echo "access http://localhost"
