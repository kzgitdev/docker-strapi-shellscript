# I use Alpine Linux docker image
#   node:20.17.0-alpine3.20 / OS: Apline Linux 3.20.3 / node:1000:1000:sh / npm 10.8.2 / yarn 1.22.22
USERID=$(id -u)
GROUPID=$(id -g)

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
      - ./src:/src
    ports:
      - "80:1337"
    command: "npm run develop --port 1337"
    stdin_open: true
    tty: true
EOF

# create docker image: strapi-app:latest from strapi.dockerfile
#   execute docker build command
echho "-----"
echo "create strapi:latest docker image ...."
docker build --no-cache -t strapi-app:latest -f strapi.dockerfile .

if [ ! -e ./src ]; then
    mkdir ./src
    echo "-----"
    echo "./src directory is created."
else
    echo "-----"
    echo "./src directory arleady existed."
    echo "if ./src is not empty, back up ./src and create ./src empty directory"
fi
docker image ls | grep strapi

# execute docker compose command to install strapi
echo "-----"
echo "install strapi for docker container in ./src directory."
docker compose run --rm strapi-app npx create-strapi@latest /src --no-run

# execute docker compose command to boot up strapi-app container
echo "-----"
echo "Hey! execute to boot up strapi-app container"
docker compose up -d
docker compose ps -a
echo ""
echo "Successfuly! Strapi is installed!"
echo "access to admin login: http://localhost/admin / http://localhost"
