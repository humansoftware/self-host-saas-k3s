# k3s-platform-ansible

This repository contains an Ansible playbook to set up a Kubernetes environment on a bare metal server running Ubuntu 24.04. It automates the installation and configuration of the following components:

- **k3s**: A lightweight Kubernetes distribution.
- **Container Registry**: A private container registry with integration and configuration for k3s.

## Ansible Installation

If you don't have Ansible installed, you can set it up on your local machine with the following commands:

```bash
sudo apt update
sudo apt install -y ansible
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

## Usage

1. Clone this repository:
    ```bash
    git clone https://github.com/your-username/k3s-platform-ansible.git
    cd k3s-platform-ansible
    ```

2. Create a `secrets.ini` file with your sensitive information:
    ```ini
    [secrets]
    registry_username=your_registry_username
    registry_password=your_registry_password
    backblaze_key_id=your_backblaze_key_id
    backblaze_application_key=your_backblaze_application_key
    ```

3. Update the `inventory.ini` file with your server details and reference the `secrets.ini` file.

4. Run the playbook:
    ```bash
    ansible-playbook playbook.yml -i inventory.ini
    ```
5. Verify the installation:

 - Check that k3s is running: `kubectl get nodes`
 - Ensure the container registry is accessible.
 - Confirm Longhorn is installed and backups are configured.

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