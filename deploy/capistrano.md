# 安裝


# 環境設定

# config 同步

以下指令可以將本地的 config push 到遠端的 staging server 上：

```
cap staging config:push
#或
bundle exec cap staging config:push
```

這個指令可以將 config 中所有的 *.staging.yml 放到指定 server 上的 shared/config 資料夾中

你可以在 config/deploy.rb 中指定會用到的捷徑，比方說：
```
append :linked_files, "config/database.yml"
```

這樣一來，就會生成一個捷徑 `專案資料夾/config/database.yml` 指向 `shared/config/database.yml`。


當然也有反向的指令，把 server 上的檔案抓下來：

```
cap staging config:pull
#或
bundle exec cap staging config:pull
```

# 重開 server

```
cap staging passenger:restart
#或
bundle exec cap staging passenger:restart
```