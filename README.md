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

https://github.com/user-attachments/assets/825d4827-f2a4-41ae-976f-cf645ec303db

https://github.com/user-attachments/assets/f238d242-d556-4e2d-b870-e5727085afb7

https://github.com/user-attachments/assets/c69b57dd-4ac9-4da7-adf7-bc35baf7f6e9

https://github.com/user-attachments/assets/338118b8-b169-4a8f-a0eb-a00382cbf024

https://github.com/user-attachments/assets/07da8bd9-ecea-480a-973a-d15660d1c4e6

https://github.com/user-attachments/assets/a02de7aa-0724-4f8d-9b77-45638015a8d7

https://github.com/user-attachments/assets/d0768fe4-58cf-4153-bcf1-fab9094372ae

<img width="1917" height="936" alt="Image" src="https://github.com/user-attachments/assets/cbdb13e4-a191-4415-a596-43f55dace9c5" />

Here, steps are taken to briefly overview the data and then harmonize a column into a common schema between two datasets located each in a different insitution that use disparate standards (in this case, FIM and Barthel index). Then the Semantic Alignment tab is explored.

---

## License

Each MEDIATA component is licensed separately:

- [MEDIATA_orchestrator](https://github.com/tecnomod-um/MEDIATA_orchestrator/blob/main/LICENSE.md)
- [MEDIATA_node](https://github.com/tecnomod-um/MEDIATA_node/blob/main/LICENSE.md)
- [MEDIATA_frontend](https://github.com/tecnomod-um/MEDIATA_frontend/blob/main/LICENSE.md)

This umbrella repository does not introduce additional terms.
