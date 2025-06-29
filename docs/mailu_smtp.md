# Configure SMTP (Mailu) for Your Self-Hosted SaaS

This guide explains how to enable and configure SMTP email sending for your self-hosted SaaS projects using Mailu, and how to set up the required DNS records for reliable email delivery.

## 1. Enable Mailu Globally

In your `group_vars/all/secrets.yml` (or `secrets.example.yml`), set the following variable to enable Mailu for all projects:

```yaml
install_mailu_for_smtp: true
```

## 2. Configure SMTP Per Project

Each project in the `self_saas_projects` array can have its own SMTP configuration. Example:

```yaml
self_saas_projects:
  - name: example-self-hosted-saas-app
    domain: example.mvalle.com
    smtp:
      enabled: true  # Set to false to skip Mailu config for this project
      domain: smtp.example.mvalle.com
      user: noreply@example.mvalle.com
      password: "your_smtp_password"
  - name: another-app
    domain: another.example.com
    smtp:
      enabled: true
      domain: smtp.another.example.com
      user: noreply@another.example.com
      password: "your_smtp_password"
```

- Only projects with `mailu.enabled: true` will be included in the Mailu configuration.
- The `domain` under `smtp` should be the SMTP hostname you want to use for that project.
- The `user` and `password` are the credentials Mailu will use for sending mail from that project.

## 3. DNS Requirements

For each domain you want to send (and optionally receive) email from, you must configure DNS records:

### MX Records
Set the MX record for each domain to point to its SMTP hostname:

```
example.mvalle.com.   IN MX 10 smtp.example.mvalle.com.
another.example.com.  IN MX 10 smtp.another.example.com.
```

### A or CNAME Records
Each SMTP hostname must resolve to the public IP address of your Mailu server (the LoadBalancer or Ingress IP):

```
smtp.example.mvalle.com.   IN A <mailu-public-ip>
smtp.another.example.com.  IN A <mailu-public-ip>
```

### SPF, DKIM, and DMARC
For best deliverability, add these records for each domain:
- **SPF**: Authorizes your Mailu server to send mail for your domain.
- **DKIM**: Cryptographically signs your emails (Mailu can generate the DKIM key).
- **DMARC**: Tells receiving servers how to handle unauthenticated mail.

Consult the Mailu admin UI or documentation for the exact DKIM record to add.

### Reverse DNS (PTR)
The public IP used by Mailu should have a PTR record (reverse DNS) matching one of your SMTP hostnames (e.g., `smtp.example.mvalle.com`).

## 4. Example

If you have two projects, your DNS zone might look like:

```
example.mvalle.com.   IN MX 10 smtp.example.mvalle.com.
smtp.example.mvalle.com.   IN A 203.0.113.10
another.example.com.  IN MX 10 smtp.another.example.com.
smtp.another.example.com.  IN A 203.0.113.10
```

## 5. Additional Notes
- You only need to deploy Mailu once; it will handle all enabled domains.
- If you want to disable Mailu for a specific project, set `mailu.enabled: false` for that project.
- Always test your email deliverability and check spam folders after setup.

For more details, see the [Mailu documentation](https://mailu.io/).

## 6. Accessing the Mailu Admin UI

To access the Mailu Admin web interface locally, use kubectl port-forward:

```sh
kubectl -n mailu port-forward svc/mailu-admin 8082:80
```

Then open [http://localhost:8082](http://localhost:8082) in your browser. Login with your admin credentials.

