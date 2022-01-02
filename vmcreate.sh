#!/bin/bash

usage() {
# `cat << EOF` This means that cat should stop reading when EOF is detected
cat << EOF  
Usage: ./vmcreate -g myvm-resource-gp
Install Pre-requisites for EspoCRM with docker in Development mode
-g|--resource-group		The azure resource group
OPTIONAL
-h|--help				Display help
--vm-prefix				The VM name prefix used when each VM is created
						e.g "vmName" becomes "vmName1", "vmName2", etc.
--nic-prefix			The NIC name prefix used for each VM NIC
						e.g. "myNIC" becomes "myNIC1", "myNIC2", etc.
--vnet-name				The vnet-name
--subnet				The subnet
--nsg-name				The name of the NSG applied to each VM.
-c|vm-count				The number of VMs to create.
EOF
# EOF is found above and hence cat command stops reading. This is equivalent to echo but much neater when printing out.
}

group="";
vmprefix="myVM";
nicprefix="myNic";
vnet="";
subnet="myBackEndSubnet";
nsgname="myNSG";
vmcount=1;

# $@ is all command line parameters passed to the script.
# -o is for short options like -v
# -l is for long options with double dash like --version
# the comma separates different long options
# -a is for long options with single dash like -version
options=$(getopt -l "help,resource-group:,vm-prefix:,nic-prefix:,vnet:,subnet:,vm-count:,nsg-name:" -o "hg:c:" -a -- "$@")

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
--vm-prefix)
	shift;
    vmprefix=$1
    ;;
--nic-prefix)
	shift;
    nicprefix=$1
    ;;
--vnet)
	shift;
    vnet=$1
    ;;
--subnet)
	shift;
    subnet=$1
    ;;
--nsg-name)
	shift;
    nsgname=$1
    ;;
-c|--vm-count)
	shift;
    vmcount=$1
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


for (( i=1; i<=$vmcount; i++ ))
do
	vm_name="$vmprefix$i";
	nic_name="$nicprefix$i";
	echo "Creating NIC with $nic_name";
	az network nic create --resource-group $group --name $nic_name --vnet-name $vnet --subnet $subnet --network-security-group $nsgname;

	echo "Creating VM $vm_name with NIC $nic_name";
	az vm create --resource-group $group --name $vm_name --nics $nic_name --image Ubuntu --admin-username azureuser --no-wait;

	echo "Creating VM Extension for VM $vm_name";
	az vm extension set --resource-group $group --vm-name $vm_name --publisher Microsoft.Azure.Extensions --name CustomScript --version 2.0 --protected-settings '{"fileUris":["https://raw.githubusercontent.com/Azure-Samples/compute-automation-configurations/master/automate_nginx.sh"], "commandToExecute":"./automate_nginx.sh"}';
done
