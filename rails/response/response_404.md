如何在 controller 傳回各種404

# render
```
render status: :not_found
```

```
render status: :not_found, layout: false
```

```
render text: 'Not Found', status: :not_found
```

```
render file: 'public/404.html', status: :not_found, :layout => false
```

# head
```
head :not_found
```

# throw

```
raise ActiveRecord::RecordNotFound
```