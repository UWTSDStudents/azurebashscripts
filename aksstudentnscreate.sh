# Read all the users from the K8sStudents group
KUSERS=$(az ad group member list -g K8sStudents  --query [].userPrincipalName -o tsv)

delimiter=" "
# Split the string into a bash array called users
declare -a array=($(echo $KUSERS | tr "$delimiter" " "))

# Iterate over the array
for user in "${users[@]}"
do
    echo "$user"
done

