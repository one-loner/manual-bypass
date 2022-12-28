#!/bin/bash
echo installing packets
apt-get install -y tor obfs4proxy shadowsocks-libev shadowsocks-v2ray-plugin simple-obfs privoxy dante-server
ip a
echo -------------------------------------------------------------------------------------------------------
echo Enter external ip-addres of the server:
read ip
echo Enter external interface name:
read intname
echo Enter ports of services. Warning: use port more that 1024 and do not use the same ports for different services.
echo -------------------------------------------------------------------------------------------------------
echo Enter port for obfs4 tor bridge:
read obfs4port
echo Enter port for shadowsocks proxy:
read ssport
echo Enter port for http/https proxy:
read httpport
echo Enter port for socks5 proxy:
read socks5port
sed  s/ExternalIP:port/$ip:$obfs4port/ torrc.sample>torrc
sed s/ExternalIP:port/$ip:$httpport/ privoxy.config.sample>privoxy.config
sed s/ExternalIP/$ip/ shadowsocks.config.sample>shadowsocks.config
sed -i s/Port/$ssport/ shadowsocks.config

sed s/ExternalIP/$ip/ shadowsocks-client.config.sample>shadowsocks-client.config
sed -i s/Port/$ssport/ shadowsocks-client.config

sed s/interface/$intname/ danted.conf.sample >danted.conf
sed -i s/Port/$socks5port/ danted.conf

#Loading configurations
cat privoxy.config>/etc/privoxy/config
cat danted.conf>/etc/danted.conf
cat shadowsocks.config>/etc/shadowsocks-libev/config.json
cat torrc>/etc/tor/torrc
cat shadowsocks.servce> /etc/systemd/system/shadowsocks.service
systemctl restart privoxy
systemctl restart danted
systemctl restart tor
systemctl enable privoxy
systemctl enable danted
systemctl enable tor

systemctl daemon-reload
systemctl start shadowsocks
systemctl enable shadowsocks

echo Proxy settings:
echo http/https proxy $ip:$httpport
echo socks5proxy      $ip:$socks5port
echo -------------------------------------------
echo shadowsocks client configuretion file:
cat shadowsocks-client.config
echo to config obfs4 in tor client enther how a bridge:
tail -n 1 /var/lib/tor/pt_state/obfs4_bridgeline.txt>obfs4
sed -i s/<IP ADDRESS>:<PORT>/$ip:$obfs4port/ obfs4
fp=$(cat /var/lib/tor/fingerprint | awk '{print $2}')
sed -i s/<FINGERPRINT>/$fp/ obfs4
cat obfs4
