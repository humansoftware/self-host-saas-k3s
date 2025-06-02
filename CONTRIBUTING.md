# Contributing to Self-Hosted SaaS K3s

Thank you for your interest in contributing to this project! This document provides guidelines and instructions for contributing.

## Development Workflow

1. **Open an Issue First**
   - Before submitting any pull request, please open an issue to discuss the proposed changes
   - This helps ensure that your work aligns with the project's goals and prevents duplicate efforts
   - Clearly describe the feature or bug fix you want to implement
   - Wait for feedback and approval from maintainers before proceeding

2. **Fork and Clone**
   - Fork the repository to your GitHub account
   - Clone your fork locally
   - Create a new branch for your changes

3. **Testing Your Changes**
   - All changes must be tested using the provided test VM setup
   - Follow the testing instructions below

## Testing with Multipass VM

The project uses Multipass to create a test VM environment for validating Ansible playbooks. Here's how to use it:

### Prerequisites
- Ubuntu or a compatible Linux distribution
- Snap package manager (for Multipass installation)

### Running the Tests

1. **First-time Setup**
   ```bash
   # Make the script executable
   chmod +x run_test_vm.sh
   
   # Run the script with --restart flag to create a fresh VM
   ./run_test_vm.sh --restart
   ```

2. **Subsequent Runs**
   ```bash
   # Run without --restart to reuse the existing VM
   ./run_test_vm.sh
   ```

### What the Test Script Does

The `run_test_vm.sh` script:
1. Installs Multipass if not present
2. Creates a fresh Ubuntu 24.04 VM with 2 CPUs, 4GB RAM, and 25GB disk
3. Configures SSH access using your public key
4. Sets up the Ansible inventory
5. Installs required Ansible collections
6. Runs the main playbook against the test VM

### Troubleshooting

If you encounter issues:
1. Use `--restart` to create a fresh VM
2. Check Multipass status: `multipass info saas-server`
3. SSH into the VM: `multipass shell saas-server`
4. View VM logs: `multipass logs saas-server`

## Submitting Changes

1. **Code Style**
   - Follow existing code style and formatting
   - Include comments for complex logic
   - Update documentation as needed

2. **Commit Messages**
   - Write clear, descriptive commit messages
   - Reference issue numbers when applicable

3. **Pull Request Process**
   - Push your changes to your fork
   - Create a pull request against the main repository
   - Include a description of your changes
   - Reference the related issue
   - Ensure all tests pass
   - Wait for review and feedback

## Getting Help

If you need help or have questions:
- Open an issue for general questions
- Join our community discussions
- Contact the maintainers

Thank you for contributing to making this project better!
