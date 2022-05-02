#!/bin/bash
echo ""
echo "This will revoke the BIG-IP / SSL Orchestrator license."
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
    ansible-playbook -e @ansible_vars.yaml playbooks/utility-revoke-license.yaml
else
    echo "Cancelled"
fi