# 抓出所有機器的 ip 列表
aws ec2 describe-instances | g '"PublicIp"' | sed 's/ *//g'



# 使用 SSH 連上 aws 的 ec2 機器

```
ssh ubuntu@34.239.151.223
```
其中 ubuntu 是使用者帳號，後面是 ec2 機器的 ip

回應如下：

```
The authenticity of host '35.153.39.168 (35.153.39.168)' can't be established.
ECDSA key fingerprint is SHA256:/tOxEG4Uo3ss7Lngz7tUNZIwSXvHSP0B5i5bWBC6o1c.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '35.153.39.168' (ECDSA) to the list of known hosts.
ubuntu@35.153.39.168's password:
```

