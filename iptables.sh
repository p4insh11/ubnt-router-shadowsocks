#!/bin/bash
# Maintainer MMX
# Email 4isnothing@gmail.com
# SERVER_IP
add_rules()
{
curl 'https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt' > cn_ipv4.list
wait
CHAIN_NAME='BYPASSLIST'

del_rules
# Add new ipset
ipset destroy chnlist
ipset -N chnlist hash:net maxelem 65536

echo 'ipset processing...'
for ip in $(cat cn_ipv4.list)
do
  ipset add chnlist $ip
done
echo 'ipset done.'

# Add new chain $CHAIN_NAME
iptables -t nat -N $CHAIN_NAME

# Add server IP
if [ -n "$SERVER_IP" ]
then
  echo "Your server IP is $SERVER_IP"
else
  read -p "Please set server IP:" SERVER_IP
fi
iptables -t nat -A $CHAIN_NAME -d $SERVER_IP -j RETURN

# LAN IP
iptables -t nat -A $CHAIN_NAME -d 0.0.0.0/8 -j RETURN
iptables -t nat -A $CHAIN_NAME -d 10.0.0.0/8 -j RETURN
iptables -t nat -A $CHAIN_NAME -d 127.0.0.0/8 -j RETURN
iptables -t nat -A $CHAIN_NAME -d 169.254.0.0/16 -j RETURN
iptables -t nat -A $CHAIN_NAME -d 172.16.0.0/12 -j RETURN
iptables -t nat -A $CHAIN_NAME -d 192.168.0.0/16 -j RETURN
iptables -t nat -A $CHAIN_NAME -d 224.0.0.0/4 -j RETURN
iptables -t nat -A $CHAIN_NAME -d 240.0.0.0/4 -j RETURN

# ipset match
iptables -t nat -A $CHAIN_NAME -p tcp -m set --match-set chnlist dst -j RETURN

# redirect
iptables -t nat -A $CHAIN_NAME -p tcp -j REDIRECT --to-ports 1080

# Add to prerouting chain
iptables -t nat -A PREROUTING -p tcp -j $CHAIN_NAME

echo 'Done.'
}

del_rules()
{
ipset destroy chnroute
iptables -t nat -F $CHAIN_NAME
iptables -t nat -X $CHAIN_NAME
echo 'Del_rules Done.'
}

backup_iptables()
{
iptables-save > iptables.conf
echo 'Done.'
}

restore_iptables()
{
iptables-restore < iptables.conf
echo 'Done.'
}

"$@"

