# Elixir

# 語法
跟 ruby 有 87 ％ 像的 functional 語言

# Demo (Pipe, Pattern Matching)
vali_int/1 的意思？？

# Macro

quote do ... end

可以獲得 ... 的 AST

defmacro 必須傳回 AST 所以 defmacro 一開始就包一個 quote do ... end
defmacro OOO() do
  quote do
    ...
  end
end


# race condition

spawn 可以開 process

```
spawn (fn -> ... end)
```

# OTP
定義 GenServer 跟 Supervisor