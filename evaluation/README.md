# MEDIATA Evaluation Materials

This folder contains the assets and scripts used to generate the MEDIATA usability evaluation package.

The evaluation package is intended for an unsupervised usability test of the MEDIATA release. Running the project will generate the latest evaluation PDFs in this directory.

## Preparing the repository

To clone the repository and its submodules, use:

```sh
git clone --recurse-submodules https://github.com/tecnomod-um/MEDIATA_project.git
cd MEDIATA_project
```

## Running the evaluation

Run the project from the repository root:

```sh
./run.sh
```

This generates the evaluation PDFs in this folder:

- `evaluation_tasks.pdf` - participants follow these tasks
- `questionnaire.pdf` - participants complete this form

## Participant Instructions

1. Complete the tasks listed in `evaluation_tasks.pdf`.
2. Fill in the form in `questionnaire.pdf` after finishing the tasks.
