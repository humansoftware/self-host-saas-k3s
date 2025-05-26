# self-host-saas-k3s


This repository contains an Ansible playbook to set up a Kubernetes environment on a bare metal server running Ubuntu 24.04. It automates the installation and configuration of the following components:

- **k3s**: A lightweight Kubernetes distribution.
- **Container Registry**: A private container registry with integration and configuration for k3s.

## Ansible Installation

If you don't have Ansible installed, you can set it up on your local machine with the following commands:

```bash
sudo apt update
sudo apt install -y ansible
ansible-galaxy --version
```

For more details, refer to the [Ansible installation guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).

## Features

- Automated installation of k3s.
- Deployment and configuration of a private container registry.
- Installation of Longhorn for persistent storage.
- Backup configuration for Longhorn to Backblaze.

## Prerequisites

- A bare metal server running Ubuntu 24.04.
- Ansible installed on your local machine.
- SSH access to the target server with sudo privileges.
- **Python 3** must be installed on your local machine (the Ansible control node).
- The **kubernetes Python client** library is required for Ansible to manage Kubernetes resources:
    ```bash
    pip install kubernetes openshift
    ```
- **Helm 3** must be installed on your local machine:
    - Use your package manager (e.g., `sudo apt install helm` or `sudo pacman -S helm`), or
    - Download the binary from the [Helm releases page](https://github.com/helm/helm/releases) and place it in `/usr/local/bin/`.


### SSH Key Setup

Make sure your SSH public key is added to the `authorized_keys` of the user you will use to connect (e.g., `ubuntu`) on your server.  
This allows Ansible to connect without a password.

Example (from your local machine):
```bash
ssh-copy-id ubuntu@YOUR_SERVER_PUBLIC_IP
```

Or manually add the contents of your `~/.ssh/id_rsa.pub` to `/home/ubuntu/.ssh/authorized_keys` on the server.

**Note:**  
You can specify which SSH key to use by setting the `ansible_ssh_private_key_file` variable in your `inventory.yml` or host/group vars.

## Setting Up Required Secrets and Variables

Before running the playbook, you must configure your secrets:

1. **Copy the secrets template and edit it:**
    ```bash
    cp group_vars/all/secrets.example.yml group_vars/all/secrets.yml
    ```
    Open `group_vars/all/secrets.yml` and fill in all required values, such as your server's public IP (`host_public_ip`), registry credentials, and any other sensitive information.

    Example:
    ```yaml
    host_public_ip: "YOUR_SERVER_PUBLIC_IP"
    registry_password: "your-registry-password"
    # ...other secrets...
    ```

2. **Defaults and other variables:**
    - The file `group_vars/all/variables.yml` contains default values for most settings. You usually do **not** need to edit this file unless you want to override a default.

**Note:**  
All sensitive or environment-specific values should be set in `group_vars/all/secrets.yml`.  
Do **not** commit your `secrets.yml` file to version control.


## Usage

1. Clone this repository:
    ```bash
    git clone https://github.com/your-username/self-host-saas-k3s.git
    cd self-host-saas-k3s
    ```

2. Copy `group_vars/all/secrets.example.yml` to `group_vars/all/secrets.yml` and edit the secrets needed. Also, review `group_vars/all/variables.yml` to make sure it is adequate to your needs.

3. Update the `inventory.ini` file with your server details.

4. Run the playbook:
    ```bash
    ansible-galaxy install -r requirements.yml
    ansible-playbook -i inventory.yml playbook.yml --extra-vars action=install
    ```
5. For security reasons, the kube port set in api_port in the inventory is not open by default in the firewall. You can set up a local ssh tunnel to run local kubectl commands:
    ```bash
    ssh -N -L 6443:localhost:6443 ubuntu@"YOUR_PUBLIC_IP" &
    ```
    Alternatively, you can set the firewall config `firewall_open_k3s_ports`, which defaults to false.
       
6. Verify the installation:

 - Check that k3s is running: `kubectl get nodes`
 - Ensure the container registry is accessible.
 - Confirm Longhorn is installed and backups are configured.

## Local Testing with Multipass VM

For local development and testing, this repository provides helper scripts:

- **run_test_vm.sh**: Provisions and starts a Multipass VM, then runs the Ansible playbook against it.
- **vmkubectl.sh**: Allows you to run `kubectl` commands against the Kubernetes cluster running inside the VM by automatically setting up an SSH tunnel and using the correct kubeconfig.

**Example usage for local testing:**
```bash
./run_test_vm.sh
./vmkubectl.sh get nodes
```

> **Note:**  
> These scripts are intended for local testing only.  
> For production or real server deployments, follow the main instructions below to run Ansible directly against your target host.

---

## Configuration

- **Container Registry**: Update the registry configuration in the playbook to match your requirements.
- **Longhorn**: Customize the backup settings to use your Backblaze credentials.

## Troubleshooting

- If the playbook fails, check the Ansible logs for detailed error messages.
- Ensure all dependencies are installed and the server meets the prerequisites.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

## Acknowledgments

- [k3s](https://k3s.io/)
- [Longhorn](https://longhorn.io/)
- [Backblaze](https://www.backblaze.com/)