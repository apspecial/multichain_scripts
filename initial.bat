:: if error ocurrs, exit
$ErrorActionPreference = "Stop"

PATH=C:/multichain
echo "initial...."
echo "only need create one time for a chain"
echo "please enter the chain name that you want to retrieve data from:"
set /p chainname=""

::create chain
multichain-util create %chainname%
::start chain
multichaind %chainname% -daemon  

