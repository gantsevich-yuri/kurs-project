### Build, run and check currency value app image

```
docker build -t currency:v1 .
docker run -d -p 5000:5000 currency:v1
docker ps -a
curl -I http://127.0.0.1:5000/
```