# Server Preparation

This guide explains how to prepare your server using cloud-init before running the Ansible playbook.

## Cloud-Init Configuration

The cloud-init configuration is defined in [cloud-init.yml](https://github.com/humansoftware/self-host-saas-k3s/blob/main/cloud-init.yml). This configuration:
- Creates the ubuntu user with sudo access
- Changes SSH port to 2222
- Disables password authentication
- Installs required packages
- Configures the firewall

## Using Cloud-Init

### 1. Create the Configuration

1. Copy the cloud-init configuration:
   ```bash
   cp cloud-init.yml server-init.yml
   ```

2. Edit `server-init.yml`:
   - Replace `YOUR_SSH_PUBLIC_KEY` with your actual SSH public key

### 2. Apply Cloud-Init

#### For OVH (Recommended):
1. Go to OVH Control Panel > Dedicated Servers
2. Select your server
3. Go to "Network" tab
4. Under "User data", paste the contents of `server-init.yml`
5. Click "Apply"

#### For Other Providers:
- DigitalOcean: Use "User data" field when creating a Droplet
- AWS: Use "User data" field when launching an EC2 instance
- Other providers: Check their documentation for cloud-init support

## Verifying the Setup

1. Wait for the server to initialize (usually 1-2 minutes)

2. Connect to the server:
   ```bash
   ssh -p 2222 ubuntu@YOUR_SERVER_IP
   ```

3. Verify the configuration:
   ```bash
   # Check SSH port
   sudo netstat -tuln | grep 2222

   # Check firewall
   sudo ufw status
   ```

## Troubleshooting

If you cannot connect to the server:
1. Verify the SSH port (2222)
2. Check if the server is running
3. Verify your SSH key is correct
4. Check cloud-init logs: `sudo cat /var/log/cloud-init-output.log`

## Next Steps

After the server is prepared:
1. Update your inventory file with the new SSH port
2. Proceed with the [installation guide](installation.md) 