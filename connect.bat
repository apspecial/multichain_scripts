# if error ocurrs, exit
set -e errexit


echo "connecting...."
echo "please enter the ip address that you want to connect:"
read ipaddr
multichaind $ipaddr -daemon

#save the ipaddress:port into a file, for the convenience of later use
echo $ipaddr >> ipaddress.info

echo -e "\nplease waiting for the peer server to grant your connection.Press enter to continue"
read ok

# get the name the chain from ipaddress
chainname=$(echo $ipaddr | awk -F'@' '{print $1}')
multichaind $chainname -daemon
