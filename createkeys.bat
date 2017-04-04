:: if error ocurrs, exit
$ErrorActionPreference = "Stop"


::create streams for exchange the data
echo -e "create 3 sreams on the chain by this sever...\n"
echo "please enter the chain name that you want to create:"
set /p chainname=""

multichain-cli %chainname% create stream pubkeys true || true
multichain-cli %chainname% create stream items true || true
multichain-cli %chainname% create stream access true || true

::get the address of this sever
multichain-cli %chainname% listaddresses > temp.info

::acquire the operating address
myaddr=$(cat temp.info | grep -E 'address' |awk -F':' '{print $2}'|grep -o '[0-9A-Za-z]*'|tail -n 1)

::create and store the private key
mkdir -p ~/.multichain/%chainname%/stream-privkeys/
openssl genpkey -algorithm RSA -out ~/.multichain/%chainname%/stream-privkeys/$myaddr.pem


::create public key and store the public key
pubkeyhex=$(openssl rsa -pubout -in ~/.multichain/%chainname%/stream-privkeys/$myaddr.pem | xxd -p -c 9999)
::echo $pubkeyhex > publickey.info

::pulish public key
multichain-cli %chainname% publishfrom $myaddr pubkeys '' $pubkeyhex

echo "create keys successfully"
