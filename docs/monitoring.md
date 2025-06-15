# Monitoring (Prometheus & Grafana)

This stack provides cluster monitoring and visualization using Prometheus and Grafana.

## Configuration

All configuration is handled via Ansible variables in `roles/monitoring/defaults/main.yml` or can be overridden in your inventory.

Key variables:
```yaml
monitoring_namespace: monitoring

prometheus_enabled: true
prometheus_storage_size: 5Gi
prometheus_storage_class: longhorn
prometheus_alertmanager_enabled: false

grafana_enabled: true
grafana_storage_size: 5Gi
grafana_storage_class: longhorn
grafana_admin_user: admin
grafana_admin_password: admin
```

## Accessing the Grafana UI

1. Set up port forwarding:

   ```bash
   kubectl -n monitoring port-forward svc/grafana 3000:80
   ```

2. Access the UI at [http://localhost:3000](http://localhost:3000)

3. Login with:
   - Username: `admin`
   - Password: `admin`
   (or your custom credentials if you changed them)

### Grafana Features

- Pre-built dashboards for Kubernetes and Prometheus metrics
- Custom dashboard creation
- Alerting and notifications
- Data source management

## Accessing the Prometheus UI

1. Set up port forwarding:

   ```bash
   kubectl -n monitoring port-forward svc/prometheus-server 9090:80
   ```

2. Access the UI at [http://localhost:9090](http://localhost:9090)

### Prometheus Features

- Query metrics with PromQL
- Explore time-series data
- Configure alerting rules (if enabled)

## Troubleshooting

### Common Issues

1. **Grafana/Prometheus not accessible**
   - Ensure pods are running:  
     ```bash
     kubectl get pods -n monitoring
     ```
   - Check port-forward command and local firewall

2. **No data in dashboards**
   - Check Prometheus targets in its UI
   - Ensure node exporters and kube-state-metrics are running

3. **Login issues**
   - Verify credentials in your Ansible variables

---

If you configured variables correctly, monitoring should be ready to use after deployment.