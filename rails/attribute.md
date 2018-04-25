# 類別變數

使用 class_attribute 可以在類別上新增類別變數

```
class Base
  class_attribute :setting
end

class Subclass < Base
end

Base.setting = true
Subclass.setting            # => true
Subclass.setting = false
Subclass.setting            # => false
Base.setting                # => true
```

閱讀更多：https://apidock.com/rails/Class/class_attribute
