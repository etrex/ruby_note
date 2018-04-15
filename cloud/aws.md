# 抓出所有機器的 ip 列表
aws ec2 describe-instances | g '"PublicIp"' | sed 's/ *//g'


# 使用 SSH 連上 aws ec2 的機器

```
ssh ubuntu@35.153.39.168
```
其中 ubuntu 是使用者帳號，後面是 ec2 機器的 ip

回應如下：

```
The authenticity of host '35.153.39.168 (35.153.39.168)' can't be established.
ECDSA key fingerprint is SHA256:/tOxEG4Uo3ss7Lngz7tUNZIwSXvHSP0B5i5bWBC6o1c.
Are you sure you want to continue connecting (yes/no)?
```

輸入 yes 繼續：

```
Warning: Permanently added '35.153.39.168' (ECDSA) to the list of known hosts.
ubuntu@35.153.39.168's password:
```

此時輸入對應使用者帳號(在這裡是 ubuntu)的密碼：

```
Welcome to Ubuntu 16.04.4 LTS (GNU/Linux 4.4.0-1054-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  Get cloud support with Ubuntu Advantage Cloud Guest:
    http://www.ubuntu.com/business/services/cloud

0 packages can be updated.
0 updates are security updates.


Last login: Sun Apr 15 02:16:11 2018 from 122.116.104.21
ubuntu@ip-172-30-0-28:~$
```

到這裡就連上了。