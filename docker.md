

Docker 使用 LXC 做出
LXC 是 linux 用來區隔

和 VMWare 不同，Docker 不需要模擬硬體環境

Docker 只能跑在 linux 上
docker 會在 linux 上切一個資料夾 再跑一個 linux
docker 其實是把一個資料夾視為硬碟，在這個資料夾內跑作業系統


在 mac 上面跑 Docker 他會在系統開一台虛擬機再開 Docker

docker import 壓縮檔
docker export 壓縮檔

scratch: docker 的最小單位

debootstrap：是一個 linux 的指令，可以指定一個資料夾生成一個 linux 所需要的所有檔案

docker commit：提供跟 git 差不多的功能，可以做到差異同步

docker push 帳號/名字:版本

docker pull 帳號/名字:版本

docker images：列出所有 docker 版本

docker image history 名字：列出所有這個 repostory 的版本經歷

docker tag：給一個 sha 名字

docker 的特性是 stateless，因為 stateless 所以可以 scale (跟FP的概念相同)

所以在設計 docker image 時，應該要保證內容只包含程式碼，而且不會在執行的過程中被變更。

設定檔可以全部以環境變數來設定，可以在執行 docker 時設定環境變數。

可以把設定檔中心化管理，確保自動 scale 是可行的。


在一個資料夾放 Dockerfile 作為設定檔
docker build .
可以建立一個 docker image


docker run -it "docker image 名稱" command
-t 將 docker image 內的 log 傳出來
-i 將本機的 鍵盤指令傳入 docker image
可以建立一個 docker container 然後執行 command

docker image 相當於類別，docker container 相當於實體物件

在執行 docker run 時，系統會從 docker image 建立一個資料夾，然後在這個資料夾上面跑 linux。

docker ps 可以列出所有實體

docker start 可以從現有的物件繼續作事。 

docker commit container名稱 這會把目前的 container 另存成 image。


bash 指令小知識

| pipe
> rewrite寫入
>> append寫入


# Dockerfile
Dockerfile 範例：
```
FROM ubuntu:16.04
```

Dockerfile 安裝 ruby：
```
FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install ruby -y

CMD ["ruby"]
```

Dockerfile ENTRYPOINT：
```
FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install ruby -y
RUN gem install rake
RUN mkdir -p /src/app

WORKDIR /src/app 
ADD Rakefile /src/app

ENTRYPOINT ["rake"]
```

mkdir -p 可以新增巢狀資料夾

ENTRYPOINT ["rake"] 會把 rake 字串加在 docker run 的 command 前面。

Dockerfile VOLUME：
```
FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install ruby -y
RUN gem install rake
RUN mkdir -p /src/app

WORKDIR /src/app 
ADD Rakefile /src/app
VOLUME ["/src/app/logs"]

ENTRYPOINT ["rake"]
```

指定資料夾要獨立硬碟

## docker cp
docker cp container名稱:路徑 本機路徑
可以從 docker container 中複製一個檔案到本機

## docker run --volumes-from
docker run --volumes-from container名稱

在執行一個 container 時載入另一個 container 的

## docker run -v
docker run -v 路徑

設定 docker container 開啟的 port
EXPOSE 3000

docker 

```
docker run -p 9292:3000
```

