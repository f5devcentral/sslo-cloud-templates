## AWS SSL Orchestrator Infrastructure Deployment using Terraform

These Terraform configuration files will deploy an F5 SSL Orchestrator environment into Amazon Web Services (AWS).

The resulting deployment will consist of the following:

- Security VPC and various subnets for SSL Orchestrator and inspection devices
- Application VPC and subnet for demo application
- Demo application server (Wordpress)
- F5 SSL Orchestrator (BIG-IP Virtual Edition)
- Two layer 3 inspection devices

The Terraform does not automatically deploy an SSL Orchestrator Topology configuration. However, it does generate an Ansible Variables file that can be used with the accompanying Ansible playbook to deploy an Inbound Layer 3 Topology. You can also manually configure and deploy the Topology instead.

-----

#### Project Development

This template was developed and tested in the **AWS US-East-1** region with the following versions:

- Terraform v1.1.8 / AWS Provider v3.75.1
- Terraform v0.14.5 / AWS Provider v3.57.0

-----

#### Usage

- From a web browser client - subscribe to the following EC2 instances:

  - https://aws.amazon.com/marketplace/pp?sku=5e92658b-3fa7-42c1-9a9b-569f009582df
  - https://aws.amazon.com/marketplace/pp?sku=78b1d030-4c7d-4ade-b8e6-f8dc86941303
  - https://aws.amazon.com/marketplace/pp?sku=a133064f-76e1-4d8a-aa3d-26ef12e6b95a

- Obtain your programmatic access credentials for your AWS account: Access Key ID, Access Key, and Session Token.

- From inside your development environment - add a profile to you AWS credentials files or export the AWS credentials
  ```bash
  export AWS_ACCESS_KEY_ID="your-aws-access-key-id"
  export AWS_SECRET_ACCESS_KEY="your-aws-secret-access-key"
  export AWS_SESSION_TOKEN="your-aws-session-token"
  ```

- From the terraform-aws-sslo folder - Copy the included **terraform.tfvars.example** file to **terraform.tfvars** and update the values (*they will override the defaults from the *variables.tf* file*):

  - Set a unique prefix value for object creation
  - Set a BIG-IP license key. You will need a BYOL SSL Orchestrator base registration key.
  - Set a unique name for the EC2 keypair. Terraform will create the keypair in AWS and also save it to the current folder.
  - Set the AWS region and availability (if different)
  - Set the AMI ID for SSL Orchestrator (**sslo_ami**) if you wish to use a different software version.
  - Set the SSL Orchestrator instance type (if different). Ensure that you use an instance type that supports the 7 ENIs required for this deployment. This will usually be some variant of a **4xlarge** instance type.
  - Set your SSL Orchestrator **admin** user password (use a strong password!). Note: This is configured for demo/dev enviroments only. The recommended practice is to use a secrets manager like Secrets or Vault to store the password.

- From inside your development environment - deploy the Terraform configuration
  ```bash
  terraform init
  terraform validate
  terraform plan
  terraform apply -auto-approve
  ```

- If there are no errors, Terraform  will output several values, including the public IP address to access the SSL Orchestrator TMUI/API. Hang on this information as you'll need it later for testing.

----

#### Deleting the Deployment

When you are ready to delete your deployment
  ```bash
  terraform destroy
  ```

----

#### Steps for Manual SSL Orchestrator Topology Configuration

- [optional] Upload a trusted SSL certificate and key before entering the SSL Orchestrator guide configuration UI

- Create an L3 Inbound topology

- Define SSL settings (using either the default or the previously uploaded certificate and key)

- Create the first inspection service
  - Enter a name for the service
  - Select a Layer 3 type from the service catalog
  - De-select automatic network configuration
  - Use **dmz1** as the To-Service VLAN
  - Enter the IP address of the inspection service (from Terraform outputs)
  - Use **dmz2** as the From-Service VLAN
  - Enable Port remapping (e.g., 8000)

- Create the second inspection service
  - Enter a name for the service
  - Select a different Layer 3 type from the service catalog
  - De-select automatic network configuration
  - Use **dmz3** as the To-Service VLAN
  - Enter the IP address of the inspection service (from Terraform outputs)
  - Use **dmz4** as the From-Service VLAN
  - Enable Port remapping (e.g., 9000)

- Create a Service Chain (service_chain_1) and add the first inspection service to it.

- Create a second Service Chain (service_chain_2) and add both inspection services to it.

- In the Egress settings, use SNAT automap and network default route

- In the Security Policy rules:

  - Create a new rule (before the default rule) withClient Subnet: 10.0.0.0/8 and Service Chain: service_chain_1

  - Add the second Service Chain to the Default rule.

- Deploy the Topology configuration.

----

#### Inbound Traffic Diagram

 ![F5](https://user-images.githubusercontent.com/16813250/166265042-6008008a-6e60-4034-b6aa-51924ce485da.png)

 ![F5](https://user-images.githubusercontent.com/16813250/166265200-9c753ea5-3a27-4c1c-ba03-0205be2e168a.png)

----

#### Troubleshooting

##### BIG-IP (SSL Orchestrator) VE Issues

The BIG-IP VE uses the F5 Automation Toochain Declarative Onboarding (DO) extension to configure the base networking. This is intiated via the runtime-init script as defined in the f5_onboard.tmpl template file.

If the DO configuration fails (possibly due to a licensing issue), the BIG-IP network settings will not be configured. Correct your DO issues and redeploy the BIG-IP.


##### Inspection Devices

This configuration uses "inspection" devices sitting in separate service chains to simulate real world deployments. These are Linux hosts with Snort IDS installed. Snort is not configured, but it will bootstrap with appropriate routing and IP forwarding so that packets traverse the inspection zone and return to the SSL Orchestrator interfaces.

If the config fails, you should check where traffic is stopping.  A good place to start is at the BIG-IP.

- Run a tcpdump on the dmz1 and dmz3 interfaces. Do you see traffic?
  - No: Inspection devices are not configured properly in the SSL Orchestrator Service configuration, Service Chain, or Security Policy. Review your SSL Orchestrator configuration.

  - Yes: Run a tcpdump on the dmz2/dmz4 interface. Do you see traffic?

    - No: The routes on the inspection devices are not set up correctly (possibly due to bootstrap issues).

      - SSH to the inspection device(s) and check the route table.

      - Does the table contain a route for 10.0.2.0/24? If not, then run the following commands to add the routes:

        - inspection_device_1: 

          ```bash
          sudo ip route delete default
          sudo ip route add default via 10.0.3.1 metric 1
          sudo ip route add 10.0.2.0/24 via 10.0.3.129
          sudo sysctl -w net.ipv4.ip_forward=1
          ```

        - inspection_device_2:

          ```bash
          sudo ip route delete default
          sudo ip route add default via 10.0.4.1 metric 1
          sudo ip route add 10.0.2.0/24 via 10.0.4.129
          sudo sysctl -w net.ipv4.ip_forward=1
          ```
