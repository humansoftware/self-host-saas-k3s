# SSH Tunnel Automation

This guide provides various methods to automate the SSH tunnel for accessing your K3s cluster.

## Basic SSH Tunnel

The basic SSH tunnel command:
```bash
ssh -N -L 6443:localhost:6443 ubuntu@YOUR_PUBLIC_IP
```

## Automation Options

### 1. Using autossh (Recommended)

`autossh` provides automatic reconnection if the connection drops:

```bash
# Install autossh
sudo apt-get install autossh

# Create a persistent tunnel
autossh -M 0 -N -L 6443:localhost:6443 ubuntu@YOUR_PUBLIC_IP
```

### 2. Systemd Service

Create a systemd service for automatic tunnel management:

```bash
# Create service file
sudo nano /etc/systemd/system/k3s-tunnel.service
```

Add the following content:
```ini
[Unit]
Description=K3s SSH Tunnel
After=network.target

[Service]
User=YOUR_USERNAME
ExecStart=/usr/bin/autossh -M 0 -N -L 6443:localhost:6443 ubuntu@YOUR_PUBLIC_IP
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

Enable and start the service:
```bash
sudo systemctl enable k3s-tunnel
sudo systemctl start k3s-tunnel
```

### 3. Shell Script

Create a simple shell script for manual tunnel management:

```bash
# Create tunnel script
nano ~/k3s-tunnel.sh
```

Add the following content:
```bash
#!/bin/bash
ssh -N -L 6443:localhost:6443 ubuntu@YOUR_PUBLIC_IP
```

Make it executable:
```bash
chmod +x ~/k3s-tunnel.sh
```

### 4. SSH Config

Configure SSH for easier connection management:

```bash
# Add to ~/.ssh/config
nano ~/.ssh/config
```

Add the following configuration:
```ini
Host k3s-tunnel
    HostName YOUR_PUBLIC_IP
    User ubuntu
    LocalForward 6443 localhost:6443
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

Then you can simply use:
```bash
ssh k3s-tunnel
```

## Troubleshooting

### Common Issues

1. **Connection Drops**
   - Check your network connection
   - Verify the server is running
   - Check SSH server logs: `journalctl -u ssh`

2. **Permission Denied**
   - Verify SSH key permissions: `chmod 600 ~/.ssh/id_rsa`
   - Check SSH config permissions: `chmod 600 ~/.ssh/config`

3. **Port Already in Use**
   - Check if port 6443 is already in use: `netstat -tuln | grep 6443`
   - Kill existing process: `kill $(lsof -t -i:6443)`

### Monitoring

1. **Check Tunnel Status**
   ```bash
   # For systemd service
   systemctl status k3s-tunnel

   # For autossh
   ps aux | grep autossh
   ```

2. **View Logs**
   ```bash
   # Systemd service logs
   journalctl -u k3s-tunnel -f

   # SSH logs
   tail -f /var/log/auth.log
   ```

## Security Considerations

1. **SSH Key Management**
   - Use strong SSH keys
   - Regularly rotate keys
   - Use key-based authentication only

2. **Network Security**
   - Restrict SSH access to specific IPs
   - Use non-standard SSH port
   - Enable fail2ban

3. **Monitoring**
   - Monitor failed login attempts
   - Set up alerts for suspicious activity
   - Regular security audits 