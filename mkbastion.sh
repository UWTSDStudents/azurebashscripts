#!/bin/bash

usage() {
# `cat << EOF` This means that cat should stop reading when EOF is detected
cat << EOF  
Usage: ./mkbastion.sh --resource-group mkvm-resource-gp --name myBastionHost
		--vnet myVNet --subnet-name azureBastionSubnet
		--subnet-prefix 10.1.1.0/24 --public-ip-name myBastionIP
		--location ukwest 
Install Pre-requisites for EspoCRM with docker in Development mode
-g|--resource-group		The azure resource group
--vnet-name				The vNet to which the Bastion is to be connected.
--subnet-prefix			The Bastion subnet IP prefix e.g. 10.0.0.1/24
--location				The region e.g. ukwest
OPTIONAL
-h|--help				Display help
-n|--name				The name of the bastion
--public-ip-name		The name of the public IP address 

EOF
# EOF is found above and hence cat command stops reading. This is equivalent to echo but much neater when printing out.
}

group="";
vnet="";
location="";
name="myBastionHost";
publicIP="myBastionIP";
subnetPrefix="";

# $@ is all command line parameters passed to the script.
# -o is for short options like -v
# -l is for long options with double dash like --version
# the comma separates different long options
# -a is for long options with single dash like -version
options=$(getopt -l "help,resource-group:,public-ip-name:,name:,vnet:,subnet-name:,subnet-prefix:,location:" -o "hg:n:l:" -a -- "$@")

# set --:
# If no arguments follow this option, then the positional parameters are unset. Otherwise, the positional parameters 
# are set to the arguments, even if some of them begin with a ‘-’.
eval set -- "$options"

while true
do
case $1 in
-h|--help) 
    usage
    exit 0
    ;;
# -v|--version) 
    # shift
    # export version=$1
    # ;;
-g|--resource-group)
    shift;
    group=$1
    ;;
--public-ip)
	shift;
    publicIP=$1
    ;;
-n|--name)
	shift;
    name=$1
    ;;
--vnet)
	shift;
    vnet=$1
    ;;
--subnet-prefix)
	shift;
    subnetPrefix=$1
    ;;
-l|--location)
	shift;
    location=$1
    ;;
--)
	# positional parameters
    shift
	# if [ $# -eq 2 ]; then
		# echo "param $1";
		# shift;
		# echo "param2 $1";
		# shift;
	# else
		# echo "No arguments provided"
		# exit 1
	# fi
    break;;
esac
shift
done

if [ -z "$group" ]
then
	echo "You must specify a resource group";
	exit 1;
fi

if [ -z "$vnet" ]
then
	echo "You must specify a vNet";
	exit 1;
fi

if [ -z "$subnetPrefix" ]
then
	echo "You must specify a subnet IP prefix";
	exit 1;
fi

if [ -z "$location" ]
then
	echo "You must specify a location";
	exit 1;
fi

echo "Creating Public IP $publicIP";
az network public-ip create --resource-group $group --name $publicIP --sku Standard
echo "Creating AzureBastionSubnet subnet with IP prefix $subnetPrefix";
az network vnet subnet create --resource-group $group --name AzureBastionSubnet --vnet-name $vnet --address-prefixes $subnetPrefix
echo "Creating Bastion $name connecting to vNet $vnet in $location";
az network bastion create --resource-group $group --name $name --public-ip-address $publicIP --vnet-name $vnet --location $location

bastionIP=$(az network public-ip show --resource-group myvm-resource-gp --name myBastionIP --query ipAddress --output tsv);
echo "To connect to the Bastion use the IP address $bastionIP";

