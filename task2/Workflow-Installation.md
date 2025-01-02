# Workflow Installation

This is step-by-step guide for installing a new workflow in [WESkit](https://gitlab.com/one-touch-pipeline/weskit). After the following steps, it will be possible to run and monitor the installed workflow via the WESkit GUI.

## Prerequisites

- WESkit installation
- Execution backend (e.g. Slurm)

## Configure the Backend

Copy all workflow files (e.g. *Snakefile*, *main.nf*, etc.) to a directory, that can be reached by all execution nodes. This could be e.g. a NFS share. The directory containing the workflows must be stored in the `remote_workflows_dir` field in the *config.yaml* of the WESkit installation. Furthermore the `remote_data_dir` must be specified, which contains the working directory of the workflow.

Example `config.yaml` for a Slurm execution backend:
```yaml
executor:
    type: "ssh_slurm"
    remote_data_dir: "/path/to/data"
    remote_workflows_dir: "/path/to/workflows"
```

If the workflow uses conda, you need to make it available as default parameter in the config.

Snakemake requires the parameter `use-conda`. Additionally you can set `conda-prefix` to specify the conda directory (containing e.g. the environments).

Example Snakemake configuration for conda:
```yaml
SMK:
    "7.30.2":
        default_parameters: &default_smk_engine_parameters
            - name: "use-conda"
                api: true
                type: "bool"
                value: "true"
            - name: conda-prefix
                api: true
                type: "str validFor Python.pathlib.Path"
                value: "/mnt/biohack_data/conda_cache/"
```

In case of Nextflow, you can simply put the parameters in the *nextflow.config* file.

## Configure the GUI

To make the workflow available in the GUI, it has to be added to the *info.yaml* file. 

The following table contains the relevant fields:

| Field    | Description |
| -------- | ------- |
| type  | Type of the workflow engine, e.g. SMK, NFL.   |
| uri | Path to the workflow file. This must refer to the script, you copied in the first step.  |
| version    | Workflow engine version. |
| config    | Schema for the configuration. |

If the workflow requires input parameters, for example a path to a data-set, you have to set up the *config* schema accordingly. Each property refers to an input parameter for the workflow. A property is defined by its name, type and description. Finally, you can mark some properties as *required*.


Here is an example configuration:
```yaml
nextflow_example:
  type: "NFL"
  uri: "file:nextflow-example-workflow-2024/main.nf"
  version: "23.04.1"
  config:
    $schema: "https://json-schema.org/draft/2020-12/schema"
    $id: "https://example.com/product.schema.json"
    title: "WF2"
    description: "This document describes the configuration for nextflow-example-workflow-2024"
    type: "object"
    properties:
      genome: 
        description: "Path to fasta (.fa) genome file."
        type: "string"
      samples: 
        description: "Path to fastq sample file(s)."
        type: "string"
    required:
      - "genome"
      - "samples"
```

This configuration describes a workflow running on *Nextflow 23.04.1*. The script is stored under `<worflow_dir>/nextflow-example-workflow-2024/main.nf`. The workflow requires two mandatory parameter: *genome* and *samples*, which both are of type "*string*", because they represent a file path.

## Apply changes

To apply the changes, restart WESkit with the following commands:
```bash
docker stack rm weskit
cd deployment/
python weskit_stack.py start --compose /path/to/config.yaml
```