# mini http server demo



## Docker images build

~~~sh
DOCKER_BUILDKIT=0 docker build -f Dockerfile -t tekintian/myserver .
~~~


~~~sh
docker run --name myserver -itd -p 80:8080 tekintian/myserver
# and then visit 
# http://localhost/index
~~~

