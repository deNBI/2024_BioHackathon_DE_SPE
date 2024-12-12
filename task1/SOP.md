**Standard Operating Procedure (SOP) for deploying MinIO with Ansible in the de.NBI cloud**

---

## **1. Purpose**

The purpose of this SOP is to provide a detailed process for deploying MinIO on a VM in the de.NBI cloud using an Ansible playbook. The deployment includes firewall configuration, Nginx setup with SSL termination via Certbot, secure access through Let's Encrypt certificates, and MinIO policies for data/user management.

---

## **2. Scope**

This SOP applies to system administrators and DevOps engineers responsible for setting up a trusted research environment (TRE)/secure processing environment (SPE) for sharing sensitive data with researchers using MinIO integrated with LS-AAI authentication.

---

## **3. Prerequisites**

1. Access to a VM in the de.NBI cloud (e.g., in Berlin/Bielefeld).
2. Ansible installed on the control machine.
3. Proper access permissions to run playbooks on the VM.
4. Domain names for MinIO services.
5. Terraform installed for VM provisioning.
6. Service registered at [LS-AAI](https://aai.lifescience-ri.eu/) and have the necessary credentials for relying party configuration. You can follow the [LS-AAI documentation](https://lifescience-ri.eu/ls-login/relying-parties/how-to-register-and-integrate-a-relying-party-to-ls-login.html) for more information.

---

## **4. Roles and responsibilities**

- **System administrator:** Executes the deployment and ensures post-deployment validation.
- **DevOps engineer:** Maintains and updates the playbook, associated roles, and Terraform configurations.

---

## **5. Procedure**

### **5.1. Preparing the Ansible control machine**

1. Install Ansible:
   ```bash
   sudo apt update && sudo apt install ansible
   ```
2. Clone the repository containing the playbook and roles.
   ```bash
   git clone <repository_url>
   ```
3. Install required dependencies:

   ```bash
   cd <repository_directory>

   ansible-galaxy install -r requirements.yml
   ```

### **5.2. Configuring the playbook**

1. Update `secret_group_vars/all.yml` with:

   - Domain names (`domain`, `minio_console_dns`, `minio_api_dns`)
   - Certbot admin email (`admin_email`)
   - MinIO access key and secret key (`minio_root_user`, `minio_root_password`)

2. Verify the following Ansible roles are available:
   - `geerlingguy.docker`
   - `geerlingguy.certbot`
   - `minio-nginx`
   - `minio-server`

### **5.3. Running the playbook**

1. Execute the playbook:
   ```bash
   ansible-playbook -i hosts playbook.yml
   ```

---

## **6. Deployment breakdown**

### **6.1. Pre-tasks**

- Install necessary packages (`python3`, `ufw`).
- Configure UFW to allow ports 22, 80, and 443.
- Deny all other incoming traffic.

### **6.2. Roles execution**

1. **Docker installation:**

   - Installs Docker using the `geerlingguy.docker` role.

2. **Nginx and SSL setup:**

   - Configures Nginx reverse proxy.
   - Obtains SSL certificates via Certbot.

3. **MinIO deployment:**

   - Deploys MinIO using Docker.
   - Configures MinIO to use the Let's Encrypt certificates to enable HTTPS for [Server Side Encryption with Customer provided keys (SSE-C)](https://min.io/docs/minio/linux/administration/server-side-encryption/server-side-encryption-sse-c.html).

### **6.3. Post deployment**

1.**MinIO Policies Setup:**

- In the git repository, there is a `minio_policies` directory containing the MinIO policies which an admin can add to the MinIO server to manage user access and data sharing via the MinIO web console and attach it as the `Role Policy` to the integration with LS-AAI in the later steps.
- The policies can be added by going to the MinIO web console and navigating to the `Policies` section and selecting `Create Policy`.
- Add a Policy name and copy the policy JSON from the `minio_policies` directory and save it.
- _Note: You might want to adapt the policies as per your requirements_

2. **LS-AAI Integration:**
   ### **6.3.2.1 Prerequisites**
   1. **Relying Party Configuration:**
      - Once you register you can access the SAML/OIDC metadata of your relying party from the LS-AAI dashboard.
      - The following data is required
        1. **Client ID:** The client ID of the relying party.
        2. **Client Secret:** The client secret of the relying party.
        3. **Config URL:** `https://login.aai.lifescience-ri.eu/oidc/.well-known/openid-configuration`
        4. **Scopes:** `openid,profile`
      ### **6.3.2.2 Configuration**
      1. **MinIO Configuration:**
         - You can use the MinIO web console to configure the LS-AAI integration.
         - Go to the `Identity` section and select `OpenID` as the provider and create configuration
         - Fill in the following details:
           1. **Config URL:** `https://login.aai.lifescience-ri.eu/oidc/.well-known/openid-configuration`
           2. **Client ID:** The client ID of the relying party.
           3. **Client Secret:** The client secret of the relying party.
           4. **Display Nmae:** `Elixir LS AAI login`
           5. **Scopes:** `openid,profile`
           6. **Redirect URI:** `https://<minio_console_dns>/oauth_callback`
           7. **Role Policy:** Enter the MinIO policy name that you have added to the MinIO server (you can attach more than one policy by separating them with a comma).
           8. Enable the `Claim User Info` option to get the user information from the LS-AAI.

---

## **7. Verification Steps**

1. Check MinIO web console access using the configured domain.
2. Verify secure HTTPS access with valid SSL certificates.
3. Test data upload and sharing features.
4. Check MinIO policies for user and data management.
5. Check LS-AAI integration for secure user authentication.

---

## **8. Configuring Server-Side Encryption (SSE-C)**

1. Install the MinIO client and configure: Follow the instructions [here](https://min.io/docs/minio/linux/reference/minio-mc.html)
2. Create an encryption key:
   ```bash
   openssl rand -hex 32
   ```
3. Configure the MinIO client:

   ```bash
   # Example: mc alias set <ALIAS NAME> <MINIO API URL> <ACCESS KEY> <SECRET KEY>

   mc alias set denbiminio https://minioapi.seproenv.bi.denbi.de <ACCESS_KEY> <SECRET_KEY>
   ```

4. Upload a file using SSE-C:

   ```bash
   # Example: mc put --enc-c "<ALIAS NAME>/<BUCKET NAME>/<OBJECT PATH>=<ENCRYPTION KEY>" <LOCAL FILE PATH> <TARGET>

   mc put --enc-c "denbiminio/ssec-testing/test/ssec_test_file=<ENCRYPTION_KEY>" ssec_test_file.txt denbiminio/ssec-testing/test/ssec_test_file.txt
   ```

5. To download the encrypted file, use the following command:

   ```bash
   # Example: mc get --enc-c "<ALIAS NAME>/<BUCKET NAME>/<OBJECT PATH>=<ENCRYPTION KEY>" <TARGET> <LOCAL FILE PATH>

   mc get --enc-c "denbiminio/ssec-testing/test/ssec_test_file=<ENCRYPTION_KEY>" denbiminio/ssec-testing/test/ssec_test_file.txt downoloaded_ssec_test_file.txt
   ```

---

## **9. Security Considerations**

- Use LS-AAI for authentication.
- Regularly update the playbook and dependent roles.
- Restrict VM access and disable root login.
- Apply strict MinIO policies for secure data management and sharing.

---

## **10. References**

- Ansible Documentation: [https://docs.ansible.com](https://docs.ansible.com)
- Terraform Documentation: [https://www.terraform.io/docs](https://www.terraform.io/docs)
- MinIO Documentation: [https://min.io/docs](https://min.io/docs)
- de.NBI Cloud: [https://cloud.denbi.de](https://cloud.denbi.de)
- LS-AAI Documentation: [https://lifescience-ri.eu/ls-login/relying-parties/how-to-register-and-integrate-a-relying-party-to-ls-login.html](https://lifescience-ri.eu/ls-login/relying-parties/how-to-register-and-integrate-a-relying-party-to-ls-login.html)
- MinIO SSE-C: [https://min.io/docs/minio/linux/administration/server-side-encryption/server-side-encryption-sse-c.html](https://min.io/docs/minio/linux/administration/server-side-encryption/server-side-encryption-sse-c.html)
- GitHub Repository: [https://github.com/deNBI/2024_BioHackathon_DE_SPE](https://github.com/deNBI/2024_BioHackathon_DE_SPE)
