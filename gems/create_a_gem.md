如何寫一個 gem？

# 1: 生成一個新的 gem

```
bundle gem gem_name
```

其中 gem_name 可以替換成你想要的名字


# 2: 編輯 gem_name.gemspec

把 gem_name.gemspec 當中所有的 TODO 都填好

# 3: Test

可以進入已經載入 gem 的 irb 做一些測試

```
./bin/console
```

# 4: Build

```
git add .
gem build gem_name.gemspec
```

會生成一個 gem_name-0.1.0.gem 檔案

# 5: 發布

```
gem push gem_name-0.1.0.gem
```

就完成了！

# 注意事項

關於

```
gem build gem_name.gemspec
```

預設 gemspec 會有這段 code:
```
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
```

所以在 build 的時候，gemspec 會挑選出在 git 管理之下檔案，所以如果你建立了一個新檔案但是沒有 `git add .` 的話，是無法被打包進入 gem 內的。


# Gem::InvalidSpecificationException

另外，如果 build 好的 .gem 檔案也在 git 管理之下時，會無法 build 成功，因為不該把 .gem 包進 .gem 內。

```
WARNING:  See http://guides.rubygems.org/specification-reference/ for help
ERROR:  While executing gem ... (Gem::InvalidSpecificationException)
    gem_name-0.1.0 contains itself (gem_name-0.1.0.gem), check your files list
```

如果你只是單純刪除 .gem 檔，就重試 build 指令的話，你會看到

```
WARNING:  See http://guides.rubygems.org/specification-reference/ for help
ERROR:  While executing gem ... (Gem::InvalidSpecificationException)
    ["fake_chatbot-0.1.0.gem"] are not files
```