# 偵測一個檔案的編碼

需要安裝 [uchardet](https://www.freedesktop.org/wiki/Software/uchardet/)

```bash
brew install uchardet
uchardet file_path
```

# 讀取檔案時指定要使用的編碼

```
File.open(file_path, "r:SHIFT_JIS").each do |line|
end
```

此時 line.encoding 的值為 UTF-8

# 查看一個字串目前所使用的解碼器

str.encoding

```ruby
"hi!".encoding
=> #<Encoding:UTF-8>
```

# 查看一個字串真實的值

str.bytes

```ruby
"ない".bytes
 => [227, 129, 170, 227, 129, 132]
```

# 變更自身的解碼器，但不變更值

str.force_encoding(encoding)

```
"ない".encoding
 => #<Encoding:UTF-8>
"ない".bytes
 => [227, 129, 170, 227, 129, 132]
"ない"
 => "ない"
"ない".force_encoding("SHIFT_JIS").encoding
 => #<Encoding:Shift_JIS>
"ない".force_encoding("SHIFT_JIS").bytes
 => [227, 129, 170, 227, 129, 132]
"ない".force_encoding("SHIFT_JIS")
 => "\x{E381}\xAA\x{E381}\x84"
```

# 確保string「看起來」相同，獲得另一種編碼的值

str.encode(要變成的編碼)

舉例來說："ない".encode(編碼) 可以讓你獲得在其他編碼中，用來代表 "ない" 的值

```
"ない".encoding
 => #<Encoding:UTF-8>
"ない".bytes
 => [227, 129, 170, 227, 129, 132]
"ない"
 => "ない"
"ない".encode('SHIFT_JIS').encoding
 => #<Encoding:Shift_JIS>
"ない".encode('SHIFT_JIS').bytes
 => [130, 200, 130, 162]
"ない".encode('SHIFT_JIS')
 => "\x{82C8}\x{82A2}"
```

"ない" 在 UTF-8 編碼中的值是 [227, 129, 170, 227, 129, 132]
"ない" 在 SHIFT_JIS 編碼中的值是 [130, 200, 130, 162]

有可能會遇到在該編碼系統中沒有任何能代表 "ない" 的值，這時候會出錯誤

```ruby
"ない".encode("ASCII")
 => Encoding::UndefinedConversionError (U+306A from UTF-8 to US-ASCII)
```