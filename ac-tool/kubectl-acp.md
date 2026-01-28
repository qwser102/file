# ACP CLI Tools Usage Guide

## 1. Introduction

This guide introduces the essential CLI tools available on the ACP platform: `kubectl`, `kubectl-acp` (a `kubectl` plugin), `helm`, and `roxctl`. The document will help you quickly get started, automate common tasks, and efficiently troubleshoot issues.

---

## 2. Tool Overview

| Tool            | Purpose                                               |
| --------------- | ----------------------------------------------------- |
| **kubectl**     | Core Kubernetes resource operations                   |
| **kubectl-acp** | ACP plugin for login, logout, and context switching   |
| **helm**        | Render and deploy Kubernetes applications via charts  |
| **roxctl**      | Perform security scans and manage policies (StackRox) |

---

## 3. Installation & Configuration

### 3.1 kubectl

Follow the official Kubernetes documentation to install `kubectl` on your system: [Official guide](https://kubernetes.io/docs/tasks/tools/)

### 3.2 kubectl-acp

`kubectl-acp` is a plugin for `kubectl` that streamlines authentication and context management for ACP. After downloading the binary, you can install it as follows:

```bash
# macOS/Linux binary installation
chmod +x kubectl-acp-<os>-<arch>
sudo mv kubectl-acp-<os>-<arch> /usr/local/bin/kubectl-acp
```

#### Core Commands:

##### 1. **Login to ACP**

```bash
kubectl acp login <acp-address> [flags]
```

**Available Flags:**

| Flag                          | Description                                            |
| ----------------------------- | ------------------------------------------------------ |
| `--idp <provider>`            | Identity provider to use                               |
| `-u, --username <username>`   | Username for authentication                            |
| `-p, --password <password>`   | Password for authentication                            |
| `-c, --cluster <cluster>`     | Name of the cluster to set as the default after login  |
| `-n, --namespace <namespace>` | Name of the namespace to use with the selected cluster |

##### 2. **Logout**

```bash
kubectl acp logout
```

Logs out and clears cached ACP credentials.

##### 3. **Set Cluster Context**

```bash
kubectl acp set-cluster <cluster-name>
```

Switches your active context to the specified ACP cluster.

##### 4. **Set Namespace Context**

```bash
kubectl acp set-namespace <namespace-name>
```

Switches your active context to the specified namespace.

As an alternative  you can also use `kubectl config set-context --current --namespace <namespace-name>` to switch the namespace in the current context.

To see current context and all available contexts use `kubectl config get-contexts`.


##### 5. **Push Image to Registry**

```bash
kubectl acp push <image>
```

### 3.3 roxctl

roxctl is a command-line tool for managing security policies and scanning images in ACP through StackRox. It provides a simple interface for performing security scans, generating Software Bill of Materials (SBOM), and checking images for policy violations.

Follow these instructions to [Install roxctl](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_security_for_kubernetes/4.7/html-single/roxctl_cli/index#installing-cli-on-linux_installing-roxctl-cli).

### 3.4 Helm

Helm is a package manager for Kubernetes that allows you to define, install, and manage Kubernetes applications. It uses a packaging format called charts.

Follow these instructions to [Install Helm](https://helm.sh/docs/intro/install/).

---

## 4. Common Scenarios & Examples

### 4.1 Resource Management (`kubectl` and `helm`)

```bash
# Step 1: Login to ACP
kubectl acp login <acp-address> --idp acp-ldap -u <username> -p <password> --cluster <cluster-name> --namespace <namespace>

# Step 2: Push image (if needed)
kubectl acp push <image>

# Step 3: List pods in current namespace
kubectl get pods

# Step 4: Render Helm template
helm template my-app ./charts/my-app --set image.tag=1.0 > application.yaml

# Step 5: Apply application manifest
kubectl apply -f application.yaml

# Step 6: Logout when finished
kubectl acp logout
```

### 4.2 Security Scanning & Policies (`roxctl`)

`ROX_ENDPOINT` and `ROX_API_TOKEN` are required for `roxctl` commands. You can get them from the Platform Administrator and set them as environment variables or pass them directly in the command line.

```bash
# Step 1: Set environment variables
export ROX_API_TOKEN=<api_token>
export ROX_ENDPOINT=<address>:<port_number>

# Step 2: Scan an image for vulnerabilities
roxctl image scan --image registry.acp.local/my-app:1.0

# Step 3: Generate SBOM (Software Bill of Materials)
roxctl image sbom --image docker.io/library/nginx:latest > sbom.json

# Step 4: Check images for build time policy violations
roxctl image check --image registry.acp.local/my-app:1.0
```
