## F5 SSL Orchestrator API Project Tools
#### Amazon Web Services version

This project contains:

- Terraform templates for an AWS SSL Orchestrator environment deployment and base infrastructure configuration.
- Ansible folders and sample playbooks to configure SSL Orchestrator.

Refer to the README files in the **terraform-aws-sslo** and **ansible** folders for usage information.

---------------

#### Ansible Requirements
The following software package versions are required for F5 Ansible automation:
- Python >= 3.8
- Ansible >= 2.10

Please refer to official F5 documentation for additional guidance: https://clouddocs.f5.com/products/orchestration/ansible/devel/

> :warning: Please note that as of May 2022 the SSL Orchestrator Ansible collection is currently under public preview and subject to evolve over time.

##### Installation
- Start in an empty local folder and git clone this repository
- Change to the new f5_sslo_api_tools folder
  ```bash
  cd f5_sslo_api_tools
  ```
- Change to the ansible folder and install the F5 Ansible module collections (imperative and declarative collections)
  ```bash
  cd ansible
  ansible-galaxy collection install f5networks.f5_modules f5networks.f5_bigip -f
  ```
- Launch Terraform commands from within the **f5_sslo_api_tools/terraform-aws-sslo** folder.
- Launch Ansible commands from within the **f5_sslo_api_tools/ansible** folder.

##### Required Python Libraries
The SSL Orchestrator Ansible modules depend on the following third party libraries:
- f5-sdk
- bigsuds
- netaddr
- objectpath
- isoparser
- lxml
- deepdiff

##### Additional Considerations
If deploying to a virtual (VE) environment, it will be useful to increase management plane memory provisioning on the BIG-IPs.
  ```bash
  tmsh modify sys db provision.extramb value 8192
  tmsh save sys config
  ```

---------------

#### Terraform Requirements
The following software package versions are required for F5 Terraform automation:
- Terraform >= 0.11

Please refer to official F5 documentation for additional guidance: 
https://clouddocs.f5.com/products/orchestration/terraform/latest/

---------------

#### Environment considerations
Ansible and Terraform automation can be performed from practically any (Windows/Mac/Linux) workstation environment provided the above requirements are met.

An additional option is provided here to employ a pre-packaged automation environment inside a Docker container. The container includes all of the tools needed to successfully perform BIG-IP SSL Orchestrator automation. There are two modes this can be used:

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

---------------

#### Testing
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

---------------

##### Attributions
This project would not exist without the contributions of the following individuals:
- Jason Chiu
- Melisa Wentz
- Arnulfo Hernandez
- Barrymore Simon
- Matt Stovall
- Jack Fenimore