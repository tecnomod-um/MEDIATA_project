# MEDIATA Platform

**MEDIATA** is a federated clinical data harmonization platform, initially developed as part of the [STRATIF-AI](https://cordis.europa.eu/project/id/101080875) European research project. It enables secure, distributed preprocessing, integration, and semantic alignment of sensitive patient datasets across multiple institutions.

This repository serves as the **main entry point**, containing links to all core components:

| Component            | Description                                        |
|----------------------|----------------------------------------------------|
| [`MEDIATA_orchestrator`](https://github.com/tecnomod-um/MEDIATA_orchestrator) | Central backend service for coordination, authentication, and orchestration |
| [`MEDIATA_node`](https://github.com/tecnomod-um/MEDIATA_node)             | Lightweight node backend deployed at each clinical site                   |
| [`MEDIATA_frontend`](https://github.com/tecnomod-um/MEDIATA_frontend)     | Web-based front-end client for secure, multi-node interaction            |

---

## Features

 - Discovery: federated dataset catalogs (FAIR / DCAT compliant).
 - Profiling & cleaning: descriptive stats, filters, data quality tools.
 - Integration: column/value alignment against a shared schema.
 - Semantic alignment: SNOMED CT term suggestions, HL7 FHIR export/mapping helpers.
 - Security by design: Kerberos SSO, HTTPS/TLS; no raw patient data leaves nodes.

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

## Sample use case

See MEDIATA in action:
https://github.com/tecnomod-um/MEDIATA_project/releases/download/v0.1.0/demo_video.mp4
Here, steps are taken to briefly overview the data and then harmonize a column into a common schema between two datasets located each in a different insitution that use disparate standards (in this case, FIM and Barthel index). Then the Semantic Alignment tab is explored.

---

## License

Each MEDIATA component is licensed separately:

- [MEDIATA_orchestrator](https://github.com/tecnomod-um/MEDIATA_orchestrator/blob/main/LICENSE.md)
- [MEDIATA_node](https://github.com/tecnomod-um/MEDIATA_node/blob/main/LICENSE.md)
- [MEDIATA_frontend](https://github.com/tecnomod-um/MEDIATA_frontend/blob/main/LICENSE.md)

This umbrella repository does not introduce additional terms.
