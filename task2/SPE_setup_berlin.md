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


## Step N: Submit Jobs
Once the setup is complete, you can submit your first sbatch jobs. These jobs will automatically trigger the startup of worker nodes in the cluster.
