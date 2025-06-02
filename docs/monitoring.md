# Monitoring Guide

This guide explains how to set up and use monitoring tools in your Self-Host SaaS K3s cluster.

## Monitoring Stack

### 1. Prometheus

1. Install Prometheus:
   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm install prometheus prometheus-community/kube-prometheus-stack
   ```

2. Configure Prometheus:
   ```yaml
   apiVersion: monitoring.coreos.com/v1
   kind: ServiceMonitor
   metadata:
     name: your-app
     labels:
       release: prometheus
   spec:
     selector:
       matchLabels:
         app: your-app
     endpoints:
     - port: metrics
   ```

### 2. Grafana

1. Access Grafana:
   ```bash
   kubectl port-forward svc/prometheus-grafana 3000:80
   # Access at http://localhost:3000
   # Default credentials: admin/prom-operator
   ```

2. Import dashboards:
   - Kubernetes Overview
   - Node Exporter
   - Prometheus

## Metrics Collection

### 1. Node Metrics

1. Node Exporter:
   ```yaml
   apiVersion: monitoring.coreos.com/v1
   kind: ServiceMonitor
   metadata:
     name: node-exporter
     labels:
       release: prometheus
   spec:
     selector:
       matchLabels:
         app.kubernetes.io/name: node-exporter
     endpoints:
     - port: metrics
   ```

### 2. Container Metrics

1. cAdvisor:
   ```yaml
   apiVersion: monitoring.coreos.com/v1
   kind: ServiceMonitor
   metadata:
     name: cadvisor
     labels:
       release: prometheus
   spec:
     selector:
       matchLabels:
         app.kubernetes.io/name: cadvisor
     endpoints:
     - port: metrics
   ```

## Alerting

### 1. AlertManager

1. Configure alerts:
   ```yaml
   apiVersion: monitoring.coreos.com/v1
   kind: PrometheusRule
   metadata:
     name: your-app-alerts
     labels:
       release: prometheus
   spec:
     groups:
     - name: your-app
       rules:
       - alert: HighCPUUsage
         expr: container_cpu_usage_seconds_total > 0.8
         for: 5m
         labels:
           severity: warning
         annotations:
           summary: High CPU usage
           description: Container {{ $labels.container }} has high CPU usage
   ```

2. Configure receivers:
   ```yaml
   apiVersion: monitoring.coreos.com/v1
   kind: AlertmanagerConfig
   metadata:
     name: default
     namespace: monitoring
   spec:
     receivers:
     - name: email
       emailConfigs:
       - to: your-email@example.com
         from: alertmanager@your-domain.com
         smarthost: smtp.your-domain.com:587
     route:
       receiver: email
   ```

## Logging

### 1. Loki

1. Install Loki:
   ```bash
   helm repo add grafana https://grafana.github.io/helm-charts
   helm install loki grafana/loki-stack
   ```

2. Configure log collection:
   ```yaml
   apiVersion: logging.banzaicloud.io/v1beta1
   kind: Flow
   metadata:
     name: your-app-logs
   spec:
     filters:
     - parser:
         remove_key_name_field: true
         parse:
           type: json
     match:
     - select:
         labels:
           app: your-app
     localOutputRefs:
     - loki
   ```

### 2. Log Visualization

1. Add Loki data source in Grafana:
   - URL: http://loki:3100
   - Access: Server (default)

2. Create log dashboard:
   - Add Loki panel
   - Configure log query
   - Set up time range

## Resource Monitoring

### 1. CPU and Memory

1. Create resource dashboard:
   ```yaml
   apiVersion: monitoring.coreos.com/v1
   kind: PrometheusRule
   metadata:
     name: resource-alerts
   spec:
     groups:
     - name: resources
       rules:
       - alert: HighMemoryUsage
         expr: container_memory_usage_bytes > 0.8
         for: 5m
         labels:
           severity: warning
   ```

### 2. Storage

1. Monitor Longhorn volumes:
   ```yaml
   apiVersion: monitoring.coreos.com/v1
   kind: ServiceMonitor
   metadata:
     name: longhorn
   spec:
     selector:
       matchLabels:
         app: longhorn-manager
     endpoints:
     - port: metrics
   ```

## Custom Metrics

### 1. Application Metrics

1. Expose metrics endpoint:
   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: your-app
   spec:
     template:
       spec:
         containers:
         - name: your-app
           ports:
           - name: metrics
             containerPort: 8080
   ```

2. Configure ServiceMonitor:
   ```yaml
   apiVersion: monitoring.coreos.com/v1
   kind: ServiceMonitor
   metadata:
     name: your-app
   spec:
     selector:
       matchLabels:
         app: your-app
     endpoints:
     - port: metrics
   ```

## Dashboard Management

### 1. Create Dashboards

1. Basic dashboard:
   - Add panels for CPU, Memory, Network
   - Configure time range
   - Set up variables

2. Application dashboard:
   - Add custom metrics
   - Configure alerts
   - Set up annotations

### 2. Share Dashboards

1. Export dashboard:
   - Save as JSON
   - Share with team
   - Import in other instances

## Troubleshooting

### 1. Common Issues

1. **Metrics not showing**
   - Check ServiceMonitor configuration
   - Verify metrics endpoint
   - Check Prometheus targets

2. **Alerts not firing**
   - Verify alert rules
   - Check AlertManager configuration
   - Test alert conditions

3. **Logs not appearing**
   - Check Loki configuration
   - Verify log collection
   - Check storage capacity

### 2. Debugging

1. Check Prometheus status:
   ```bash
   kubectl get pods -n monitoring
   kubectl logs -n monitoring -l app=prometheus
   ```

2. Verify Grafana:
   ```bash
   kubectl get pods -n monitoring -l app=grafana
   kubectl logs -n monitoring -l app=grafana
   ```

## Best Practices

1. **Resource Management**
   - Set appropriate retention periods
   - Configure resource limits
   - Regular cleanup of old data

2. **Alert Configuration**
   - Use meaningful alert names
   - Set appropriate thresholds
   - Configure proper notification channels

3. **Dashboard Organization**
   - Group related metrics
   - Use consistent naming
   - Document dashboard purposes

## Next Steps

1. [Configure backups](backups.md)
2. [Security hardening](security.md)
3. [Application deployment](applications.md) 