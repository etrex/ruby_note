
## 當外鍵欄位名稱與資料表名稱不同時
```
create_table :messages do |t|
  t.references :sender, foreign_key: {to_table: :users}
end
```~