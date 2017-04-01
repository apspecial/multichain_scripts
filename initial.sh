# if error ocurrs, exit
set -e errexit


echo "initial...."
echo "only need create one time for a chain"
echo "please enter the chain name that you want to retrieve data from:"
read chainname

multichain-util create $chainname
multichaind $chainname -daemon  

