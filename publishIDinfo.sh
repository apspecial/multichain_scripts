# if error ocurrs, exit
set -e errexit

echo -e "If you see the success at the end of outcome, it is success.Otherwise it has errors\n"
echo "connecting...."
#echo "please enter the ip address (example:testchainx@192.168.31.207:7753 ) that you want to connect:"
#read ipaddr

# pause for granted by another server.
echo -e "\nplease waiting for the peer server to grant your permissions,press enter for finish.\
If the server has alreay granted, just press enter"
read ok

# get the name the chain from ipaddress
#chainname=$(echo $ipaddr | awk -F'@' '{print $1}')
echo "please enter the chain name that you want to retrieve data from:"
read chainname

# get data contains the address of this server
multichain-cli $chainname getaddresses > temp.info


#acquire the operating address of this server
myaddr=$(cat temp.info|grep -o '[0-9A-Za-z]*'|tail -n 1)



# input the orginal data need to encrpyt 
echo -e "\nPlease enter the file name(example:~/multichain/myid.info) you want to transfer"
read filename

#create password for encrpytion of data
password=$(openssl rand -base64 48)

#encrypt the input file
cipherhex=$(openssl enc -aes-256-cbc -in $filename -pass pass:$password | xxd -p -c 99999)

#publish the data into stream: items
multichain-cli $chainname subscribe '["items","pubkeys"]'
multichain-cli $chainname publishfrom $myaddr items  secret-info $cipherhex
multichain-cli $chainname liststreamitems items > temp.info

#get txid from items
txid_info1=$(cat temp.info | grep -E 'txid' | tail -n 1 |awk -F':' '{print $2}'|grep -o '[0-9A-Za-z]*')


# create a directory for item password, and store the password for future reference:
mkdir -p ~/.multichain/$chainname/stream-passwords/
echo $password > ~/.multichain/$chainname/stream-passwords/$txid_info1.txt


#Publish the encrypted password
# first subscribe to the pubkeys stream, and then retrieve the first server’s RSA public key from that stream:
multichain-cli $chainname subscribe pubkeys
multichain-cli $chainname liststreamitems pubkeys > temp.info

#get the address which publish the public key
pubaddr=$(cat temp.info|grep -v ':' |grep -o '[0-9A-Za-z]*'|tail -n 1)

#get the txid and vout of pubkeys stream
multichain-cli $chainname liststreampublisheritems pubkeys $pubaddr true 1 > temp.info
txid_pubkey=$(cat temp.info | grep -E 'txid' |awk -F':' '{print $2}'|grep -o '[0-9A-Za-z]*'|tail -n 1)
vout_pubkey=$(cat temp.info | grep -E 'vout' |awk -F':' '{print $2}'|grep -o '[0-9A-Za-z]*'|tail -n 1)

#store pubkey
multichain-cli $chainname gettxoutdata $txid_pubkey $vout_pubkey | tail -n 1 | xxd -p -r > pubkey.pem

#encrypt the password
keycipherhex=$(echo $password | openssl rsautl -encrypt -inkey pubkey.pem -pubin| xxd -p -c 9999)


#create the key of the publishing item
label=${txid_info1}"-"$pubaddr

# publish the encrypted password
multichain-cli $chainname publishfrom $myaddr access $label $keycipherhex

# if there is no error, then the next words will exist.
echo -e "\nthe access channel ready, can be retrieved from blockchain. \nSuccess!"

