# MEDIATA Platform

**MEDIATA** is a federated clinical data harmonization platform developed as part of the [STRATIF-AI](https://cordis.europa.eu/project/id/101080875) European research project. It enables secure, distributed preprocessing, integration, and semantic alignment of sensitive patient datasets across multiple institutions — all without centralizing raw data.

This repository serves as the **main entry point**, containing links to all core components:

| Component            | Description                                        |
|----------------------|----------------------------------------------------|
| [`MEDIATA_orchestrator`](https://github.com/tecnomod-um/MEDIATA_orchestrator) | Central backend service for coordination, authentication, and orchestration |
| [`MEDIATA_node`](https://github.com/tecnomod-um/MEDIATA_node)             | Lightweight node backend deployed at each clinical site                   |
| [`MEDIATA_frontend`](https://github.com/tecnomod-um/MEDIATA_frontend)     | Web-based front-end client for secure, multi-node interaction            |

---

## 🔧 Cloning the Full Project

To clone this repository along with all submodules:

```bash
git clone --recurse-submodules https://github.com/tecnomod-um/MEDIATA_project.git
cd MEDIATA_project
