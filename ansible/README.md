## SSL Orchestrator Topology Configuration using Ansible

This project contains a set of sample playbooks to configure SSL Orchestrator:

- Inbound layer 3 topology
  - An inbound layer 3 topology
  - 2 layer 3 security devices (Snort)
  - 2 service chains
    - Service chain 1: snort1
    - Service chain 2: snort1 and snort2
  - 2 security policy rules
    - Internal traffic from 10.0.0.0/8 subnet sends to service chain 1
    - All other TCP/443 traffic sends to service chain 2

- Inbound existing application topology
  - A simple LTM application (VIP, client/server ssl, pool)
  - SSL Orchestrator existing app (services, service chains, policy) that attaches itself to the application VIP

- Configuration utility to delete all SSL Orchestrator configuration objects
- Configuration utility to revoke the BIG-IP license (so that it can be re-used)

------

#### Project Development

This template was developed and tested with the following versions:

- SSL Ochestrator 7.5 / BIG-IP 15.1.1

------

#### Usage

The accompanying Terraform files generate an Ansible variables file (ansible_vars.yaml) that can be used with this playbook. Before using SSL Orchestrator Ansible playbooks, you must install the F5 Module v1 and v2 Ansible collections (imperative and declarative) into your Ansible development folder:

  ```
  cd ansible
  ansible-galaxy collection install f5networks.f5_modules f5networks.f5_bigip -f
  ```

You can now use one of the following options to deploy the example SSL Orchestrator playbooks

- Option 1: Deploy an Ansible config using the variables file that was created by the accompanying Terraform.

  From the 'ansible' folder:

  ```bash
  cp ../terraform-aws-sslo/ansible_vars.yaml .
  ansible-playbook -e @ansible_vars.yaml playbooks/config-sslo-inbound-l3-complete.yaml
  ```

- Option 2: Deploy an Ansible config with your own variables file.

  Use the 'ansible_vars.yaml.example' file as a template to create a custom 'ansible_vars.yaml' file and then update the variable values.

  From the 'ansible' folder:

  ```bash
  cp playbooks/ansible_vars.yaml.example ansible_vars.yaml
  vi ansible_vars.yaml
  ansible-playbook -e @ansible_vars.yaml playbooks/config-sslo-inbound-l3-complete.yaml
  ```
