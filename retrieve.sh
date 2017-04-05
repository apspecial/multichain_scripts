# if error ocurrs, exit
set -e errexit

echo "please enter the chain name that you want to retrieve data from:"
read chainname



# subscirbe the streams for next operation
multichain-cli $chainname subscribe '["items","access","pubkeys"]'

#get txid and vout of items
multichain-cli $chainname liststreamitems items true 1 >temp.info
txid_items=$(cat temp.info | grep -E 'txid' | tail -n 1 |awk -F':' '{print $2}'|grep -o '[0-9A-Za-z]*')
vout_items=$(cat temp.info | grep -E 'vout' | tail -n 1 |awk -F':' '{print $2}'|grep -o '[0-9A-Za-z]*')

#get the address which publishes the public keys
multichain-cli $chainname liststreampublishers pubkeys >temp.info
add0=$(cat temp.info | grep -E 'publisher' | tail -n 1 |awk -F':' '{print $2}'|grep -o '[0-9A-Za-z]*')

#get the encrypted data which published in the stream items
cipherhex=$(multichain-cli $chainname gettxoutdata $txid_items $vout_items | tail -n 1)

#obtain the key of the access
label=${txid_items}"-"$add0

#get the txid and vout of the access 
multichain-cli $chainname liststreamkeyitems access $label true > temp.info
txid_access=$(cat temp.info | grep -E 'txid' | tail -n 1 |awk -F':' '{print $2}'|grep -o '[0-9A-Za-z]*')
vout_access=$(cat temp.info | grep -E 'vout' | tail -n 1 |awk -F':' '{print $2}'|grep -o '[0-9A-Za-z]*')

#get the encrypted password
keycipherhex=$(multichain-cli $chainname gettxoutdata $txid_access $vout_access | tail -n 1)

#decrypt the password
password=$(echo $keycipherhex | xxd -p -r | openssl rsautl -decrypt -inkey ~/.multichain/$chainname/stream-privkeys/$add0.pem)

#decrypt the orginal data
echo -e "waiting for the data from the peer, enjoy!\n"
echo -e "=====BEGIN THE DATA========="
echo $cipherhex | xxd -p -r | openssl enc -d -aes-256-cbc -pass pass:$password
echo -e "=========EOF================\n"
echo -e "\nSuccessfully decryption."


