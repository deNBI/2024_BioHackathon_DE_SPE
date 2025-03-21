# Secure Processing Environments as a Service in the de.NBI Cloud

**Project Leads**:
- Nils Hoffmann (FZ Jülich) n.hoffmann@fz-juelich.de
- Sven Olaf Twardziok (BIH@Charité) sven.twardziok@bih-charite.de

**Participants**:
- Carsten Schelp, SURF
- Jan Krüger, FZ Jülich
- Xaver Stiensmeier, Uni Bielefeld
- Alex Kanitz, SIB
- Sanjay Kumar Srikakulam, Uni Freiburg
- Valentin Schneider-Lunitz, BIH@Charité
- Landfried Kraatz, BIH@Charité
- Martin Braun, BIH@Charité
- Jacobo Miranda, EMBL Heidelberg

**Acknowledgements**:
- de.NBI Cloud Team: David Weinholz, Viktor Rudko, Peter Belmann

**Abstract**:
In biomedical research, sensitive data from humans is a critical asset for the ability to carry out essential research in even potentially critical situations, e.g. as proven during the COVID-19 pandemic. Providing easy access to data speeds up the research process, resulting in faster development of new drugs, or exploring and further understanding of rare diseases. With the German model project for comprehensive diagnostics and therapy identification using genome sequencing for rare and oncological diseases according to §64e, Sozialgesetzbuch and the European Health Data Space (EHDS), more clinical data from daily routine will be available for translational research in the future in Germany and in Europe. However, a high level of protection of sensitive data must be implemented. Today, different approaches for implementing secure environments exist. The concept of the 5 safes (Safe projects, Safe people, Safe settings, Safe data, Safe outputs) is used to build Trusted Research Environments (TRE) in the UK and the EHDS calls for the development of Secure Processing Environments (SPE) for the processing of health data for research. In both approaches, technical solutions are used to ensure that sensitive data is highly protected.

In this de.NBI Biohackathon project, we will use existing ELIXIR services as well as external tools to create a technical foundation for reusable Secure Processing Environments in the de.NBI cloud. In detail, the authentication will be based on Life Science Login for authentication and authorization.Authenticated and authorized users will be able to execute secure and validated Snakemake and Nextflow workflows on sensitive data using WESKIT, an implementation of the GA4GH WES standard. The actual computation will be relayed to a SLURM cluster system based on BiBiGrid that is deployed within the secure processing environment. WESkit will execute the workflows on behalf of the users on the SLURM cluster. The sensitive data will be available via the cluster's file system for authorized users. This allows certain data sets to be shared, while other data remains protected from user access.

In this project, we will set up the secure processing environment as an example platform, provide detailed documentation and describe all necessary processes so that the environment can be transferred to other use cases in the de.NBI cloud. This will ultimately enable other de.NBI Cloud locations and potentially other cloud providers in ELIXIR to easily adapt the environment to their needs. Through the use of established components and infrastructure, we maximize the chance of a successful outcome by the end of the hackathon.

**Tasks**:

Task 1: Deployment of MinIO in the de.NBI cloud and using MinIO for sharing sensitive data with researchers. [Results](./task1)

Task 2: Using WESKIT & SLURM (BiBiGrid) to build a Secure Processing Environment (SPE) in the de.NBI cloud. [Results](./task2)

Task 3: TES-K & confidential computing in the de.NBI cloud. [Results](https://github.com/deNBI/deNBI-cloud-kubeone)

**Report**:
BioHackrXiv  Report: [PDF](https://github.com/deNBI/2024_BioHackathon_DE_SPE/blob/main/2025_03_10_paper_preview.pdf), [MD](https://github.com/deNBI/2024_BioHackathon_DE_SPE/blob/main/paper.md) [https://doi.org/10.37044/osf.io/pzmue_v1](https://doi.org/10.37044/osf.io/pzmue_v1).
