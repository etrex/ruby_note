# INDEX（索引）

用空間換時間，加速查詢效果。

## cardinality(勢)
估計某欄位大概有多少種內容

WIKI：在數學裡，一個有限集的元素個數是一個自然數，其大小標誌著該集合裡元素的多少。比較無窮集裡元素的多寡之方法，可在集合論裡用集合的等勢和某集合的勢比另一個集合大這兩個概念來達到目的。

## B-tree
- MySQL 中最常用的 index

### 線性順序性
CREATE INDEX idx_1 (a, b, c);

把 a b c 按照順序排列
如果要查詢的資料是連續區間，就會採用 index
所以只能在最後一個條件做範圍查詢


#### 對以下 query 有幫助
WHERE a = 1 AND b = 2 AND c < 3;
WHERE a = 1 AND b = 2 AND c = 3;
WHERE a = 1 AND b = 2;
WHERE a = 1 AND b < 2;
WHERE a = 1;

#### 對以下 query 有部份幫助
WHERE a = 1 AND c = 3;

只有用到 a

#### 無法加速
WHERE b = 2 AND c = 3;
WHERE b = 2;
WHERE c = 3;

### Covered Index
在 index 放入要查詢的欄位，就不用在 index 查完之後再回去查主表
減少一次 Query 以加速

CREATE INDEX idx_1 (a, b, c, col1, col2);
SELECT col1, col2 FROM table WHERE a = 1 AND b = 2 AND c = 3;

不常被存取的表格才有可能加這個

## R-tree
- 使用於空間座標的操作
- MySQL 5.7+ 後的 InnoDB 支援 R-tree
- MyISAM 也支援 R-tree 但是太爛沒人用
- MySQL 的 R-tree 只能丟座標資料型態進去

## Elastic Search
- 需要兩個以上的範圍查詢時可以考慮使用

## 全文檢索
 GIN
 CJKV