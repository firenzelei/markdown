#!/bin/sh

# yum -y install wget && cd /tmp/ && wget https://raw.githubusercontent.com/firenzelei/markdown/master/init.sh && sh init.sh >> /tmp/init.sh 2>&1
# 语言
yum groupinstall chinese-support -y
#vim /etc/sysconfig/i18n   LANG="zh_CN.UTF-8"
echo "export LC_ALL=en_US.UTF-8"  >>  /etc/profile
source /etc/profile
rpm -Uvh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
rpm -Uvh http://mirror.webtatic.com/yum/el6/latest.rpm
rpm -Uvh https://www.percona.com/redir/downloads/percona-release/redhat/latest/percona-release-0.1-4.noarch.rpm
yum -y install epel-release
yum -y install gcc gcc-c++ autoconf automake make
yum -y install zlib zlib-devel openssl openssl-devel pcre pcre-devel
yum -y install ack screen wget curl zip unzip ntpdate
yum -y install net-snmp net-snmp-devel net-snmp-utils vim git bind-utils
yum -y install tar nc htop iotop iftop telnet wget curl curl-devel
yum -y remove mysql-server mysql httpd
yum -y install nginx nginx-module-geoip
yum -y install libwebp-devel libwebp-tools ImageMagick ImageMagick-devel 
yum -y install yum-utils
yum-complete-transaction
yum -y install sudo
service nginx start


# libmcrypt
# rpm -Uvh http://mirrors.hust.edu.cn/epel//5/x86_64/epel-release-5-4.noarch.rpm
# yum -y install libmcrypt libmcrypt-devel mcrypt mhash
yum -y install php71w php71w-fpm php71w-common php71w-cli php71w-devel php71w-intl php71w-mysqlnd php71w-pdo php71w-soap php71w-tidy php71w-xml php71w-xmlrpc php71w-zts php71w-gd php71w-mbstring php71w-mcrypt php71w-pecl-zendopcache php71w-pear php71w-posix php71w-mysqlnd php71w-pecl-redis
chkconfig --level 2345 php-fpm on
service php-fpm start

# Yar安装
yum -y install curl-devel
pecl install msgpack-2.0.2
pecl install yar-2.0.1

cd /etc/php.d  && echo "extension=msgpack.so" > msgpack.ini && echo "extension=yar.so" > yar.ini
service php-fpm restart

# mysql 5.7
rpm -Uvh http://dev.mysql.com/get/mysql57-community-release-el6-8.noarch.rpm
yum -y install mysql-community-server
service mysqld start
# 此时需要使用临时密码登录
# ps -ef | grep error=  
# cat /var/log/mysqld.log | grep "temporary password"  # 获取临时密码
# set global validate_password_policy=0;  # 否则会报错 Your password does not satisfy the current policy requirements
# 修改密码ALTER USER 'root'@'localhost' IDENTIFIED BY '***'; FLUSH PRIVILEGES;

# 更换时区
echo "ZONE=Asia/Shanghai" > /etc/sysconfig/clock
rm -f  /etc/localtime 
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#修改时间
# date -s "2017-03-23 14:31:00"
# clock -w

#### 安装redis
mkdir -p /etc/redis
cd /usr/local
wget http://download.redis.io/releases/redis-stable.tar.gz
tar xzf redis-stable.tar.gz
cd redis-stable
cd src && make && make install
cd ../ && sh utils/install_server.sh
/bin/cp -f redis.conf /etc/redis/6379.conf
service redis_6379 restart

####安装 composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer


#### 安装java
cd /tmp
wget  -O java.rpm http://javadl.oracle.com/webapps/download/AutoDL?BundleId=227541_e758a0de34e24606bca991d704f6dcbf -o java.rpm
rpm -ivh java.rpm
javac -version


# git 自动补全,设置别名
wget -O ~/.git-completion.bash https://raw.githubusercontent.com/git/git/3bc53220cb2dcf709f7a027a3f526befd021d858/contrib/completion/git-completion.bash 
echo "" >> ~/.bashrc && echo "source ~/.git-completion.bash" >> ~/.bashrc
source ~/.git-completion.bash

git config --global alias.st status
git config --global alias.br branch
git config --global alias.cm commit

# git-lfs安装 处理大文件使用
#curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | bash -
#yum makecache
#yum install -y git-lfs


# salt   安装saltStrack
yum install https://repo.saltstack.com/yum/redhat/salt-repo-latest-1.el7.noarch.rpm -y
yum clean expire-cache
yum install salt-master -y
yum install salt-minion -y

# 只需配置一下即可生效, master: 后面的空格不可丢
echo "master: pg01" >> /etc/salt/minion
service salt-minion restart && service salt-master restart
salt-key -L
salt-key -A -y
salt-key -L
salt '*' cmd.run "cd / && ls"

//其他的一些yum安装 crontab
yum install -y vixie-cron

# 邮件服务安装postfix
yum -y install mailx postfix
service postfix start
chkconfig postfix on
echo "123" | mail -s "邮件服务安装完毕" "zhanglei@nutsmobi.com"
# 如果提示  inet_protocols: configuring for IPv4 support only
# 那么  vim /etc/postfix/main.cf 修改  inet_protocols = ipv4
# 部分云服务器需要申请解封25端口，比如阿里云就是默认禁用的，需要申请解封。JD云默认打开

# 修改防火窗策略  vim  /etc/sysconfig/iptables  &&   service iptables restart
# -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
# -A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT


# 修改limit -n
#vi /etc/security/limits.conf
## End of file
#* soft nofile 65536
#* hard nofile 131072
#* soft nproc 2048
#* hard nproc 4096

sysctl -p


代码部署
mkdir -p /wwwroot
cd /wwwroot/
git clone git@github.com:firenzelei/wordpress.git
su -m nobody "composer update"
