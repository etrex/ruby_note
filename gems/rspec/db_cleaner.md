RSpec 在執行的時候不保證執行順序，每個測試產生的資料不會自動被清除。
因為測試對資料庫的操作會互相影響，如果想要確保每個測試都是在資料庫乾淨的狀態下，可以使用 [database_cleaner](https://github.com/DatabaseCleaner/database_cleaner)。
```
require 'database_cleaner'
...
RSpec.configure do |config|
...
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
...
end
```
其中的 before、around 可以參考官網說明文件：[https://relishapp.com/rspec/rspec-core/v/2-13/docs/hooks/before-and-after-hooks#before/after-blocks-defined-in-config-are-run-in-order](https://relishapp.com/rspec/rspec-core/v/2-13/docs/hooks/before-and-after-hooks#before/after-blocks-defined-in-config-are-run-in-order)
