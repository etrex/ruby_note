 # 避免按下 button 時就送出表單的方法

會導致按下 button 時就送出表單是因為 button 的預設行為就是送出表單

也就是說 type 的預設值為 submit。

```
 <button>a</button>
```

跟

```
<button type="submit">a</button>
```

行為一致，所以要避免送出表單的方法是修改 type 值

```
<button type="button">a</button>
```
