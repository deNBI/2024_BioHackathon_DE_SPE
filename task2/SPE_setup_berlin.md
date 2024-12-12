# Setting Up a Secure Research Environment with de.NBI Cloud (Berlin Node)

This guide outlines the steps to set up a Secure Research Environment (SPE) using the de.NBI Cloud in Berlin. It assumes you have an OpenStack project with estimated resources for deployment. In this example we use one VM to deploy WESkit and trigger the deployment of a slurm cluster via [BiBiGrid](https://github.com/BiBiServ/bibigrid).

The VM has the following properties: 
- Flavor Name: de.NBI large
- RAM: 64GB
- VCPUs: 32 VCPU
- Disk: 20GB

Please note a smaller VM (less CPU & RAM) will serve as well.

## Step 1: Launch an Instance

The first step is to start an instance to deploy [WESkit](https://gitlab.com/one-touch-pipeline/weskit) for workflow execution via its Gui. 
Follow the official [WESkit documentation](https://gitlab.com/one-touch-pipeline/weskit/documentation/-/blob/master/deployment/getting_started.md) to deploy WESkit using Docker Swarm.

In short:
```bash
- git clone https://gitlab.com/one-touch-pipeline/weskit/deployment
- cd deployment
- conda env create -n weskit_deployment -f environment.yaml
- conda activate weskit_deployment
- chmod 777 tests/data
- ./generateDevelopmentCerts.sh
```

### Additional Setup: Deploying a Slurm Cluster

You can use the same compute instance to deploy a Slurm cluster. To do this:

1. Clone the original [BiBiGrid repository](https://github.com/BiBiServ/bibigrid).
2. Follow the [Hands-On BiBiGrid Tutorial](https://github.com/deNBI/bibigrid_clum) for detailed instructions.

## Step 2: Configure the Master Node

After successfully deployment of the cluster, it will initially consist of a single master node. Before accessing the master node, ensure the following configurations are completed:

### Add the Default Group
Ensure that the default group is added to the master node for proper communication with the OpenStack API.

### Change DNS Resolver ###
BiBiGrid is using a custom dnsmasq resolver which is set to 8.8.8.8. denbi-cloud.bihealth.org on the other side is using 127.0.0.53.
Adjusting default DNS leads to a proper deployment of the cluster (master and worker).

## Step 3: Verify OpenStack API Connectivity
After the start, ensure that the OpenStack API endpoints are reachable by running the following command:
```bash
curl https://denbi-cloud.bihealth.org:13774/v2.1
```
## Step 4: Configure WESkit
In order to be able to submit the requests to the BiBiGrid (Slurm) cluster via an authenticated user,
we need to configure the slurm connection and LS Login. 

## Step 4.1: Slurm Cluster
In case of a docker stwarm deployment, we need to open the config_login.yaml and prove the remote executor credentials:

```bash
executor:
  type: "ssh_slurm"
  remote_data_dir: "/mnt/biohack_results/data"
  remote_workflows_dir: "/mnt/biohack_data/weskit/workflows"
  singularity_containers_dir: None
  login:
    username: "userA"
    host: "10.0.2.193"
    port: 22
    knownhosts_file: "/home/weskit/weskit_config_adapted/known_hosts"
    keyfile: "/home/weskit/weskit_config_adapted/user_accounts.txt"
    keyfile_passphrase: ""
    keepalive_interval: "30s"
    keepalive_count_max: 5
```

The given executor configuration defines the remote data and workflow directory on the remote side.
Settung singularity_containers_dir to None tells the cluster that the workflow engine (Snakemake, Nextflow) 
is executed via the e.g. conda environment and not via singularity and the corresponding container.

Within the login section user and host are provided. keyfile indicates the path to the database in text 
format that hosts information on the user and a path to the private_key. 
During the deployment only userA is able to submit job. Only ater log into the Gui via 
LS Login or any other OAuth2 suporting Identity provider the current user is overwritten by the newly authenticated one.

Furthermore, the admin needs to ensure that all required parameters workflow engine parameters are set. e.g. if a snakemake workflow needs conda environment for the whole workflow or individual tasks some paramters needs activation/configuration.

e.g.
```bash
  - name: conda-prefix
    api: true
    type: "str validFor Python.pathlib.Path"
    value: "/mnt/biohack_data/conda_cache/"
  - name: "use-conda"
    api: true
    type: "bool"
    value: "true"
```


## Step 4.2 Configure LS Login
At the current stage (11.12.2024) WESkit does not suppoert native user management. Thus an external Identity Provider that supports OAuth2 is used. In this case LS Login.

Please use **weskit_stack_base.yaml** for the configuration.
Make sure that the REST service get all the needed OIDC credentials. Which you will from the provide uppon service registration. Those are
```bash
      OIDC_ISSUER_URL: "https://login.elixir-czech.org/oidc/"
      OIDC_CLIENT_SECRET: "your_secret"
      OIDC_REALM: "your_realm"
      OIDC_CLIENTID: "your_clientID"
```
and

```bash
WESKIT_JWT_DECODE_AUDIENCE: ""
```
**WESKIT_JWT_DECODE_AUDIENCE** is your **OIDC_CLIENTID**

For the dashboard/gui you need provide additional to the OIDC credential JWT information. As an admin make sure that your are properly set. See [Flask-JWT-Extended Docu](https://flask-jwt-extended.readthedocs.io/en/stable/) for a detailed parameter explanation.
Please note that the parameters are prefixed with "WESKIT_" 

```bash
WESKIT_LOGIN: "true"
WESKIT_JWT_COOKIE_SECURE: "true"
WESKIT_JWT_TOKEN_LOCATION: '["cookies", "headers"]'
WESKIT_JWT_ALGORITHM: "RS256"
WESKIT_JWT_DECODE_AUDIENCE: "your_clinetID"
WESKIT_JWT_IDENTITY_CLAIM: "sub"
WESKIT_JWT_CSRF_IN_COOKIES: "false"
WESKIT_JWT_CSRF_METHODS: '[]' 
WESKIT_DASHBOARD_URL: "your_url"
WESKIT_OIDC_ISSUER_URL: "https://login.elixir-czech.org/oidc/"
WESKIT_OIDC_CLIENT_SECRET: "your_secret"
WESKIT_OIDC_REALM: ""
WESKIT_OIDC_CLIENTID: "your_clientID"
WESKIT_OIDC_SCOPE: '["openid", "eduperson_entitlement", "profile"]'
WESKIT_VERIFY_HTTPS: "true"
WESKIT_SECRET_KEY: "your_custom_secret"
```
Feel free to adjust some of the JWT parameters if needed.

## Step 5 :Certificates ##
If your deployment is connected to a domain, you might need to provide certificates to  **weskit_stack_base.yaml** at the **secrets** section.
```bash
weskit_domain.key:
    file: ../certs/domain.key
weskit_domain.crt:
    file: ../certs/domain.pem
```
as well as to the trafic configuration:

```bash
- source: weskit_domain.key
    target: /certs/weskit_domain.key
- source: weskit_domain.crt
    target: /certs/weskit_domain.crt
```
and adjust the deployment/traefik/traefik.toml file:

```bash
[tls.stores]
  [tls.stores.default]
    [tls.stores.default.defaultCertificate] 
      CertFile = "/certs/weskit.crt"
      KeyFile = "/certs/weskit.key"


[[tls.certificates]]
  CertFile = "/certs/weskit.crt" 
  KeyFile = "/certs/weskit.key"
```

## Step 6: Add user and install Conda anvironment
Addd user via add_user.sh script to the cluster nodes. Before that you need to provide the public key of the respective user. 
private and public key can be generated localy and then put to the cluster nodes via:
```bash
ssh-keygen -f ~/.ssh/user-ecdsa -t ecdsa -b 521
```
Users can be created on using **add_user.sh** script provided below.

Next install the conda environment that hosts Snakemake and Nextflow engines.
```bash
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh
/bin/bash
```
and enable automatic conda activation uppon connection of the user.


Before WESkit deployment add user to weskit_config/user_accounts.txt and its private key to a folder that is mounted into both REST and Worker service.

Starting from your deployment folder WESkit can be started using:
```bash
python weskit_stack.py start
```


**add_user.sh**
```bash
#!/bin/bash

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Check for required arguments
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <username> <path_to_public_key>"
    exit 1
fi

USERNAME=$1
PUBLIC_KEY_PATH=$2

# Verify the public key file exists
if [[ ! -f "$PUBLIC_KEY_PATH" ]]; then
    echo "Error: Public key file '$PUBLIC_KEY_PATH' does not exist."
    exit 1
fi

# Create the user without sudo rights
echo "Creating user '$USERNAME'..."
useradd -m -s /bin/bash "$USERNAME"
if [[ $? -ne 0 ]]; then
    echo "Failed to create user '$USERNAME'."
    exit 1
fi

# Create .ssh directory for the user
SSH_DIR="/home/$USERNAME/.ssh"
mkdir -p "$SSH_DIR"
chown "$USERNAME":"$USERNAME" "$SSH_DIR"
chmod 700 "$SSH_DIR"


# Add the public key to authorized_keys
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"
cat "$PUBLIC_KEY_PATH" > "$AUTHORIZED_KEYS"
chown "$USERNAME":"$USERNAME" "$AUTHORIZED_KEYS"
chmod 600 "$AUTHORIZED_KEYS"

# Disable sudo access explicitly
if [[ -f /etc/sudoers.d/$USERNAME ]]; then
    rm -f /etc/sudoers.d/$USERNAME
fi

# Install Conda and update the environment
# install_conda_and_update "$USERNAME"

# Display completion message
echo "User '$USERNAME' has been created and configured for SSH access on port 22."
echo "Public key from '$PUBLIC_KEY_PATH' has been added for authentication."
```

**conda environment**

```bash
name: base
channels:
  - bioconda
  - conda-forge
dependencies:
  - _libgcc_mutex=0.1=conda_forge
  - _openmp_mutex=4.5=2_gnu
  - amply=0.1.6=pyhd8ed1ab_0
  - annotated-types=0.7.0=pyhd8ed1ab_1
  - appdirs=1.4.4=pyh9f0ad1d_0
  - archspec=0.2.3=pyhd8ed1ab_0
  - argparse-dataclass=2.0.0=pyhd8ed1ab_0
  - attrs=24.2.0=pyh71513ae_1
  - boltons=24.0.0=pyhd8ed1ab_0
  - brotli-python=1.1.0=py312h2ec8cdc_2
  - bzip2=1.0.8=h4bc722e_7
  - c-ares=1.32.3=h4bc722e_0
  - ca-certificates=2024.8.30=hbcca054_0
  - certifi=2024.8.30=pyhd8ed1ab_0
  - cffi=1.17.1=py312h06ac9bb_0
  - charset-normalizer=3.4.0=pyhd8ed1ab_0
  - click=8.1.7=unix_pyh707e725_1
  - coin-or-cbc=2.10.12=h8b142ea_1
  - coin-or-cgl=0.60.9=h1d3f3f2_0
  - coin-or-clp=1.17.10=h07f2a63_0
  - coin-or-osi=0.108.11=h6514dde_1
  - coin-or-utils=2.11.12=h99da652_1
  - coincbc=2.10.12=1_metapackage
  - colorama=0.4.6=pyhd8ed1ab_0
  - coloredlogs=15.0.1=pyhd8ed1ab_3
  - conda=24.11.0=py312h7900ff3_0
  - conda-inject=1.3.2=pyhd8ed1ab_0
  - conda-libmamba-solver=24.9.0=pyhd8ed1ab_0
  - conda-package-handling=2.4.0=pyh7900ff3_0
  - conda-package-streaming=0.11.0=pyhd8ed1ab_0
  - configargparse=1.7=pyhd8ed1ab_0
  - connection_pool=0.0.3=pyhd3deb0d_0
  - coreutils=9.5=hd590300_0
  - curl=8.10.1=hbbe4b11_0
  - datrie=0.8.2=py312h66e93f0_8
  - distro=1.9.0=pyhd8ed1ab_0
  - docutils=0.21.2=pyhd8ed1ab_1
  - dpath=2.2.0=pyha770c72_0
  - eido=0.2.4=pyhd8ed1ab_0
  - exceptiongroup=1.2.2=pyhd8ed1ab_1
  - fmt=10.2.1=h00ab1b0_0
  - frozendict=2.4.6=py312h66e93f0_0
  - gitdb=4.0.11=pyhd8ed1ab_1
  - gitpython=3.1.43=pyhff2d567_1
  - h2=4.1.0=pyhd8ed1ab_0
  - hpack=4.0.0=pyh9f0ad1d_0
  - humanfriendly=10.0=pyhd81877a_7
  - hyperframe=6.0.1=pyhd8ed1ab_0
  - idna=3.10=pyhd8ed1ab_0
  - immutables=0.21=py312h66e93f0_0
  - importlib_resources=6.4.5=pyhd8ed1ab_1
  - iniconfig=2.0.0=pyhd8ed1ab_1
  - jinja2=3.1.4=pyhd8ed1ab_1
  - jsonpatch=1.33=pyhd8ed1ab_0
  - jsonpointer=3.0.0=py312h7900ff3_1
  - jsonschema=4.23.0=pyhd8ed1ab_1
  - jsonschema-specifications=2024.10.1=pyhd8ed1ab_1
  - jupyter_core=5.7.2=pyh31011fe_1
  - keyutils=1.6.1=h166bdaf_0
  - krb5=1.21.3=h659f571_0
  - ld_impl_linux-64=2.43=h712a8e2_2
  - libarchive=3.7.4=hfca40fe_0
  - libblas=3.9.0=25_linux64_openblas
  - libcblas=3.9.0=25_linux64_openblas
  - libcurl=8.10.1=hbbe4b11_0
  - libedit=3.1.20191231=he28a2e2_2
  - libev=4.33=hd590300_2
   libexpat=2.6.4=h5888daf_0
  - libffi=3.4.2=h7f98852_5
  - libgcc=14.2.0=h77fa898_1
  - libgcc-ng=14.2.0=h69a702a_1
  - libgfortran=14.2.0=h69a702a_1
  - libgfortran-ng=14.2.0=h69a702a_1
  - libgfortran5=14.2.0=hd5240d6_1
  - libgomp=14.2.0=h77fa898_1
  - libiconv=1.17=hd590300_2
  - liblapack=3.9.0=25_linux64_openblas
  - liblapacke=3.9.0=25_linux64_openblas
  - libmamba=1.5.9=h4cc3d14_0
  - libmambapy=1.5.9=py312h7fb9e8e_0
  - libnghttp2=1.64.0=h161d5f1_0
  - libnsl=2.0.1=hd590300_0
  - libopenblas=0.3.28=pthreads_h94d23a6_1
  - libsolv=0.7.30=h3509ff9_0
  - libsqlite=3.47.0=hadc24fc_1
  - libssh2=1.11.0=h0841786_0
  - libstdcxx=14.2.0=hc0a3c3a_1
  - libstdcxx-ng=14.2.0=h4852527_1
  - libuuid=2.38.1=h0b41bf4_0
  - libxcrypt=4.4.36=hd590300_1
  - libxml2=2.13.4=h064dc61_2
  - libzlib=1.3.1=hb9d3cd8_2
  - logmuse=0.2.8=pyhd8ed1ab_0
  - lz4-c=1.9.4=hcb278e6_0
  - lzo=2.10=hd590300_1001
  - mamba=1.5.9=py312h9460a1c_0
  - markdown-it-py=3.0.0=pyhd8ed1ab_1
  - markupsafe=3.0.2=py312h178313f_1
  - mdurl=0.1.2=pyhd8ed1ab_1
  - menuinst=2.2.0=py312h7900ff3_0
  - nbformat=5.10.4=pyhd8ed1ab_1
  - ncurses=6.5=he02047a_1
  - numpy=2.2.0=py312h7e784f5_0
  - openjdk=11.0.1=h516909a_1016
  - openssl=3.4.0=hb9d3cd8_0
  - packaging=24.1=pyhd8ed1ab_0
  - pandas=2.2.3=py312hf9745cd_1
  - pephubclient=0.4.4=pyhd8ed1ab_0
  - peppy=0.40.7=pyhd8ed1ab_1
  - pip=24.3.1=pyh8b19718_0
  - pkgutil-resolve-name=1.3.10=pyhd8ed1ab_2
  - plac=1.4.3=pyhd8ed1ab_0
  - platformdirs=4.3.6=pyhd8ed1ab_0
  - pluggy=1.5.0=pyhd8ed1ab_0
  - psutil=6.1.0=py312h66e93f0_0
  - pybind11-abi=4=hd8ed1ab_3
  - pycosat=0.6.6=py312h98912ed_0
  - pycparser=2.22=pyhd8ed1ab_0
  - pydantic=2.10.3=pyh3cfb1c2_0
  - pydantic-core=2.27.1=py312h12e396e_0
  - pygments=2.18.0=pyhd8ed1ab_1
  - pyparsing=3.2.0=pyhd8ed1ab_2
  - pysocks=1.7.1=pyha2e5f31_6
  - pytest=8.3.4=pyhd8ed1ab_1
  - python=3.12.7=hc5c86c4_0_cpython
  - python-dateutil=2.9.0.post0=pyhff2d567_1
  - python-fastjsonschema=2.21.1=pyhd8ed1ab_0
  - python-tzdata=2024.2=pyhd8ed1ab_1
  - python_abi=3.12=5_cp312
  - pytz=2024.1=pyhd8ed1ab_0
  - pyyaml=6.0.2=py312h66e93f0_1
  - readline=8.2=h8228510_1
  - referencing=0.35.1=pyhd8ed1ab_1
  - reproc=14.2.4.post0=hd590300_1
  - reproc-cpp=14.2.4.post0=h59595ed_1
  - requests=2.32.3=pyhd8ed1ab_0
  - reretry=0.11.8=pyhd8ed1ab_0
  - rich=13.9.4=pyhd8ed1ab_1
  - rpds-py=0.22.3=py312h12e396e_0
  - ruamel.yaml=0.18.6=py312h66e93f0_1
  - ruamel.yaml.clib=0.2.8=py312h66e93f0_1
  - setuptools=75.3.0=pyhd8ed1ab_0
  - shellingham=1.5.4=pyhd8ed1ab_1
  - six=1.17.0=pyhd8ed1ab_0
  - slack-sdk=3.33.5=pyhd8ed1ab_0
  - slack_sdk=3.33.5=hd8ed1ab_0
  - smart_open=7.0.5=pyhd8ed1ab_1
  - smmap=5.0.0=pyhd8ed1ab_0
  - snakemake-interface-common=1.17.4=pyhdfd78af_0
  - snakemake-interface-executor-plugins=9.3.2=pyhdfd78af_0
  - snakemake-interface-report-plugins=1.1.0=pyhdfd78af_0
  - snakemake-interface-storage-plugins=3.3.0=pyhdfd78af_0
  - tabulate=0.9.0=pyhd8ed1ab_2
  - throttler=1.2.2=pyhd8ed1ab_0
  - tk=8.6.13=noxft_h4845f30_101
  - tomli=2.2.1=pyhd8ed1ab_1
  - tqdm=4.67.0=pyhd8ed1ab_0
  - traitlets=5.14.3=pyhd8ed1ab_1
  - truststore=0.10.0=pyhd8ed1ab_0
  - typer=0.15.1=pyhd8ed1ab_0
  - typer-slim=0.15.1=pyhd8ed1ab_0
  - typer-slim-standard=0.15.1=hd8ed1ab_0
  - typing-extensions=4.12.2=hd8ed1ab_1
  - typing_extensions=4.12.2=pyha770c72_1
  - tzdata=2024b=hc8b5060_0
  - ubiquerg=0.8.0=pyhd8ed1ab_0
  - urllib3=2.2.3=pyhd8ed1ab_0
  - veracitools=0.1.3=py_0
  - wheel=0.45.0=pyhd8ed1ab_0
  - wrapt=1.17.0=py312h66e93f0_0
  - xz=5.2.6=h166bdaf_0
  - yaml=0.2.5=h7f98852_2
  - yaml-cpp=0.8.0=h59595ed_0
  - yte=1.5.4=pyha770c72_0
  - zipp=3.21.0=pyhd8ed1ab_1
  - zlib=1.3.1=hb9d3cd8_2
  - zstandard=0.23.0=py312hef9b889_1
  - zstd=1.5.6=ha6fb4c9_0
  - pip:
      - nextflow==23.4.1
      - pulp==2.7.0
      - snakemake==7.30.2
      - stopit==1.1.2
      - toposort==1.10
```

## Step 7: Submit Jobs
Once the setup is complete, you can submit your first sbatch jobs. These jobs will automatically trigger the startup of worker nodes in the cluster.
