# Get K8s Azure Resource ID
AKS_ID=$(az aks show -g KubernetesResources -n K8s-UWTSD-Students --query id -o tsv)

# Read all the users from the K8sStudents group
KUSERS=$(az ad group member list -g K8sStudents  --query [].userPrincipalName -o tsv)

# Get all the service principal names
declare -a users=($(echo $KUSERS| tr " " " "))

# Get namespace names
delimiter="_"
# Split the string into a bash array called users
# e.g. fred_student.uwtsd.ac.uk#EXT#@lee...cros
# is split into two strings "fred" and "student.uwtsd.ac.uk#EXT#@lee...cros"
declare -a users_sp=($(echo $KUSERS| tr "$delimiter" " "))
users_ns=()

# Iterate over the array creating namespaces for each student
i=0
for user in "${users_sp[@]}"
do
   # We split the string, so skip every second string
   if [ $(($i%2)) -eq 0 ]
   then
		# Convert . to - before create namespace name
		# e.g. fred.1234 becomes fred-1234-ns
	    users_ns+=(${user//./-}-ns)
   fi

   i=$(($i+1))
done

# Get a list of all the created namespace names
ns=$(kubectl get ns -o name)
declare -a ns=($(echo $ns| tr " " " "))

i=0
for user in "${users[@]}"
do
	if [[ ${ns[*]} =~ "namespace/${users_ns[$i]}" ]]
	then 
		echo "Deleting namespace ${users_ns[$i]} assigned to ${user}"
		kubectl delete namespace ${users_ns[$i]}
	else 
		echo "Namespace ${users_ns[$i]} does not exist"; 
	fi
	
	i=$(($i+1))
done