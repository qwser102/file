# Installing ACP CLI on Linux
$ chmod +x ac-linux-amd64
$ sudo cp ac-linux-amd64 /usr/local/bin/ac

# Verify the installation
$ ac version

# local user login to the platform
$ ac login <https://prod.acp.com>
Session name: prod
Username: user@example.com
Password: [hidden]
✔ Login successful. Welcome, user@example.com!

# LDAP user login to the platform
$ ac login <https://prod.acp.com> --idp <ldap-name>
Session name: prod
Username: user@example.com
Password: [hidden]
✔ Login successful. Welcome, user@example.com!

# Logout
$ ac logout <https://prod.acp.com> 

# Print the address of the control plane and cluster services
$ ac cluster-info

# List the clusters that ac knows about
$ ac config get-clusters

# Switch to existing context for workload-a cluster
$ ac config use-cluster <cluster name>


# Create a pod using the data in pod.yaml
$ ac create -f ./pod.yaml

# Create a pod based on the JSON passed into stdin
$ cat pod.json | ac create -f -

# create namespace with template
ac config use-cluster <cluster name>
ac process -f <ns-template.yaml> -p NAMESPACE=<namespace name> -p PROJECT=<project name> -p CLUSTER=<cluster name> |ac apply -f -

# Assign the namespace-developer-system role to user alice in project my-project
$ ac adm policy add-namespace-role-to-user namespace-developer-system alice --namespace my-namespace --project my-project --cluster business-1

# add kubernetes cluster role  view  to user alice
$ ac adm policy add-cluster-role-to-user view alice

# Assign the project-admin-system role to user alice in project my-project
$ ac adm policy add-project-role-to-user project-admin-system alice --project my-project

# add kubernetes role  view  to user alice
$ ac adm policy add-role-to-user view alice -n my-namespace


# Create a cluster role binding for user1, user2, and group1 using the cluster-admin cluster role
$ ac create clusterrolebinding cluster-admin --clusterrole=cluster-admin --user=user1 --user=user2 --group=group1

# Create a new config map named my-config based on folder bar
$ ac create configmap my-config --from-file=path/to/bar

# Create a new config map named my-config with specified keys instead of file basenames on disk
$ ac create configmap my-config --from-file=key1=/path/to/bar/file1.txt --from-file=key2=/path/to/bar/file2.txt

# Create a new config map named my-config with key1=config1 and key2=config2
$ ac create configmap my-config --from-literal=key1=config1 --from-literal=key2=config2

# Create a new config map named my-config from the key=value pairs in the file
$ ac create configmap my-config --from-file=path/to/bar

# Create a new config map named my-config from an env file
$ ac create configmap my-config --from-env-file=path/to/foo.env --from-env-file=path/to/bar.env

