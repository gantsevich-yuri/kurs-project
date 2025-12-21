### Build, run, check and psuh currency value app image to Dockerhub

```
docker build -t currency:v1 .
docker run -d -p 5000:5000 currency:v1
docker ps -a
curl -I http://127.0.0.1:5000/

docker login
docker tag currency:v1 fox4kids/myrepo:currency
```