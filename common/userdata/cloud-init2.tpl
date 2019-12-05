#cloud-config

runcmd:
# download the secondary vnic script
- wget -O /usr/local/bin/secondary_vnic_all_configure.sh https://docs.cloud.oracle.com/iaas/Content/Resources/Assets/secondary_vnic_all_configure.sh
- chmod +x /usr/local/bin/secondary_vnic_all_configure.sh
- sleep 60
- /usr/local/bin/secondary_vnic_all_configure.sh -c
- echo 'PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin' > /var/spool/cron/root
- echo '@reboot /usr/local/bin/secondary_vnic_all_configure.sh -c' >> /var/spool/cron/root

# Postgresqlで使用するポート設定
- setenforce 0
- firewall-cmd --permanent --add-port=5432/tcp
- firewall-cmd --permanent --add-port=5432/udp
- firewall-cmd --reload

# 必要パッケージのインストール
- yum install -y gcc
- yum install -y readline-devel
- yum install -y zlib-devel

# PostgreSQLのインストール
- cd /usr/local/src/
- wget https://ftp.postgresql.org/pub/source/v11.3/postgresql-11.3.tar.gz
- tar xvfz postgresql-11.3.tar.gz
- cd postgresql-11.3/

# コンパイル
- ./configure
- make
- make install

# 起動スクリプト作成
- cp /usr/local/src/postgresql-11.3/contrib/start-scripts/linux /etc/init.d/postgres
- chmod 755 /etc/init.d/postgres
- chkconfig --add postgres
- chkconfig --list | grep postgres

# Postgresユーザ作成
- adduser postgres
