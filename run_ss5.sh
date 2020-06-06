@@ -0,0 +1,33 @@
#!/bin/bash

count=`ps -fe |grep "ss5" | grep -v "grep" | wc -l`
if [ $count -lt 1 ]; then
        ips="*.*.*.*" #IP的前三位，需要连号的IP段才能使用
        int=130  #IP后面的起始位
        max=229  #IP后面的终结位
        pass=987654 #账号密码不用改
        user="user" #系统子账号，本文件可以放到系统的任意目录
        prat=":10809"
        mkdir /var/run/ss5
        rm -fr /home/user* #要与系统子账号一致
        rm -fr /var/spool/mail/user* #要与系统子账号一致
        while(($int<=$max))
                do
                        user_s=$user$int
                        z="/^$user_s:/{print \$4}"
                        uid=`awk -F: "$z" /etc/passwd`
                        if [ "$uid" = "" ]; then
                                echo "创建用户"$user_s
                                useradd  $user_s  -s /bin/false -p  $pass
                                z="/^$user_s:/{print \$4}"
                                uid=`awk -F: "$z" /etc/passwd`
                        fi
                        iptables -t mangle -A OUTPUT -m owner --uid-owner $uid -j MARK --set-mark $uid
                        iptables -t nat -A POSTROUTING -m mark --mark $uid -j SNAT --to-source $ips$int
                        ss5  -t -u $user_s -b $ips$int$prat
                        echo "启动"$ips$int$prat"代理服务器"
                                let "int++"
                done

fi
echo "ok！"
