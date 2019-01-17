# 在 rails 登入後什麼時候會被自動登出

有兩個功能會影響自動登出時間。

- devise 的 remember_me

  如果在登入時選擇「記住我」則可以確保在時限內不會被自動登出，預設值為 2 週。
- rails 的 session

  session 確保用戶在持續使用的情況下不會被自動登出。

# devise 的 remember_me 功能

如果在登入時選擇「記住我」則可以確保在時限內不會被自動登出，預設值為 2 週。

devise 的 remember_me 功能會在 client 的 cookie 上加入一個 remember_#{model_name}_token 的 cookie，如果這個 cookie 存在，就算 session 過期，還是可以被視為登入。

可以在 config/initializers/devise.rb 設定 remember_#{model_name}_token 的過期時間：

```
  # ==> Configuration for :rememberable
  # The time the user will be remembered without asking for credentials again.
  config.remember_for = 3.minutes
```

登入後開始計時，時間到之後就消失。

# rails 的 session 功能

session 確保用戶在持續使用的情況下不會被自動登出。

rails 的 session 的存在時間可以在 config/applicaiton.rb 設定

```
config.session_store :redis_store, {
  servers: [
    {
      host: Settings.redis.host,
      port: Settings.redis.port,
      db: 0,
      namespace: "session"
    },
  ],
  expire_after: 1.minutes
}
```

如果將 session 的過期時間設定為 1 分鐘過期，那麼在每次收到 request 時，會重置倒數計時，直到連續兩次 request 的時間差大於 session 的過期時間。

