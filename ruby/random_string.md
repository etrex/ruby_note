# 產生隨機字串的方法

## 使用 Devise 套件提供的

Devise.friendly_token

## Faker

Faker::Lorem.characters(10)

## SecureRandom

SecureRandom.hex(10)

SecureRandom.base64(10)

SecureRandom.random_bytes(10)

SecureRandom.uuid

SecureRandom.random_number(characters**length).to_s(characters)