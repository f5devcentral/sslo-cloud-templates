## F5 SSL Orchestrator API Project Tools
#### AWS Lab Instructions

The following will walk you through a simple set of examples using the provided templates. The lab is completely self-contained within a pre-packaged Docker environment, so the only local requirement is that Docker is installed and operative.

------

### Launch the development container environment

There are two methods for launching the Docker container: 

- **Interactive command-line**: use this option to launch an interactive terminal session into the container shell. This is also useful when running a local code editor (ex. vscode). Launch this container in an empty folder. It will create a "code" folder inside this folder and mount to a /code folder in the container. 
  ```bash
  docker run --name f5sslo -it -v $(pwd)/code:/code kevingstewart/f5-ansible-terraform-lab:latest
  ```
  where:
  - **--name f5sslo**: gives the container a unique name
  - **-it**: exposes an interactive shell
  - **-v $(pwd)/code:/code** mounts the local "code" folder to /code in the container

  To exit this container:
  ```bash
  exit
  ```
  To re-start the container and attach to the console:
  ```bash
  docker container start f5sslo
  docker container attach f5sslo
  ```

- **code-server**: this container includes an implementation of Visual Studio Code Server that will expose vscode inside a browser window. Launch this container in an empty folder. It will create a "code" folder inside this folder and mount to a /code folder in the container.
  ```bash
  docker run -d -v $(pwd)/code:/code -p 3000:8080 kevingstewart/f5-ansible-terraform-lab:latest /usr/bin/code-server-init
  ``` 
  where:
  - **-d**: runs as a daemon and detach local shell
  - **-v $(pwd)/code:/code** mounts the local "code" folder to /code in the container
  - **-p 3000:8080**: publishes the container's port (8080) to a local port (3000)
  - **/usr/bin/code-server-init**: launches the code-server binary

  Once launched, open a browser and navigate to http://localhost:3000

Inside the container (interactive command line or code-server terminal), cd to /code to do all development work.

------

### Clone the repository
From within the container environment, clone this repository inside the empty /code folder. If using the interactive command line:
```bash
cd /code
git clone <repo url>
cd <repo>
```
If using the code-server, open a terminal by clicking on the (&#9776;) hamburger symbol in the top right, select "Terminal", and then "New Terminal". Inside the new terminal:
```bash
cd /code
git clone <repo url>
cd <repo>
```

------

### Bootstrap the SSLO AWS environment with Terraform

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

    ```bash
    cd terraform-aws-sslo
    cp terraform.tfvars.example terraform.tfvars
    ```

  - Set a unique prefix value for object creation.
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

- If there are no errors, Terraform  will output several values, including the public IP address to access the SSL Orchestrator TMUI/API. Hang on to this information as you'll need it later for testing.

------

### Build the SSL Orchestrator environment with Ansible

- Move into the ansible folder and install the F5 collection.

  ```bash
  cd ansible
  ansible-galaxy collection install f5networks.f5_modules f5networks.f5_bigip -f
  ```

  > :warning: Please note that as of May 2022 the SSL Orchestrator Ansible collection is currently under public preview and subject to evolve over time.

- Deploy an Ansible config using the variables file that was created by the accompanying Terraform. This will create an inbound layer 3 SSL Orchestrator topology. From the 'ansible' folder:

  ```bash
  cp ../terraform-aws-sslo/ansible_vars.yaml .
  ansible-playbook -e @ansible_vars.yaml playbooks/config-sslo-inbound-l3-complete.yaml
  ```

------

### Testing
Upon successful environment bootstrap with Terraform and SSL Orchestrator topology configuration with Ansible, you can test your deployment by attempting to access the exposed virtual server address. The output from the *terraform apply* command will contain the "sslo_vip" IP address:
```bash
curl -k https://sslo-vip-address
```

Now access the BIG-IP console using the "sslo_management_public_ip" from the Terraform output. Use the password defined in the terraform.tfvars file.
```bash
ssh admin@sslo-management-public-ip
```

In the BIG-IP console, capture traffic flowing across the inline security devices. In this lab, traffic enters Snort1 on dmz1, exits on dmz2. Traffic enters Snort2 on dmz3 and exits on dmz4.
```bash
tcpdump -lnni dmz1 not icmp
```

While the capture is running, perform the curl request again from another local terminal. You should see traffic flowing across the security device. To see the decrypted traffic:
```bash
tcpdump -lnni dmz1 -Xs0 not icmp
```

------

### Deleting the Deployment

When you are ready to delete your deployment, first revoke the BIG-IP license file so that it can be re-used:
  ```bash
  cd ../ansible
  ansible-playbook -e @ansible_vars.yaml playbooks/utility-revoke-license.yaml
  ```

Then destroy the AWS environment with Terraform:
  ```bash
  cd ../terraform-aws-sslo
  terraform destroy
  ```

------

This completes the AWS example lab.
