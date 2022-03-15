# Get K8s Azure Resource ID
AKS_ID=$(az aks show -g KubernetesResources -n K8s-UWTSD-Students --query id -o tsv)

# Read all the users from the K8sStudents group
KUSERS=$(az ad group member list -g K8sStudents  --query [].userPrincipalName -o tsv)

# Get all the service principal names
declare -a users=($(echo $KUSERS| tr " " " "))

# Get namespace names
delimiter="_"
# Split the string into a bash array called users
declare -a users_sp=($(echo $KUSERS| tr "$delimiter" " "))
users_ns=()

# Iterate over the array creating namespaces for each student
i=0
for user in "${users_sp[@]}"
do
   if [ $(($i%2)) -eq 0 ]
   then
	    users_ns+=(${user//./-}-ns)
   fi

   i=$(($i+1))
done


i=0
for user in "${users[@]}"
do
	echo "Creating namespace ${users_ns[$i]} assigned to ${user}"
	#kubectl create namespace ${user}-ns
	#az role assignment create --role "Azure Kubernetes Service RBAC Writer" --assignee $user --scope "$AKS_ID/namespaces/${users_ns[$i]}"
	i=$(($i+1))
done