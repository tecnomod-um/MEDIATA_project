<p align="center">
 <img width="50%" height="50%" alt="mediata_logo" src="https://github.com/user-attachments/assets/ed5d54ab-8f39-42c9-841d-fa052d8dcea5" />
</p>

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

## MEDIATA in action:

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

## License

Each MEDIATA component is licensed separately:

- [MEDIATA_orchestrator](https://github.com/tecnomod-um/MEDIATA_orchestrator/blob/main/LICENSE.md)
- [MEDIATA_node](https://github.com/tecnomod-um/MEDIATA_node/blob/main/LICENSE.md)
- [MEDIATA_frontend](https://github.com/tecnomod-um/MEDIATA_frontend/blob/main/LICENSE.md)

This umbrella repository does not introduce additional terms.
