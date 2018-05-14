# 載入自訂的 config 檔


## 方法 1
參考 [Rails Guides](http://guides.rubyonrails.org/configuring.html) 提供的解法。

設定檔 config/payment.yml:

```
production:
  environment: production
  merchant_id: production_merchant_id
  public_key:  production_public_key
  private_key: production_private_key
development:
  environment: sandbox
  merchant_id: development_merchant_id
  public_key:  development_public_key
  private_key: development_private_key
```

設定檔的載入 config/application.rb

```
module MyApp
  class Application < Rails::Application
    config.payment = config_for(:payment)
  end
end
```

取得設定檔中的值

```
Rails.configuration.payment['merchant_id']
```

## 方法 2

參考 [Coderwall](https://coderwall.com/p/8ruh8a/custom-config-for-rails-app) 上提供的解法。

設定檔 config/config.yml:

```
production:
    api_url: http://sample_url/api
    api_key: d91nrRr6qM
    secret_key: oTi3k4qW82

development:
    api_url: http://localhost:3000/api
    api_key: 0e7idRmq4h
    secret_key: y8mDky3Ew1

test:
    api_url: http://localhost:3000/api
    api_key: 0e7idRmq4h
    secret_key: y8mDky3Ew1
```

設定檔的載入 config/initializers/load_config.rb:

```
CONFIG_PATH="#{Rails.root}/config/config.yml"
APP_CONFIG = YAML.load_file(CONFIG_PATH)[Rails.env]
```

取得設定檔中的值

```
APP_CONFIG['api_url']
```

# 方法 3

參考 [tamouse](https://tamouse.github.io/swaac/swaac/2015/01/20/rails-4-dot-2-config-for/)提供的解法。

在任何地方載入設定檔：

```
Rails.application.config_for(:app)
```

其中 `:app` 是設定檔的檔名。

所以可以把方法2 設定檔的載入改成：

```
APP_CONFIG = Rails.application.config_for(:app)
```