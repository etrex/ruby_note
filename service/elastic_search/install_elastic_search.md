# 安裝 elasticsearch

參考文件：https://www.elastic.co/guide/en/elasticsearch/reference/current/_installation.html

以下說明如何在 macOS 下安裝 elasticsearch。

在安裝 elasticsearch 之前必須安裝 java 8

## 安裝 java8

```
brew cask install homebrew/cask-versions/java8
```

檢查是否安裝成功

```
java -version
```

預期會看見以下訊息：

```
java version "1.8.0_181"
Java(TM) SE Runtime Environment (build 1.8.0_181-b13)
Java HotSpot(TM) 64-Bit Server VM (build 25.181-b13, mixed mode)
```
# 安裝 elasticsearch

```
brew install elasticsearch
```

# 執行 elasticsearch

```
elasticsearch
```

# 在背景執行 elasticsearch

```
brew services start elasticsearch
```

# 查看 elasticsearch 狀態

```
curl -X GET "localhost:9200/_cat/health?v"
```

或者使用 kibana 來查看狀態

# 安裝 kibana

```
brew install kibana
```

# 執行 kibana

```
kibana
```

# 在背景執行 kibana

```
brew services start kibana
```

# 使用 kibana 查看 elasticsearch 狀態

開啟網頁：http://localhost:5601/app/kibana#/dev_tools/console


# 安裝中文分詞套件 IK

github: https://github.com/medcl/elasticsearch-analysis-ik

```
elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v6.2.4/elasticsearch-analysis-ik-6.2.4.zip
```

測試效果

```
curl -XPUT http://localhost:9200/index

curl -XPOST http://localhost:9200/index/fulltext/_mapping -H 'Content-Type:application/json' -d'
{
  "properties": {
    "content": {
      "type": "text",
      "analyzer": "ik_max_word",
      "search_analyzer": "ik_max_word"
    }
  }
}'

curl -XPOST http://localhost:9200/index/fulltext/1 -H 'Content-Type:application/json' -d'
{"content":"美国留给伊拉克的是个烂摊子吗"}
'

curl -XPOST http://localhost:9200/index/fulltext/2 -H 'Content-Type:application/json' -d'
{"content":"公安部：各地校车将享最高路权"}
'

curl -XPOST http://localhost:9200/index/fulltext/3 -H 'Content-Type:application/json' -d'
{"content":"中韩渔警冲突调查：韩警平均每天扣1艘中国渔船"}
'

curl -XPOST http://localhost:9200/index/fulltext/4 -H 'Content-Type:application/json' -d'
{"content":"中国驻洛杉矶领事馆遭亚裔男子枪击 嫌犯已自首"}
'

curl -XPOST http://localhost:9200/index/fulltext/_search  -H 'Content-Type:application/json' -d'
{
  "query" : { "match" : { "content" : "中国" }},
  "highlight" : {
    "pre_tags" : ["<tag1>", "<tag2>"],
    "post_tags" : ["</tag1>", "</tag2>"],
    "fields" : {
      "content" : {}
    }
  }
}
'
```

### 更換字典檔

參考 IK github 上的說明：

IKAnalyzer.cfg.xml can be located at {conf}/analysis-ik/config/IKAnalyzer.cfg.xml or {plugins}/elasticsearch-analysis-ik-*/config/IKAnalyzer.cfg.xml

字典檔的格式是一行一個詞

可參考這個字典檔：https://github.com/samejack/sc-dictionary

