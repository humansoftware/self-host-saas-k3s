# Installation Guide

This guide will walk you through the installation of Self-Host SaaS K3s on your server.

## Preparation

1. Ensure you have completed all [prerequisites](prerequisites.md)
2. Prepare your server using [cloud-init](server-preparation.md)
3. Have your configuration files ready

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/humansoftware/self-host-saas-k3s.git
cd self-host-saas-k3s
```

### 2. Configure Secrets

1. Copy the secrets template:
   ```bash
   cp group_vars/all/secrets.example.yml group_vars/all/secrets.yml
   ```

2. Edit `group_vars/all/secrets.yml` with your values. See [secrets.example.yml](https://github.com/humansoftware/self-host-saas-k3s/blob/main/group_vars/all/secrets.example.yml) for the complete list of required properties.

### 3. Update Inventory

1. Copy the sample inventory:
   ```bash
   cp inventory.sample.yml inventory.yml
   ```

2. Edit `inventory.yml` with your server details. See [inventory.sample.yml](https://github.com/humansoftware/self-host-saas-k3s/blob/main/inventory.sample.yml) for the complete example.

   Make sure to:
   - Update `host_public_ip` with your server's IP address
   - Set `ansible_port` to 2222 (the new SSH port configured by cloud-init)

### 4. Install Dependencies

```bash
ansible-galaxy install -r requirements.yml
```

### 5. Run the Playbook

```bash
ansible-playbook -i inventory.yml playbook.yml 
```

## Note: Enabling SSH Tunnel Persistence

If you want the SSH tunnel to persist even after you log out, you must enable user lingering on your system. This allows user services (like the k3s-tunnel systemd user service) to continue running after logout.

To enable lingering for your user, run the following command as root:

```sh
sudo loginctl enable-linger <your-username>
```

Replace `<your-username>` with your actual Linux username. This step is not performed automatically by the playbook and must be done manually if persistent tunnels are required.

## Using a Separate Repository for Customization (Recommended)

For production or custom environments, it is best practice to keep your sensitive and environment-specific files (such as `inventory.yml`, `secrets.yml`, and `cloud-init.yaml`) in a separate private repository. This keeps your secrets and customizations out of the main project and makes upgrades and collaboration safer.

### Example Directory Structure for Your Private Repo

```
human_infra/
├── cloud-init.prod.yaml
├── inventory.prod.yml
├── secrets.prod.yml
└── README.md
```

### Running Ansible with Your Custom Files

From your private repo (e.g., `human_infra`), run:

```sh
ansible-playbook -i inventory.prod.yml \
  ../self-host-saas-k3s/playbook.yml \
  -e @secrets.prod.yml \
  -e cloud_init_file=cloud-init.prod.yaml
```

- Adjust the paths as needed for your environment.
- The `cloud_init_file` variable can be used in your playbook or roles to reference the correct cloud-init file.

**Why use this pattern?**
- Keeps secrets and sensitive configs out of the main repo
- Makes it easier to upgrade the main project without overwriting your custom files
- Lets you share the main repo publicly, but keep your infrastructure private

See the `samples/` folder for templates.

## Verification

Each component has its own verification steps in its documentation. After installation, verify that all core components are working correctly.

## Next Steps

See the documentation index for additional guides and next steps.