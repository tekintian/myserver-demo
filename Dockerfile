# myserver server builder container
FROM golang:alpine3.15 as builder

# golang:alpine的默认GOPATH为/usr/src 所以设置为默认工作目录
WORKDIR /usr/src
# COPY docker-entrypoint.sh /docker-entrypoint.sh

# 设置go语言的环境变量
# 当CGO_ENABLED=1， 进行编译时， 会将文件中引用libc的库（比如常用的net包），以动态链接的方式生成目标文件。
# 当CGO_ENABLED=0， 进行编译时， 则会把在目标文件中未定义的符号（外部函数）一起链接到可执行文件中。
# GOARCH 编译架构()  GOOS目标版本: mac版  darwin ; linux版 linux ;  windows版 windows
ENV CGO_ENABLED=0 \
    GOARCH=amd64 \
    GOOS=linux

# 将本地项目文件加载到容器的/usr/src/myserver目录下
ADD ./ /usr/src/myserver
RUN sed -i -e 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apk/repositories; \
    apk update; \
    # 安装 wget 和 git 并设置默认git用户和邮箱(不设置的话,clone的时候可能会SSL error)
    # apk add --no-cache curl ca-certificates wget git ; \
    # git config --global user.name "AlpineBuilder"; \
    # git config --global user.email "builder@gmail.com" ; \
    # cd /usr/src; \
    # # 从git下周项目到容器
    # # git clone https://github.com/tekintian/myserver-demo.git; \
    cd /usr/src/myserver ;\
    # 初始化项目模块
    go mod init ; \
    # go build -v -ldflags "-s -w" -o /myserver ; \
    go build -v -a -installsuffix nocgo -ldflags="-s -w" -o /myserver ; \
    # 设置文件执行权限
    chmod +x /myserver

# myserver server run container
# build后的运行容器
# scratch为空docker容器
FROM scratch
# alpine容器3.8以上才支持amd64位程序, 运行容器尽量使用旧版本,体积相对较小
# FROM alpine:3.8

LABEL maintainer="tekintian@gmail.com"

WORKDIR /

# 命令解析 COPY --from={源容器} {源位置from}  {目标位置to}
COPY --from=builder /myserver /myserver
#COPY --from=builder /docker-entrypoint.sh /docker-entrypoint.sh

EXPOSE 8080
# 注意这里的底包使用的是 scratch (空容器)所以这里的入口就只能是 自己编译的这个程序了
ENTRYPOINT ["/myserver"]
# ENTRYPOINT ["/docker-entrypoint.sh"]
# CMD ["/myserver", "-g", "daemon off;"]