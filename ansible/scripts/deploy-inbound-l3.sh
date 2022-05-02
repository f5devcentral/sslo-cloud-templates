#!/bin/bash
echo ""
echo "This will deploy an SSL Orchestrator Inbound Layer 3 Topology"
echo "using the variables file created by the accompanying Terraform."
echo ""
echo "Copying the ansible_vars.yaml file created by Terraform..."
cp ../terraform-aws-sslo/ansible_vars.yaml .
echo ""
echo "ansible_vars.yaml"
echo "========================================================================"
cat ansible_vars.yaml
echo "========================================================================"
echo "If you do not see any variables above, abort now!"
echo ""
read -r -p "Are you sure? [y/N] " response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    ansible-playbook -e @ansible_vars.yaml playbooks/config-sslo-inbound-l3-complete.yaml
else
    echo "Cancelled"
fi
