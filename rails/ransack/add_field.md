# 搜尋欄位簡寫

```
ransack_alias :author, :author_first_name_or_author_last_name
```

https://www.rubydoc.info/github/ernie/ransack/Ransack%2FAdapters%2FActiveRecord%2FBase:ransackable_attributes

# 可搜尋的欄位白名單設定

在 model 身上加入
```
def self.ransackable_attributes(auth_object = nil)
  %w[欄位名稱]
end
```

# 可搜尋的scope白名單設定
對 scope 做搜尋
```
  scope :order_payment_method_name_eq, lambda { |name|
    where(order_id:
      Spree::Payment.last_in_each_order
                    .payment_method_name_equal(name)
                    .select(:order_id))
  }

  def self.ransackable_scopes(_auth_object = nil)
    %w[order_payment_mtethod_name_eq]
  end
```

# 在 Spree 上可搜尋的關聯白名單設定
```
self.whitelisted_ransackable_associations = %w[關聯名稱]
```

