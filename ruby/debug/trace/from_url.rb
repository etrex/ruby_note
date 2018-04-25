# 想知道一個 request 打出去之後執行了哪些程式，要怎麼查呢？

## 查 url 會對應到哪個 controller

### 用 rails routes 查

`rails routes` 可以看到 url 和 controller 的對應關係，你可以獲得這種東西：

```
module_name/controller_name#action_name
```

### 用 rails server 查

用 `rails server` 把伺服器開起來之後直接開啟網頁，可以在 log 裡面找到 controller name。

```
Started GET "/login" for 127.0.0.1 at 2018-04-03 15:14:45 +0800
...
Processing by Spree::UserSessionsController#new as HTML
...
```

## 找 controller 原始碼

獲得 controller name 之後，如果在專案資料夾裡面沒有找到這個 controller，那麼這個 controller 應該是實作在某個套件裡面，通常直接 google controller name 就可以找到了。
