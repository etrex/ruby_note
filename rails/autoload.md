https://blog.bigbinary.com/2016/08/29/rails-5-disables-autoloading-after-booting-the-app-in-production.html

結論

# config/application.rb
```
config.eager_load_paths << Rails.root.join('lib')
```

或

```
config.enable_dependency_loading = true
config.autoload_paths << Rails.root.join('lib')
```

沒事不要用第二種寫法