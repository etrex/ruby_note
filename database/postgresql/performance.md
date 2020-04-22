# 效能優化的概念

## 需求
- 透過觀測來察覺需求
  - 找出跑得足夠慢的 Query 例如 > 10ms
    - PostgreSQL extension (pg_stat_statements)[https://www.postgresql.org/docs/current/pgstatstatements.html]
  - 為什麼慢
    - Explain
      - https://explain.depesz.com
      - http://tatiyants.com/pev/%23/about
      - pgAdmin


## 方法

1. 直接砍需求 好爽
2. 讓他變快
    - 透過調整資料結構來採取更高效的演算法
    - 全都是快取的力量
    - 所有的快取都有成本

- 讓同一個 SQL 變快
  - 優化 query plan
    - 自動優化：同一個 sql 自己本來就會越跑越快
    - 調整 query planner 參數
    - VACUUM & ANALYZE & REINDEX & REFRESH materialized view concurrently
    - 跳過 query plan：PREPARE
  - 建立索引
    - INDEX：(有各種 index 可以用)[https://github.com/digoal/blog/blob/master/201612/20161231_01.md]
      - Hash：=
      - bloom filters：= (相當於任意組合的 B-tree，但是會掉資料)[https://github.com/digoal/blog/blob/master/201605/20160523_01.md]
      - B-tree：= > <
      - BRIN：比 B-tree 小，把資料按照維度切割成方塊狀，可以定義每個方塊的大小，索引紀錄方塊的位置，搜尋資料時可以找到對應的方塊後再做 seq scan
      - GIN：or 的概念、字串模糊搜尋、正規表達、全文檢索
      - GiST：字串模糊搜尋、正規表達、範圍相交、包含、地理位置中的點面相交，搜尋附近的點
      - SP- GiST：空間特化的 GiST
    - 維護成本：
      - 占空間
      - 越屌的 index 越貴
      - 每次 insert、update、delete 都需要更新 index

- 寫不同的 SQL
  - Mertialized View：不會自動更新，需要指定更新時間
  - 暫存表格：要用的時候才計算的快取
  - 一個 Query 拆成多個 Query：強迫 query planner 按照自己的想法
  - 多個需求做成同一個 Query：一次購足
  - Denormalizeation 改變資料結構（大招 沒事不要用）
    - 使用 array、range、jsonb 欄位
    - 使用 gin gist 索引
    - 使用 @> 比較元素包含 集合包含
    - 省略 join
  - Pre-Computed Values
    - 使用 trigger 更新資料
  - Partitioning：https://www.postgresql.org/docs/10/ddl-partitioning.html
  - 多資料庫

# 實作

## 建立測試資料

建立資料庫
```sql
CREATE DATABASE performance_test;
```

## 效能監測

### 修改 postgresql.conf

```
code /usr/local/var/postgres/postgresql.conf
```

加入以下內容

```
shared_preload_libraries = 'pg_stat_statements'	# (change requires restart)
pg_stat_statements.max = 1000
pg_stat_statements.track = all
```

### 重開 postgresql server

```
brew services restart postgresql
```


### 安裝 extension

查看可安裝的 extension
```sql
\c performance_test
table pg_available_extensions;
```

目前已安裝的 extension
```sql
\dx
```

安裝 pg_stat_statements
```sql
CREATE EXTENSION pg_stat_statements;
```

測試安裝結果
```sql
SELECT * FROM pg_stat_statements LIMIT 1;
```

## 調整 query planner 參數

http://ching119.blogspot.com/2012/06/postgresql-query-plan-bitmap-heap-scan.html
https://kknews.cc/code/gz543le.html

```sql
set random_page_cost=1;
```

## 加入測試資料

建立函數
```sql
CREATE FUNCTION random_string(
  IN string_length INTEGER,
  IN possible_chars TEXT DEFAULT 'abcdefghijklmnopqrstuvwxyz'
)
RETURNS text
LANGUAGE plpgsql
AS $$
  DECLARE
    output TEXT = '';
    i INT4;
    pos INT4;
  BEGIN
    FOR i IN 1..string_length LOOP
      pos := 1 + CAST( random() * ( LENGTH(possible_chars) - 1) AS INT4 );
      output := output || substr(possible_chars, pos, 1);
    END LOOP;
    RETURN output;
  END;
$$;
```

建立資料表
```sql
CREATE TABLE users
(
  id bigint PRIMARY KEY,
  name text NOT NULL,
  birthday timestamp NOT NULL
);
```

寫入隨機資料
```
INSERT INTO users (id, name, birthday)
SELECT
  id,
  INITCAP(random_string(10)) as name,
  now() + random() * interval '-50 year' as birthday
FROM generate_series(1, 10000) id;
```

## 簡單查詢

```
explain select * from users;
```

輸出：

```
                         QUERY PLAN
------------------------------------------------------------
 Seq Scan on users  (cost=0.00..174.00 rows=10000 width=27)
(1 row)
```

Seq Scan：每一筆資料循序看過一遍

估計啟動成本：0.00
估計總成本：174.00
估計資料列數量：10000 筆
估計一列資料的平均大小：27 bytes

成本的預設單位：以對磁碟頁面讀取1次的成本為基本單位

### where id > 9527

```
explain select * from users where id > 9527;
```

```
                                 QUERY PLAN
----------------------------------------------------------------------------
 Index Scan using users_pkey on users  (cost=0.29..23.56 rows=473 width=27)
   Index Cond: (id > 9527)
(2 rows)
```

使用 users_pkey 這個 index 進行 Index Scan

### where id > 9527 and birthday < now();

```
explain select * from users where id > 9527 and birthday < now();
```

```
                                 QUERY PLAN
----------------------------------------------------------------------------
 Index Scan using users_pkey on users  (cost=0.29..25.93 rows=473 width=27)
   Index Cond: (id > 9527)
   Filter: (birthday < now())
(3 rows)
```

在 index 找到的東西裡面，每個都做一次 birthday < now() 的過濾檢查

### where id < 9527 and birthday < now();

```
explain select * from users where id < 9527 and birthday < now();
```

```
                        QUERY PLAN
-----------------------------------------------------------
 Seq Scan on users  (cost=0.00..249.00 rows=9525 width=27)
   Filter: ((id < 9527) AND (birthday < now()))
(2 rows)
```

大概是因為察覺到資料量過大，直接放棄使用 index

### 加入新的 index

```
CREATE INDEX index_users_name ON users(name);
CREATE INDEX index_users_birthday ON users(birthday);
```

### select * from users where id < 9527 and birthday < now() + '-30 years';

```
explain select * from users where id < 9527 and birthday < now() + '-30 years';
```

```
                                      QUERY PLAN
---------------------------------------------------------------------------------------
 Bitmap Heap Scan on users  (cost=83.58..238.44 rows=3851 width=27)
   Recheck Cond: (birthday < (now() + '-30 years'::interval))
   Filter: (id < 9527)
   ->  Bitmap Index Scan on index_users_birthday  (cost=0.00..82.61 rows=4043 width=0)
         Index Cond: (birthday < (now() + '-30 years'::interval))
(5 rows)

Bitmap Index Scan: 看索引 index_users_birthday 找出所有滿足日期條件的紀錄的參考
Bitmap Heap Scan: 拿參考的東西取出 users 表格當中的東西，在過程中加入篩選 id
```

### explain select * from users where id > 4527 and birthday < now() + '-30 years' and name < 'G';

```
explain select * from users where id > 4527 and birthday < now() + '-30 years' and name < 'G';
```

```
                                    QUERY PLAN
-----------------------------------------------------------------------------------
 Bitmap Heap Scan on users  (cost=57.65..183.38 rows=509 width=27)
   Recheck Cond: (name < 'G'::text)
   Filter: ((id > 4527) AND (birthday < (now() + '-30 years'::interval)))
   ->  Bitmap Index Scan on index_users_name  (cost=0.00..57.53 rows=2299 width=0)
         Index Cond: (name < 'G'::text)
(5 rows)
```

Query Planner 會根據自己對於資料分布的了解來選擇最有效率的索引，無法同時使用兩個索引

## 加入更多資料

```
CREATE TABLE follows
(
  id bigint PRIMARY KEY,
  user_id bigint NOT NULL,
  follower_id bigint NOT NULL,
  CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES users (id),
  CONSTRAINT fk_follower_id FOREIGN KEY (follower_id) REFERENCES users (id)
);
```

寫入隨機資料
```
INSERT INTO follows (id, user_id, follower_id)
SELECT
  id,
  floor(random()*10000)+1 as user_id,
  floor(random()*10000)+1 as follower_id
FROM generate_series(1, 1000000) id;
```

## 多欄位 index

### select * from follows where user_id = 5 and follower_id = 12;

```
explain select * from follows where user_id = 5 and follower_id = 12;
```

```
                                QUERY PLAN
---------------------------------------------------------------------------
 Gather  (cost=1000.00..13620.10 rows=1 width=24)
   Workers Planned: 2
   ->  Parallel Seq Scan on follows  (cost=0.00..12620.00 rows=1 width=24)
         Filter: ((user_id = 5) AND (follower_id = 12))
(4 rows)
```

有兩個 worker 同時在對 follows 做 Seq Scan

## 多欄位 index 的功能

```
CREATE INDEX index_follows_user_id ON follows(user_id);
CREATE INDEX index_follows_follower_id ON follows(follower_id);
CREATE INDEX index_follows_user_id_and_follower_id ON follows(user_id, follower_id);
explain select * from follows where user_id = 5 and follower_id = 12;
```

```
                                              QUERY PLAN
------------------------------------------------------------------------------------------------------
 Index Scan using index_follows_user_id_and_follower_id on follows  (cost=0.42..8.45 rows=1 width=24)
   Index Cond: ((user_id = 5) AND (follower_id = 12))
(2 rows)
```

無法對使用多個 index 但是可以使用一個多欄位 index


## 找出所有 40 歲以上追蹤 10 歲以下的組合，依照 user id 排序

```
explain analyze
select u.*, f.*
from users u
join follows on u.id = follows.user_id
join users f on f.id = follows.follower_id
where u.birthday > now() + '-10 years'
and f.birthday < now() + '-40 years'
order by u.id, f.id
limit 100
;
```

```
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=1.00..238.01 rows=100 width=54) (actual time=8.223..54.228 rows=100 loops=1)
   ->  Nested Loop  (cost=1.00..91915.80 rows=38781 width=54) (actual time=8.221..54.198 rows=100 loops=1)
         ->  Merge Join  (cost=0.71..29926.52 rows=199900 width=35) (actual time=5.478..29.926 rows=527 loops=1)
               Merge Cond: (follows.user_id = u.id)
               ->  Index Only Scan using index_follows_user_id_and_follower_id on follows  (cost=0.42..25223.42 rows=1000000 width=16) (actual time=0.689..27.090 rows=3768 loops=1)
                     Heap Fetches: 3768
               ->  Index Only Scan using index_users_id_name_birthday on users u  (cost=0.29..199.09 rows=1999 width=27) (actual time=2.113..2.121 rows=6 loops=1)
                     Index Cond: (birthday > (now() + '-10 years'::interval))
                     Heap Fetches: 6
         ->  Index Scan using users_pkey on users f  (cost=0.29..0.31 rows=1 width=27) (actual time=0.045..0.045 rows=0 loops=527)
               Index Cond: (id = follows.follower_id)
               Filter: (birthday < (now() + '-40 years'::interval))
               Rows Removed by Filter: 1
 Planning Time: 16.823 ms
 Execution Time: 54.305 ms
```

1. 使用 2 次 users_pkey 分別取出 user u 和 follower f
2. 使用 Merge Join (是維持排序的 Join 方法) 做 u 和 follows 的 join
2. 根據 user id 做 merge join
3. 使用 nested loops 方法做 join

### 改成用 birthday 排序

```
explain analyze
select u.*, f.*
from users u
join follows on u.id = follows.user_id
join users f on f.id = follows.follower_id
where u.birthday > now() + '-10 years'
and f.birthday < now() + '-40 years'
order by u.birthday, f.birthday
limit 100
;
```

```
                                                                            QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=16344.37..16344.62 rows=100 width=54) (actual time=257.170..257.191 rows=100 loops=1)
   ->  Sort  (cost=16344.37..16441.32 rows=38781 width=54) (actual time=257.169..257.176 rows=100 loops=1)
         Sort Key: u.birthday, f.birthday
         Sort Method: top-N heapsort  Memory: 48kB
         ->  Hash Join  (cost=140.67..14862.19 rows=38781 width=54) (actual time=3.456..242.331 rows=38543 loops=1)
               Hash Cond: (follows.user_id = u.id)
               ->  Nested Loop  (cost=0.42..14212.48 rows=194000 width=35) (actual time=0.058..193.003 rows=193201 loops=1)
                     ->  Seq Scan on users f  (cost=0.00..249.00 rows=1940 width=27) (actual time=0.039..4.795 rows=1938 loops=1)
                           Filter: (birthday < (now() + '-40 years'::interval))
                           Rows Removed by Filter: 8062
                     ->  Index Scan using index_follows_follower_id on follows  (cost=0.42..6.20 rows=100 width=16) (actual time=0.005..0.079 rows=100 loops=1938)
                           Index Cond: (follower_id = f.id)
               ->  Hash  (cost=115.26..115.26 rows=1999 width=27) (actual time=3.382..3.382 rows=1998 loops=1)
                     Buckets: 2048  Batches: 1  Memory Usage: 141kB
                     ->  Index Scan using index_users_birthday on users u  (cost=0.29..115.26 rows=1999 width=27) (actual time=0.017..1.435 rows=1998 loops=1)
                           Index Cond: (birthday > (now() + '-10 years'::interval))
 Planning Time: 1.545 ms
 Execution Time: 257.267 ms
```

### 加上 offset

```
explain analyze
select u.*, f.*
from users u
join follows on u.id = follows.user_id
join users f on f.id = follows.follower_id
where u.birthday > now() + '-10 years'
and f.birthday < now() + '-40 years'
order by u.birthday, f.birthday
limit 100
offset 10000
;
```

```
                                                                            QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=17660.43..17660.68 rows=100 width=54) (actual time=335.162..335.209 rows=100 loops=1)
   ->  Sort  (cost=17635.43..17732.38 rows=38781 width=54) (actual time=332.962..334.485 rows=10100 loops=1)
         Sort Key: u.birthday, f.birthday
         Sort Method: top-N heapsort  Memory: 2985kB
         ->  Hash Join  (cost=140.67..14862.19 rows=38781 width=54) (actual time=2.420..298.591 rows=38543 loops=1)
               Hash Cond: (follows.user_id = u.id)
               ->  Nested Loop  (cost=0.42..14212.48 rows=194000 width=35) (actual time=0.020..244.729 rows=193201 loops=1)
                     ->  Seq Scan on users f  (cost=0.00..249.00 rows=1940 width=27) (actual time=0.012..9.179 rows=1938 loops=1)
                           Filter: (birthday < (now() + '-40 years'::interval))
                           Rows Removed by Filter: 8062
                     ->  Index Scan using index_follows_follower_id on follows  (cost=0.42..6.20 rows=100 width=16) (actual time=0.006..0.093 rows=100 loops=1938)
                           Index Cond: (follower_id = f.id)
               ->  Hash  (cost=115.26..115.26 rows=1999 width=27) (actual time=2.386..2.386 rows=1998 loops=1)
                     Buckets: 2048  Batches: 1  Memory Usage: 141kB
                     ->  Index Scan using index_users_birthday on users u  (cost=0.29..115.26 rows=1999 width=27) (actual time=0.019..2.018 rows=1998 loops=1)
                           Index Cond: (birthday > (now() + '-10 years'::interval))
 Planning Time: 0.468 ms
 Execution Time: 335.270 ms
```


## 用 materialized view 加速

```
create materialized view mv_user_and_follower as
select
  u.id user_id,
  u.name user_name,
  u.birthday user_birthday,
  f.id follower_id,
  f.name follower_name,
  f.birthday follower_birthday
from users u
join follows on u.id = follows.user_id
join users f on f.id = follows.follower_id
```


### 使用 materialized view 找出所有 40 歲以上追蹤 10 歲以下的組合，用 birthday 排序

```
EXPLAIN ANALYZE
select *
from mv_user_and_follower
where user_birthday > now() + '-10 years'
and follower_birthday < now() + '-40 years'
order by user_birthday, follower_birthday
limit 100
```

```
                                                               QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=37801.50..37801.75 rows=100 width=54) (actual time=407.964..407.982 rows=100 loops=1)
   ->  Sort  (cost=37801.50..37895.53 rows=37612 width=54) (actual time=407.963..407.969 rows=100 loops=1)
         Sort Key: user_birthday, follower_birthday
         Sort Method: top-N heapsort  Memory: 47kB
         ->  Seq Scan on mv_user_and_follower  (cost=0.00..36364.00 rows=37612 width=54) (actual time=0.042..399.039 rows=38543 loops=1)
               Filter: ((user_birthday > (now() + '-10 years'::interval)) AND (follower_birthday < (now() + '-40 years'::interval)))
               Rows Removed by Filter: 961457
 Planning Time: 0.081 ms
 Execution Time: 408.005 ms
```

變成單純的 Seq Scan

### 加上 offest

```
EXPLAIN ANALYZE
select *
from mv_user_and_follower
where user_birthday > now() + '-10 years'
and follower_birthday < now() + '-40 years'
order by user_birthday, follower_birthday
limit 100
offset 10000
```

```
                                                               QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=39078.65..39078.90 rows=100 width=54) (actual time=426.145..426.173 rows=100 loops=1)
   ->  Sort  (cost=39053.65..39147.68 rows=37612 width=54) (actual time=423.449..425.439 rows=10100 loops=1)
         Sort Key: user_birthday, follower_birthday
         Sort Method: top-N heapsort  Memory: 2994kB
         ->  Seq Scan on mv_user_and_follower  (cost=0.00..36364.00 rows=37612 width=54) (actual time=0.036..402.557 rows=38543 loops=1)
               Filter: ((user_birthday > (now() + '-10 years'::interval)) AND (follower_birthday < (now() + '-40 years'::interval)))
               Rows Removed by Filter: 961457
 Planning Time: 0.088 ms
 Execution Time: 426.209 ms
```

沒有變慢多少

### 在 materialized view 上加 index

```
CREATE INDEX index_mv_user_and_follower_birthday ON mv_user_and_follower(user_birthday, follower_birthday);
```

```
EXPLAIN ANALYZE
select *
from mv_user_and_follower
where user_birthday > now() + '-10 years'
and follower_birthday < now() + '-40 years'
order by user_birthday, follower_birthday
limit 100
```

```
                                                                                QUERY PLAN
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=0.43..38.88 rows=100 width=54) (actual time=0.059..0.202 rows=100 loops=1)
   ->  Index Scan using index_mv_user_and_follower_birthday on mv_user_and_follower  (cost=0.43..14458.62 rows=37612 width=54) (actual time=0.058..0.188 rows=100 loops=1)
         Index Cond: ((user_birthday > (now() + '-10 years'::interval)) AND (follower_birthday < (now() + '-40 years'::interval)))
 Planning Time: 0.101 ms
 Execution Time: 0.226 ms
```

太神啦～

再測個 offset

```
EXPLAIN ANALYZE
select *
from mv_user_and_follower
where user_birthday > now() + '-10 years'
and follower_birthday < now() + '-40 years'
order by user_birthday, follower_birthday
limit 100
offset 10000
```

```
                                                                                  QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=3844.47..3882.91 rows=100 width=54) (actual time=19.788..19.942 rows=100 loops=1)
   ->  Index Scan using index_mv_user_and_follower_birthday on mv_user_and_follower  (cost=0.43..14458.62 rows=37612 width=54) (actual time=0.057..19.255 rows=10100 loops=1)
         Index Cond: ((user_birthday > (now() + '-10 years'::interval)) AND (follower_birthday < (now() + '-40 years'::interval)))
 Planning Time: 0.104 ms
 Execution Time: 19.968 ms
```

快到起飛

## 試試 Precompute 的 materialized view 的策略看看

```
create materialized view mv_user_and_follower2 as
select
  u.id user_id,
  u.name user_name,
  u.birthday user_birthday,
  cast(floor(EXTRACT(DAY FROM now()-u.birthday)/365/5)*5 as integer) user_age,
  f.id follower_id,
  f.name follower_name,
  f.birthday follower_birthday,
  cast(floor(EXTRACT(DAY FROM now()-f.birthday)/365/5)*5 as integer) follower_age
from users u
join follows on u.id = follows.user_id
join users f on f.id = follows.follower_id;
\d mv_user_and_follower2;

CREATE INDEX index_mv_user_and_follower2_birthday ON mv_user_and_follower2(user_age, follower_age, user_birthday, follower_birthday);
```

確認一下內容

```
select user_age, count(0) from mv_user_and_follower2 group by 1;
```

```
 user_age | count
----------+--------
        0 |  96911
        5 | 102467
       10 |  98203
       15 |  98513
       20 |  90505
       25 | 108177
       30 | 108161
       35 | 103045
       40 |  96461
       45 |  97057
       50 |    500
```

### 查一樣的東西看結果

```
EXPLAIN ANALYZE
select *
from mv_user_and_follower2
where user_age in (0,5)
and follower_age in (40,45,50)
order by user_birthday, follower_birthday
limit 100
```

```
                                                                                      QUERY PLAN
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=15691.29..15691.54 rows=100 width=62) (actual time=53.577..53.598 rows=100 loops=1)
   ->  Sort  (cost=15691.29..15787.92 rows=38654 width=62) (actual time=53.576..53.583 rows=100 loops=1)
         Sort Key: user_birthday, follower_birthday
         Sort Method: top-N heapsort  Memory: 39kB
         ->  Index Scan using index_mv_user_and_follower2_birthday on mv_user_and_follower2  (cost=0.42..14213.96 rows=38654 width=62) (actual time=0.018..44.697 rows=38644 loops=1)
               Index Cond: ((user_age = ANY ('{0,5}'::integer[])) AND (follower_age = ANY ('{40,45,50}'::integer[])))
 Planning Time: 0.113 ms
 Execution Time: 53.623 ms
```

看起來是變得很單純，加個 offset 看看：

```
EXPLAIN ANALYZE
select *
from mv_user_and_follower2
where user_age in (0,5)
and follower_age in (40,45,50)
order by user_birthday, follower_birthday
limit 100
offset 10000
```

```
                                                                                      QUERY PLAN
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=17003.12..17003.37 rows=100 width=62) (actual time=66.240..66.262 rows=100 loops=1)
   ->  Sort  (cost=16978.12..17074.76 rows=38654 width=62) (actual time=64.764..65.628 rows=10100 loops=1)
         Sort Key: user_birthday, follower_birthday
         Sort Method: top-N heapsort  Memory: 2819kB
         ->  Index Scan using index_mv_user_and_follower2_birthday on mv_user_and_follower2  (cost=0.42..14213.96 rows=38654 width=62) (actual time=0.019..34.210 rows=38644 loops=1)
               Index Cond: ((user_age = ANY ('{0,5}'::integer[])) AND (follower_age = ANY ('{40,45,50}'::integer[])))
 Planning Time: 0.103 ms
 Execution Time: 66.305 ms
```