<p align="center">
 <img width="50%" height="50%" alt="mediata_logo" src="https://github.com/user-attachments/assets/ed5d54ab-8f39-42c9-841d-fa052d8dcea5" />
</p>

<p align="center">
  <img alt="Last commit" src="https://img.shields.io/github/last-commit/tecnomod-um/MEDIATA_project" />
  <img alt="Stars" src="https://img.shields.io/github/stars/tecnomod-um/MEDIATA_project" />
  <img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-blue" />
</p>

**MEDIATA** is a federated clinical data harmonization platform, initially developed as part of the [STRATIF-AI](https://cordis.europa.eu/project/id/101080875) European research project. It enables secure, distributed preprocessing, integration, and semantic alignment of sensitive patient datasets across multiple institutions.

This repository serves as the **main entry point**, containing links to all core components:

| Component                                                                     | Description                                                                          |
| ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| [`MEDIATA_orchestrator`](https://github.com/tecnomod-um/MEDIATA_orchestrator) | Central backend service dedicated to coordination, authentication, and orchestration |
| [`MEDIATA_node`](https://github.com/tecnomod-um/MEDIATA_node)                 | Lightweight node backend deployed at each clinical site                              |
| [`MEDIATA_frontend`](https://github.com/tecnomod-um/MEDIATA_frontend)         | Web-based frontend client for secure, multi-node interaction                         |

---

## Features

- Data cataloguing: DCAT descriptions are supported so available data can be described.
- Discovery: federated, on-site dataset analysis.
- Profiling & cleaning: descriptive stats to gauge data quality and cleaning tools.
- Integration: column/value alignment against a customizable shared schema.
- Semantic alignment: create an RDF file from elements in the datasets, with SNOMED CT term suggestions.
- HL7 FHIR (currently in development): export/mapping via clustering.
- Security by design: Kerberos SSO, HTTPS/TLS; no raw patient data ever leaves the site.

---

## MEDIATA in action

Multiple sites can be accessed simultaneously, with each describing its datasets using the DCAT standard.
<video width="630" height="300" src="https://github.com/user-attachments/assets/313dd37d-bfb6-4a73-917a-c9ed7be1a600"></video>

Navigate through both single-feature and aggregate statistics across multiple files from different sites simultaneously.
<video width="630" height="300" src="https://github.com/user-attachments/assets/8e573036-15aa-41d3-b37a-42aec178dec8"></video>

Explore the structure of specific columns in different files...
<video width="630" height="300" src="https://github.com/user-attachments/assets/1d3d771f-15ce-4650-b1f1-0594bfffd970"></video>

...and map them into a common schema, applied at each site.
<video width="630" height="300" src="https://github.com/user-attachments/assets/84ee2bb1-0014-48ab-b6b0-8d7b9b7df7ea"></video>

Use the navigation functionality to perform this process iteratively.
<video width="630" height="300" src="https://github.com/user-attachments/assets/36142aae-2989-40eb-8b5f-189b355b19bc"></video>

Create RDF schemas from features extracted from the datasets.
<video width="630" height="300" src="https://github.com/user-attachments/assets/0c5101fc-2e91-438a-a821-a33f8b2420ad"></video>

FHIR mapping support is under development, currently at the clustering stage.
<video width="630" height="300" src="https://github.com/user-attachments/assets/3985cffb-035c-4657-bea6-98322a696901"></video>

---

## Cloning the Project

To clone this repository along with all submodules:

```bash
git clone --recurse-submodules https://github.com/tecnomod-um/MEDIATA_project.git
cd MEDIATA_project
```

If already cloned without submodules:

```bash
git submodule update --init --recursive
```

---

## Local Deployment

To deploy MEDIATA locally using Docker, follow these steps:

### Prerequisites

1. **Install Docker** and ensure it is running:
   - Install [Docker Desktop](https://www.docker.com/products/docker-desktop) for your operating system
   - Start Docker Desktop and ensure it is running
   - **For WSL 2 users**: Enable WSL 2 integration in Docker Desktop settings (Settings → Resources → WSL Integration)
   - Verify Docker is available: `docker --version` and `docker compose version`

2. **Clone this repository** with all submodules:
   ```bash
   git clone --recurse-submodules https://github.com/tecnomod-um/MEDIATA_project.git
   cd MEDIATA_project
   ```

3. **Clone additional required repositories** inside the `MEDIATA_orchestrator` directory:
   ```bash
   cd MEDIATA_orchestrator
   git clone https://github.com/tecnomod-um/mediata-rdf-builder.git
   git clone https://github.com/alvumu/InteroperabilityFHIRAPI.git
   cd ..
   ```

### Deployment Steps

1. **Fix line endings** (if needed on Windows or when encountering CRLF issues):
   ```bash
   sed -i 's/\r$//' run.sh
   ```

2. **Run the deployment script**:
   ```bash
   ./run.sh
   ```

   The script will:
   - Build and deploy the orchestrator with Docker Compose
   - Start MongoDB, Elasticsearch, Snowstorm, RDF Builder, and FHIR API services
   - Build and run the MEDIATA node
   - Build and run the frontend

3. **Access the services**:
   - **Frontend**: http://localhost:3000
   - **Orchestrator**: http://localhost:18088/taniwha
   - **Node API**: http://localhost:18082/taniwha

### Checking Status

- View running services: `docker compose ps` (in the `MEDIATA_orchestrator` directory)
- View orchestrator logs: `cd MEDIATA_orchestrator && docker compose logs -f orchestrator`
- View node logs: `docker logs -f mediata-node`
- View frontend logs: `docker logs -f mediata-frontend`

### Stopping Services

To stop all services, run:
```bash
./stop.sh
```

---

## License

Each MEDIATA component is licensed separately:

- [MEDIATA_orchestrator](https://github.com/tecnomod-um/MEDIATA_orchestrator/blob/main/LICENSE.md)
- [MEDIATA_node](https://github.com/tecnomod-um/MEDIATA_node/blob/main/LICENSE.md)
- [MEDIATA_frontend](https://github.com/tecnomod-um/MEDIATA_frontend/blob/main/LICENSE.md)

This umbrella repository does not introduce additional terms.
