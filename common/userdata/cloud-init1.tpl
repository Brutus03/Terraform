#cloud-config

runcmd:
# download the secondary vnic script
- wget -O /usr/local/bin/secondary_vnic_all_configure.sh https://docs.cloud.oracle.com/iaas/Content/Resources/Assets/secondary_vnic_all_configure.sh
- chmod +x /usr/local/bin/secondary_vnic_all_configure.sh
- sleep 60
- /usr/local/bin/secondary_vnic_all_configure.sh -c

- yum update -y
- echo "Hello World.  The time is now $(date -R)!" | tee /root/output.txt

- echo '################### webserver userdata begins #####################'
- touch ~opc/userdata.`date +%s`.start
# echo '########## yum update all ###############'
# yum update -y
- echo '########## basic webserver ##############'
- yum install -y httpd
- systemctl enable  httpd.service
- systemctl start  httpd.service
- echo '<html><head></head><body><pre><code>' > /var/www/html/index.html
- hostname >> /var/www/html/index.html
- echo '' >> /var/www/html/index.html
- cat /etc/os-release >> /var/www/html/index.html
- echo '</code></pre></body></html>' >> /var/www/html/index.html
- firewall-offline-cmd --add-service=http
- systemctl enable  firewalld
- systemctl restart  firewalld
- touch ~opc/userdata.`date +%s`.finish
- echo '################### webserver userdata ends #######################'
