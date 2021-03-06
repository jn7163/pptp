# 脚本在centos_6.8_x86_64下测试成功

rpm -Uvh http://poptop.sourceforge.net/yum/stable/packages/pptpd-1.4.0-1.el6.x86_64.rpm
yum -y install pptpd vim

cp /etc/ppp/options.pptpd /etc/ppp/options.pptpd.bak
echo "ms-dns 8.8.8.8" >> /etc/ppp/options.pptpd
echo "ms-dns 8.8.4.4" >> /etc/ppp/options.pptpd
cp /etc/ppp/chap-secrets /etc/ppp/chap-secrets.bak
echo "1 pptpd 1 *" >> /etc/ppp/chap-secrets
cp /etc/pptpd.conf /etc/pptpd.conf.bak
echo "localip 192.168.9.1" >> /etc/pptpd.conf
echo "remoteip 192.168.9.11-30" >> /etc/pptpd.conf

# 内核转发
sed 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf
/sbin/sysctl -p

# iptables转发
iptables -F
iptables -t nat -A POSTROUTING -o eth0 -s 192.168.9.0/24 -j MASQUERADE
service iptables save
service iptables restart

# 设置mtu，否则win连接vpn打开youtube、facebook等网站会有问题——打开google并不会
sed -i '16c /sbin/ifconfig ppp0 mtu 1472' /etc/ppp/ip-up

# 开机自启
chkconfig pptpd on
service pptpd start
