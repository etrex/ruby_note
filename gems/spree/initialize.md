# 初始化設定

# 新增管理帳號

```
rake spree_auth:admin:create
```

或是在 rails console
```
Rails.application.load_tasks
Rake::Task['spree_auth:admin:create'].invoke
```

# 後台設定

偏好設定
  一般設定
    Name
    Seo Title
    url
    mail
    幣別設定

新增國家：Taiwan
新增區域：Taiwan

刪除付費方式：全部
新增付費方式：Tappay （Spree::Gateway::Tappay)

新增出貨方式：宅配/home
新增出貨方式：全家店到店/c2c

新增Option Type：size