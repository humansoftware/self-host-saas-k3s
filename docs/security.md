# Security Configuration

Self-Host SaaS K3s applies several security best practices by default. You can customize these settings by editing the relevant variables in your `group_vars/all/secrets.yml` file.

## Key Security Variables

Set these variables in `secrets.yml` to control security features:

- **`ssh_public_key_to_authorize_on_target`**:  
  Path to the SSH public key on your control machine. This key will be authorized for the `ubuntu` user on the server.  
  _Example:_  
  ```yaml
  ssh_public_key_to_authorize_on_target: "{{ lookup('env', 'HOME') }}/.ssh/id_rsa.pub"
  ```

- **`firewall_open_k3s_ports`**:  
  Set to `true` to allow access to the K3s API port (default: 6443) from the internet.  
  _Default:_ `false` (K3s API is not exposed externally).

## Firewall Rules

The firewall is managed using UFW and is configured with the following rules:

- **Default policy:** Deny all incoming connections.
- **SSH:**  
  - Only allows connections on the SSH port (default: 2222).
  - Password authentication is disabled; only key-based authentication is permitted.
- **HTTP/HTTPS:**  
  - Ports 80 (HTTP) and 443 (HTTPS) are open to allow web traffic.
- **K3s API:**  
  - Port 6443 is only open if `firewall_open_k3s_ports` is set to `true`.

## Security Best Practices

- Always use SSH keys for authentication.
- Change the default SSH port if needed by editing `ansible_port` in your inventory, but the firewall will only allow the port specified in the playbook.
- Keep your SSH private keys secure and never share them.
- Only set `firewall_open_k3s_ports` to `true` if you need to access the Kubernetes API remotely, and consider restricting access by IP.

For a full list of configurable secrets, see [group_vars/all/secrets.example.yml](https://github.com/humansoftware/self-host-saas-k3s/blob/main/group_vars/all/secrets.example.yml).

## SSH tunnels

For security reasons, most UIs and services in the cluster are not directly exposed to the internet. Instead, they are accessed through SSH tunnels, which provide a secure way to access these services. This approach ensures that:

1. Services are only accessible to authorized users with SSH access
2. All traffic is encrypted through the SSH connection
3. No additional ports need to be opened on the firewall

For detailed instructions on setting up and automating SSH tunnels, including various methods like using `autossh`, systemd services, and SSH config, please refer to our [SSH Tunnel Guide](ssh-tunnel.md).