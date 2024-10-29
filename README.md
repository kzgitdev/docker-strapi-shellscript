# create and compose docker container of Strapi

## description
generate-env.sh shell script is to auto generate following files and directory.
- .env  
- strapi.dockerfile  
- docker-compose.yml  
- src/ ... empty dirctory

## build container and boot it up
1. step1  set to execute permission  
```chmod +x ./generate-env.sh```

2. step2: run the generate-env.sh  
```./generate-env.sh```

3. step3: access the admin page  
http://localhost:1337/admin
