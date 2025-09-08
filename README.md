# MEDIATA Platform

**MEDIATA** is a federated clinical data harmonization platform, initially developed as part of the [STRATIF-AI](https://cordis.europa.eu/project/id/101080875) European research project. It enables secure, distributed preprocessing, integration, and semantic alignment of sensitive patient datasets across multiple institutions.

This repository serves as the **main entry point**, containing links to all core components:

| Component            | Description                                        |
|----------------------|----------------------------------------------------|
| [`MEDIATA_orchestrator`](https://github.com/tecnomod-um/MEDIATA_orchestrator) | Central backend service dedicated to coordination, authentication, and orchestration |
| [`MEDIATA_node`](https://github.com/tecnomod-um/MEDIATA_node)             | Lightweight node backend deployed at each clinical site                   |
| [`MEDIATA_frontend`](https://github.com/tecnomod-um/MEDIATA_frontend)     | Web-based front-end client for secure, multi-node interaction            |

---

## Features

 - Data cataloguing: DCAT descriptions are supported to describe available data.
 - Discovery: federated on-site dataset analysis.
 - Profiling & cleaning: descriptive stats to gauge data quality and cleaning tools.
 - Integration: column/value alignment against a customizable shared schema.
 - Semantic alignment: create and rdf file from the elements present in the dataset, with SNOMED CT term suggestions.
 - HL7 FHIR (currently in development):  HL7 FHIR export/mapping by clustering.
 - Security by design: Kerberos SSO, HTTPS/TLS; no raw patient data ever leaves the site.

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

<video width="630" height="300" src="https://github.com/user-attachments/assets/313dd37d-bfb6-4a73-917a-c9ed7be1a600"></video>


https://github.com/user-attachments/assets/313dd37d-bfb6-4a73-917a-c9ed7be1a600

https://github.com/user-attachments/assets/8e573036-15aa-41d3-b37a-42aec178dec8

https://github.com/user-attachments/assets/1d3d771f-15ce-4650-b1f1-0594bfffd970

https://github.com/user-attachments/assets/84ee2bb1-0014-48ab-b6b0-8d7b9b7df7ea

https://github.com/user-attachments/assets/36142aae-2989-40eb-8b5f-189b355b19bc

https://github.com/user-attachments/assets/0c5101fc-2e91-438a-a821-a33f8b2420ad

https://github.com/user-attachments/assets/3985cffb-035c-4657-bea6-98322a696901

Here, steps are taken to briefly overview the data and then harmonize a column into a common schema between two datasets located each in a different insitution that use disparate standards (in this case, FIM and Barthel index). Then the Semantic Alignment tab is explored.

---

## License

Each MEDIATA component is licensed separately:

- [MEDIATA_orchestrator](https://github.com/tecnomod-um/MEDIATA_orchestrator/blob/main/LICENSE.md)
- [MEDIATA_node](https://github.com/tecnomod-um/MEDIATA_node/blob/main/LICENSE.md)
- [MEDIATA_frontend](https://github.com/tecnomod-um/MEDIATA_frontend/blob/main/LICENSE.md)

This umbrella repository does not introduce additional terms.
