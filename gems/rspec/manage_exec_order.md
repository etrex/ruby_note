# 控制執行順序

如果想要控制 rspec 執行每一個 test 的順序，可以在 bash 寫：
```bash
rspec --order defined
rspec --seed 1
```
詳細的介紹可以參考 [https://relishapp.com/rspec/rspec-core/docs/command-line/order](https://relishapp.com/rspec/rspec-core/docs/command-line/order)