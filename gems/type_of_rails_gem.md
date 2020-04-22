# ruby gem, rails plugin, rails engine 的差別？

# ruby gem

使用以下指令生成一個新的 gem

```
bundle gem gem_name
```

# rails plugin

rails plugin 也是一種 gem

使用以下指令生成一個新的 rails plugin

```
rails plugin new gem_name
```

或

```
rails plugin new gem_name --full
```

或

```
rails plugin new gem_name --mountable
```

其中，加了 `--full` 或者是 `--mountable` 的指令生成的 rails plugin 又稱為 rails engine。

詳細請參考 [The ABC of Rails Engines](https://5xruby.tw/posts/rails-engines/)