# 多態關聯

可以讓一個 model 連接到多個不同的 model

原理:

假設存在 model A、B，一般關聯是這樣寫:

```
class A < ApplicationRecord
  belongs_to :b
end

class B < ApplicationRecord
  has_many :a
end
```

假設存在 model A、B1、B2、...、Bn，而我們想要讓 A 跟其中一個 B 有關聯

如果我們在建立物件模型A時，這樣寫:

```
rails g model a b:references{polymorphic}
```

那麼他產生出來的 migration_file 長這樣：

```
class CreateAs < ActiveRecord::Migration[5.2]
  def change
    create_table :as do |t|
      t.references :b, polymorphic: true

      t.timestamps
    end
  end
end
```

對應的資料表(postgresql)結構如下：

```
                                        Table "public.as"
   Column   |            Type             | Collation | Nullable |            Default
------------+-----------------------------+-----------+----------+--------------------------------
 id         | bigint                      |           | not null | nextval('as_id_seq'::regclass)
 b_type     | character varying           |           |          |
 b_id       | bigint                      |           |          |
 created_at | timestamp without time zone |           | not null |
 updated_at | timestamp without time zone |           | not null |
Indexes:
    "as_pkey" PRIMARY KEY, btree (id)
    "index_as_on_b_type_and_b_id" btree (b_type, b_id)
```

而這相當於使用以下指令產生的 model

```
rails g model a b_id:integer b_type
```

其對應的 migration 檔案內容如下：

```
class CreateAs < ActiveRecord::Migration[5.2]
  def change
    create_table :as do |t|
      t.integer :b
      t.string :

      t.timestamps
    end
  end
end
```

其產生出來的資料表結構如下：

```
                                        Table "public.as"
   Column   |            Type             | Collation | Nullable |            Default
------------+-----------------------------+-----------+----------+--------------------------------
 id         | bigint                      |           | not null | nextval('as_id_seq'::regclass)
 b_id       | integer                     |           |          |
 b_type     | character varying           |           |          |
 created_at | timestamp without time zone |           | not null |
 updated_at | timestamp without time zone |           | not null |
Indexes:
    "as_pkey" PRIMARY KEY, btree (id)
```

也就是說他會產生兩個欄位: b_id 跟 b_type。

跟一般關聯不同，這裡多用了一個 b_type 來儲存 b 的類別名稱。

同時 A 模型中應該要寫這樣的關聯:

```
class A < ApplicationRecord
  belongs_to :b, polymorphic: true
end
```

而 B 模型則是寫:

```
class B1 < ApplicationRecord
  has_many :a, as: :b
end
class B2 < ApplicationRecord
  has_many :a, as: :b
end
...
```


