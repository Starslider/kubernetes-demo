# Contributing to Kubernetes Demo

First off, thank you for considering contributing to the Kubernetes Demo project! It's people like you that make this project such a great resource for the community.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Pull Request Process](#pull-request-process)
- [Development Guidelines](#development-guidelines)
- [Reporting Issues](#reporting-issues)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to project maintainers.

### Our Pledge

We pledge to make participation in our project and our community a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

## Getting Started

1. **Fork the Repository**
   ```bash
   # Clone your fork
   git clone https://github.com/your-username/kubernetes-demo.git
   cd kubernetes-demo
   
   # Add upstream remote
   git remote add upstream https://github.com/Starslider/kubernetes-demo.git
   ```

2. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Your Changes**
   - Follow the [Development Guidelines](#development-guidelines)
   - Keep changes focused and atomic
   - Add tests if applicable
   - Update documentation as needed

4. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```
   
   Follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages:
   - feat: A new feature
   - fix: A bug fix
   - docs: Documentation changes
   - style: Code style changes (formatting, etc)
   - refactor: Code refactoring
   - test: Adding or modifying tests
   - chore: Maintenance tasks

## Pull Request Process

1. **Update Documentation**
   - Update the README.md with details of changes if applicable
   - Update the relevant configuration examples
   - Add notes to the documentation about new features

2. **Submit Pull Request**
   - Fill in the provided PR template
   - Link any relevant issues
   - Provide clear description of changes
   - Add screenshots for UI changes if applicable

3. **Review Process**
   - Maintainers will review your PR
   - Address any requested changes
   - Once approved, maintainers will merge your PR

## Development Guidelines

### Kubernetes Configuration
- Use Helm charts or Kustomize for deployments
- Follow the principle of least privilege
- Include resource limits and requests
- Use meaningful labels and annotations

### Documentation
- Keep READMEs up to date
- Document all configuration options
- Include examples for complex features
- Update version information

### Testing
- Test configurations with --dry-run
- Verify against multiple Kubernetes versions
- Test on both single-node and multi-node setups
- Validate with different container runtimes

## Reporting Issues

When reporting issues, please use the issue templates provided and include:

1. **Description**
   - Clear, concise description of the issue
   - Steps to reproduce
   - Expected vs actual behavior

2. **Environment**
   - Kubernetes version
   - Container runtime and version
   - Host OS and version
   - Any relevant logs

3. **Additional Context**
   - Screenshots if applicable
   - Related issues or PRs
   - Possible solutions you've considered

---

Again, thank you for contributing to Kubernetes Demo! 🚀