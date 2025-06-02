# Self-Host SaaS K3s

A complete self-hosting solution that transforms a single dedicated server into a powerful SaaS platform. This project aims to simplify the self-hosting journey by providing a comprehensive, production-ready setup with just one Ansible script.

## Why This Project?

I created this project because I wanted to self-host my applications while maintaining the development velocity and features we're used to in cloud environments. The goal is to provide a complete solution that includes:

- CI/CD pipelines
- Custom deployment configurations
- Security hardening
- Automated backups to Backblaze
- And much more...

All of this without the complexity of managing multiple services or worrying about infrastructure details.

## Why K3s on a Single Node?

While running Kubernetes on a single node might seem like overkill, I chose K3s for several important reasons:

1. **Infrastructure as Code**: K3s leverages Kubernetes' well-documented standards for defining infrastructure through Custom Resource Definitions (CRDs) and Helm charts. This means you can:
   - Define your entire infrastructure in YAML files
   - Version control your infrastructure
   - Automate deployments and updates
   - Maintain consistent environments

2. **Development Velocity**: K3s provides all the services and tools we're used to in cloud environments, making development cycles faster and more efficient.

3. **Flexibility**: The setup allows hosting multiple projects with different requirements on the same server with minimal effort, including:
   - Web applications and APIs
   - Background jobs and cron tasks
   - Data pipelines and processing
   - Web crawlers and scrapers

4. **Future-Proof**: If you need to scale later, the transition to a multi-node cluster is much simpler.

5. **Cost-Effective**: You get all the benefits of a cloud-like environment at a fraction of the cost.

## Documentation

For detailed documentation, including installation guides, configuration options, and usage instructions, visit our [documentation site](https://humansoftware.github.io/self-host-saas-k3s/).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.