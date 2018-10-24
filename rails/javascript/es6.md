# export 與 import 的用法


# variable export

popup.js 的定義
```js
export const apply = function() {
  ...
}
```

import 時的寫法
```js
import { apply } from 'popup'
apply();
```

# class export

popup.js 的定義
```js
export default class Popup {
  constructor(autoShow = true) {
    this.autoShow = autoShow;
  }

  this.show = function(){

  }
}
```

import 時的寫法
```js
import Popup from 'popup'

const popup = new Popup();
popup.show();
```



# mount
```js
// <div id="nannies-edit"></div>
class PopupManager {
  constructor() {
    this.popups = {};
  }

  register($el, options) {
    this.popups[$el] = new Popup(options);
  }

  mount() {
    let el, $el;
    for(el in this.popups) {
      $el = document.getElementById(el);
      if($el) {
        this.popups[el].show();
      }
    }
  }
}

const manager = new PopupManager();
manager.register("#nannies-edit", {xxx});

document.addEventListener('turbolinks:load', function() {
  manager.mount();
});
```