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

## Verification

Each component has its own verification steps in its documentation. After installation, verify that all core components are working correctly.

## Next Steps

See the documentation index for additional guides and next steps. 