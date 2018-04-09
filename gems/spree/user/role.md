# Spree 權限控管機制

Spree::User 和 Spree::Role 之間具有多對多關係。

```
spree_test_development=# select * from spree_roles;
 id | name
----+-------
  1 | admin
  2 | user
(2 rows)
```

```
spree_test_development=# select * from spree_role_users;
 id | role_id | user_id
----+---------+---------
  1 |       1 |       1
(1 row)
```

透過 spree_role_users 來指定 user 具有的權限。
