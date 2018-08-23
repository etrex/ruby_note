# telegram

## 申請一隻聊天機器人
先在 Telegram 上加 [BotFather](https://telegram.me/botfather) 好友

然後跟他說 `/newbot` 就會進入填表單的流程

## 獲取 token 的方法
跟 botFather 說 `/token`

## 設定 Webhook
我們跟 Telegram 聯絡的方式是送出 request 到 `https://api.telegram.org/bot{token}/{方法名稱}`，其中 `{token}` 必須被替換成你的 token。

有個方法是 `setWebhook`，這就是新增一個 Webhook 的方法。

我們使用 Post request 打到這個網址，並傳遞一個參數 url 來告訴 Telegram 我們收訊息的 webhook 網址。

詳細說明可以參考[Telegram Webhook 的設定](https://core.telegram.org/bots/api#setwebhook)

## 收訊息

在 Telegram 中，每一個訊息稱為 Update，當我們從 webhook 收到 Update 時，會獲得一個 json。

以下是一個私聊文字訊息的 json 結構：

```ruby
{
  "update_id":495961079,
  "message":{
    "message_id":11,
    "from":{
      "id":164230890,
      "is_bot":false,
      "first_name":"郭佳甯",
      "username":"etrexkuo",
      "language_code":"zh-Hant"
    },
    "chat":{
      "id":164230890,
      "first_name":"郭佳甯",
      "username":"etrexkuo",
      "type":"private"
    },
    "date":1534958400,
    "text":"test"
  }
}
```

詳細的資料結構以及其代表的意義可以參考[Telegram Message 格式說明](https://core.telegram.org/bots/api#message)

## 發送訊息
和 `setWebhook` 差不多，同樣是打出 Post Request 來辦到，只是這次的方法名稱為 `sendmessage`。

需要傳遞的參數：
- chat_id：要將訊息發送到哪個群組
- text：訊息內容

我們可以從 webhook 獲得 chat_id。

詳細說明文件請參考[Telegram Send Message 說明](https://core.telegram.org/bots/api#sendmessage)

## 進群組後，想要收到所有的訊息
向 botFather 說 `/setprivacy` 並且設定為 `Disable` 就可以收到所有的訊息了

[Telegram Privacy Mode 說明文件](https://core.telegram.org/bots#privacy-mode)

## 參考文件
[Telegram Bot 相關說明](https://core.telegram.org/bots)
[Telegram Bot API 相關說明](https://core.telegram.org/bots/api)
