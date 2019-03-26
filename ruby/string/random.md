# 產生隨機字串的方法

## 使用 Devise 套件提供的

```ruby
Devise.friendly_token
```

## Faker

```ruby
Faker::Lorem.characters(10)
```

## SecureRandom

```ruby
SecureRandom.hex(10)
```

```ruby
SecureRandom.base64(10)
```

```ruby
SecureRandom.random_bytes(10)
```

```ruby
SecureRandom.uuid
```

```ruby
SecureRandom.random_number(characters**length).to_s(characters)
```