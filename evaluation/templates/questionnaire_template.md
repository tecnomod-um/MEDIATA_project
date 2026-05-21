# Usability Evaluation Questionnaire

**Scope:** MEDIATA Discovery and Integration workflow  
**Evaluation type:** Unsupervised remote evaluation  
**Estimated time:** 30-45 minutes

---

## 1. Participant Instructions

You have received a MEDIATA evaluation package containing the application release, sample datasets, a target schema, a sample mapping specification, this questionnaire, and the task sheet.

Please complete the workflow independently. The goal is to evaluate MEDIATA as a tool for discovering datasets, generating integration metadata, creating and reviewing mappings, processing datasets, and checking the output. You are not being evaluated on clinical interpretation of the sample data.

Use the tutorial/help material included in the release before starting the tasks.

---

## 2. Evaluation Focus

This questionnaire evaluates whether MEDIATA supports a practical discovery and integration workflow from the user's point of view. The focus is on whether users can understand what data is available, inspect and prepare it for integration, create or review meaningful mappings, process the selected datasets, and verify that the generated outputs are usable.

---

## 3. Participant Profile

| Question | Answer |
| --- | --- |
| Participant code or initials | |
| Role | ☐ Clinician ☐ Researcher ☐ Data scientist ☐ Software developer ☐ Student ☐ Other: |
| Previous experience with clinical data | ☐ None ☐ Basic ☐ Intermediate ☐ Advanced |
| Previous experience with data integration or harmonization tools | ☐ None ☐ Basic ☐ Intermediate ☐ Advanced |
| Previous experience using web-based data tools | ☐ None ☐ Basic ☐ Intermediate ☐ Advanced |
| Have you used MEDIATA before? | ☐ Yes ☐ No |
| Date of evaluation | |

<!-- pagebreak -->

---

## 4. Task Checklist

Please complete the tasks from the task sheet. After each task, mark the result and add comments if needed.

### Task 0 - Open the Local Node and FAIR Data Point

| Result | Select one |
| --- | --- |
| I logged in with the local credentials `admin` / `admin` | ☐ Yes ☐ Partially ☐ No |
| I selected the `default` project | ☐ Yes ☐ Partially ☐ No |
| I opened the `MEDIATA` Node | ☐ Yes ☐ Partially ☐ No |
| I opened the Node metadata panel | ☐ Yes ☐ Partially ☐ No |
| I found the FAIR Data Point button or badge | ☐ Yes ☐ Partially ☐ No |
| I copied the FAIR Data Point URL and opened it in another tab | ☐ Yes ☐ Partially ☐ No |
| Comments | |

### Task 1 - Open Discovery and Load Sample Datasets

| Result | Select one |
| --- | --- |
| I found the Discovery tab | ☐ Yes ☐ Partially ☐ No |
| I opened `sample_dataset_1.csv` first | ☐ Yes ☐ Partially ☐ No |
| I opened all four sample datasets together | ☐ Yes ☐ Partially ☐ No |
| Multi-file selection was clear | ☐ Yes ☐ Partially ☐ No |
| Comments | |

### Task 2 - Select Files and Hide One Feature

| Result | Select one |
| --- | --- |
| I enabled all loaded files in Discovery | ☐ Yes ☐ Partially ☐ No |
| I found `fim_total` using the feature toggles | ☐ Yes ☐ Partially ☐ No |
| I hid `fim_total` from the current view | ☐ Yes ☐ Partially ☐ No |
| I confirmed that `fim_total` disappeared from the current view | ☐ Yes ☐ Partially ☐ No |
| I showed `fim_total` again before continuing | ☐ Yes ☐ Partially ☐ No |
| Comments | |

<!-- pagebreak -->

### Task 3 - Inspect Columns and Value Summaries

| Result | Select one |
| --- | --- |
| I found one sex field and one smoking-related field | ☐ Yes ☐ Partially ☐ No |
| I found one diagnosis field | ☐ Yes ☐ Partially ☐ No |
| I found one FIM, Barthel, or related activity field | ☐ Yes ☐ Partially ☐ No |
| Equivalent fields across files were easy to recognize | ☐ Yes ☐ Partially ☐ No |
| Column names and data types were understandable | ☐ Yes ☐ Partially ☐ No |
| Summaries, charts, and missing-value indicators were useful | ☐ Yes ☐ Partially ☐ No |
| The feature type switch was understandable, if used | ☐ Yes ☐ Partially ☐ No ☐ Not used |
| Comments | |

### Task 4 - Filter One Dataset

| Result | Select one |
| --- | --- |
| I showed only `sample_dataset_1.csv` | ☐ Yes ☐ Partially ☐ No |
| I created filters for sex and FIM total or the closest available fields | ☐ Yes ☐ Partially ☐ No |
| The histogram charts changed after filtering as I expected | ☐ Yes ☐ Partially ☐ No |
| I reset the filters, the histograms changed back as I expected | ☐ Yes ☐ Partially ☐ No |
| I enabled all sample files again | ☐ Yes ☐ Partially ☐ No |
| Comments | |

### Task 5 - Review Aggregate Metrics

| Result | Select one |
| --- | --- |
| I switched to aggregate metrics | ☐ Yes ☐ Partially ☐ No |
| I viewed covariance | ☐ Yes ☐ Partially ☐ No |
| I changed to Pearson correlation | ☐ Yes ☐ Partially ☐ No |
| I changed to Spearman correlation | ☐ Yes ☐ Partially ☐ No |
| I resized the aggregate panels | ☐ Yes ☐ Partially ☐ No |
| I understood the omitted-feature UI | ☐ Yes ☐ Partially ☐ No ☐ No omitted features shown |
| Comments | |

### Task 6 - Detect and Clean a Planted Outlier

| Result | Select one |
| --- | --- |
| I found the outlier in one continuous measurement field | ☐ Yes ☐ Partially ☐ No |
| The integrity metrics made the issue visible | ☐ Yes ☐ Partially ☐ No |
| I found the Data cleaning panel from the File Explorer | ☐ Yes ☐ Partially ☐ No |
| I configured `Remove rows with pattern` for the affected column | ☐ Yes ☐ Partially ☐ No |
| I confirmed that the cleaned output no longer contained the outlier | ☐ Yes ☐ Partially ☐ No |
| Comments | |

### Task 7 - Generate Element Metadata for Integration

| Result | Select one |
| --- | --- |
| I was aware that only enabled datasets were used for element generation | ☐ Yes ☐ Partially ☐ No |
| I generated/uploaded element metadata for the datasets currently shown in Discovery | ☐ Yes ☐ Partially ☐ No |
| I could identify the generated element files and their source datasets | ☐ Yes ☐ Partially ☐ No |
| Comments | |

### Task 8 - Open Integration and Load Element Files

| Result | Select one |
| --- | --- |
| I found the Integration tab | ☐ Yes ☐ Partially ☐ No |
| I selected the generated element files for all four sample datasets | ☐ Yes ☐ Partially ☐ No |
| The feature list, selected feature area, controls, and result panel were understandable | ☐ Yes ☐ Partially ☐ No |
| Comments | |

### Task 9 - Create a Simple Manual Smoking-History Mapping

| Result | Select one |
| --- | --- |
| I selected the relevant smoking-related columns | ☐ Yes ☐ Partially ☐ No |
| I assigned source categories to output values | ☐ Yes ☐ Partially ☐ No |
| I created a target mapping for the columns | ☐ Yes ☐ Partially ☐ No |
| Comments | |

### Task 10 - Load the Target Schema and Rename Bathing

Use `evaluation/sample_schemas/sample_schema.json`.

| Result | Select one |
| --- | --- |
| I loaded the target schema | ☐ Yes ☐ Partially ☐ No |
| The schema-guided suggestions pointed to the expected target fields | ☐ Yes ☐ Partially ☐ No |
| I found or reviewed the bathing-related mapping in the schema | ☐ Yes ☐ Partially ☐ No |
| I renamed the bathing mapping to `bathing_status` using the in-app editor | ☐ Yes ☐ Partially ☐ No |
| The renamed mapping showed in the column name suggestions as I expected | ☐ Yes ☐ Partially ☐ No |
| Comments | |

<!-- pagebreak -->

### Task 11 - Run Suggested Mappings

| Result | Select one |
| --- | --- |
| I ran `Suggest mappings` | ☐ Yes ☐ Partially ☐ No |
| I understood the option to replace the current result | ☐ Yes ☐ Partially ☐ No |
| I inspected and understood some of the suggested column mappings | ☐ Yes ☐ Partially ☐ No |
| Suggested mappings grouped similar concepts sensibly | ☐ Yes ☐ Partially ☐ No |
| I corrected one questionable mapping, if needed | ☐ Yes ☐ Partially ☐ No ☐ Not needed |
| Comments | |

### Task 12 - Upload the Sample Mapping Specification

Use `evaluation/sample_mappings/sample_spec.json`.

| Result | Select one |
| --- | --- |
| I uploaded the sample mapping specification | ☐ Yes ☐ Partially ☐ No |
| I understood file resolution, if required | ☐ Yes ☐ Partially ☐ No ☐ Not required |
| The loaded mappings appeared in the result panel | ☐ Yes ☐ Partially ☐ No |
| Comments | |

### Task 13 - Edit One Existing Mapping

| Result | Select one |
| --- | --- |
| I inspected or edited one existing mapping successfully | ☐ Yes ☐ Partially ☐ No |
| The edit controls were clear | ☐ Yes ☐ Partially ☐ No |
| Comments | |

### Task 14 - Process the Datasets

| Result | Select one |
| --- | --- |
| I found the `Process datasets` action | ☐ Yes ☐ Partially ☐ No |
| I selected each source dataset that should be processed | ☐ Yes ☐ Partially ☐ No |
| The meaning of the modal, and the files presented, was clear | ☐ Yes ☐ Partially ☐ No |
| Comments | |

### Task 15 - Save, Export, and Reopen the Results in Discovery

| Result | Select one |
| --- | --- |
| I saved or downloaded the mapping specification | ☐ Yes ☐ Partially ☐ No |
| I found and renamed the produced `parsed_` files | ☐ Yes ☐ Partially ☐ No |
| I reopened the produced files in Discovery | ☐ Yes ☐ Partially ☐ No |
| I used feature search/toggles to focus on specific output columns | ☐ Yes ☐ Partially ☐ No |
| The produced file shape, columns, and value summaries were expected | ☐ Yes ☐ Partially ☐ No |
| Comments | |

---

## 5. Task Difficulty Ratings

Scale:  
1 = Very easy  
2 = Easy  
3 = Neutral  
4 = Difficult  
5 = Very difficult  
N/A = Not completed or not available

| Task | 1 | 2 | 3 | 4 | 5 | N/A |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 0. Local Node and FAIR Data Point | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| 1. Open Discovery and load sample datasets | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| 2. Select files and hide one feature | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| 3. Inspect columns and value summaries | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| 4. Filter one dataset | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| 5. Review aggregate metrics | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| 6. Detect and clean an outlier | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| 7. Generate element metadata | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| 8. Load element files in Integration | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| 9. Manual smoking-history mapping | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| 10. Load schema and rename bathing | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| 11. Run and review suggested mappings | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| 12. Upload sample mapping specification | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| 13. Edit one mapping | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| 14. Process datasets | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| 15. Save/export and reopen results | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |

---

## 6. Usability Questionnaire

Please answer using this scale:

1 = Strongly disagree  
2 = Disagree  
3 = Neutral  
4 = Agree  
5 = Strongly agree

### A. General Usability

| No. | Statement | 1 | 2 | 3 | 4 | 5 |
| ---: | --- | ---: | ---: | ---: | ---: | ---: |
| 1 | I think I would use MEDIATA for dataset discovery and integration tasks. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 2 | The platform was unnecessarily complex. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 3 | The platform was easy to use. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 4 | I would need help from a technical person to use this release effectively. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 5 | Discovery and Integration were clear in their purpose. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 6 | There was too much inconsistency between different parts of the platform. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 7 | I think most users with similar experience could learn this workflow. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 8 | Using the platform would increase the time taken to do the tasks rather than reduce it. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 9 | I felt confident using the platform. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 10 | I needed to learn too many things before I could complete the tasks. | ☐ | ☐ | ☐ | ☐ | ☐ |

### B. Tutorial and Independent Use

| No. | Statement | 1 | 2 | 3 | 4 | 5 |
| ---: | --- | ---: | ---: | ---: | ---: | ---: |
| 11 | The tutorial/help material was easy to find. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 12 | The tutorial explained the local login, default project, and default Node. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 13 | The tutorial explained file selection and multi-file selection. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 14 | The tutorial explained how to select files and hide or restore features in Discovery. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 15 | The tutorial explained aggregate metrics and omitted features. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 16 | The tutorial explained how generated element files are used in Integration. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 17 | The tutorial explained manual mappings and suggested mappings. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 18 | The tutorial explained processing datasets and checking parsed output. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 19 | I understood what I was expected to do without supervision. | ☐ | ☐ | ☐ | ☐ | ☐ |

### C. Node and Metadata

| No. | Statement | 1 | 2 | 3 | 4 | 5 |
| ---: | --- | ---: | ---: | ---: | ---: | ---: |
| 20 | The Node concept was clear and easy to identify after login. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 21 | The Node metadata panel was easy to open. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 22 | The FAIR Data Point badge or URL was easy to find. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 23 | Node metadata descriptions helped me understand the available datasets. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 24 | It was clear what the Node represents and how it relates to Discovery and Integration. | ☐ | ☐ | ☐ | ☐ | ☐ |

### D. Discovery Module

| No. | Statement | 1 | 2 | 3 | 4 | 5 |
| ---: | --- | ---: | ---: | ---: | ---: | ---: |
| 25 | The Discovery module made it easy to find available datasets. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 26 | Dataset names and file lists were understandable. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 27 | Opening one file and then several files was clear. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 28 | It was clear which files were currently enabled in the view. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 29 | It was clear how to show or hide features. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 30 | Column information was easy to find. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 31 | Value summaries and charts were readable. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 32 | Filters were easy to create and reset. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 33 | Aggregate metrics were understandable. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 34 | MEDIATA helped me notice the planted outlier. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 35 | Discovery gave me useful insights about the datasets. | ☐ | ☐ | ☐ | ☐ | ☐ |

### E. Integration Module

| No. | Statement | 1 | 2 | 3 | 4 | 5 |
| ---: | --- | ---: | ---: | ---: | ---: | ---: |
| 36 | The Integration module was easy to locate. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 37 | Loading multiple element files was clear. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 38 | The feature list made it clear which source columns were available. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 39 | The target schema was easy to load. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 40 | Target fields were easy to inspect. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 41 | Manual categorical mapping was understandable. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 42 | Numeric or range-based value mappings were understandable. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 43 | Suggested mappings were useful as a starting point. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 44 | Suggested mapping values or ranges were easy to review. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 45 | It was clear how to correct a suggested mapping. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 46 | The sample mapping specification was easy to upload. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 47 | Running the processing workflow was clear. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 48 | It was clear that each source file needed to be selected for processing. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 49 | Save or export actions were easy to find. | ☐ | ☐ | ☐ | ☐ | ☐ |

### F. Trust, Feedback, and Errors

| No. | Statement | 1 | 2 | 3 | 4 | 5 |
| ---: | --- | ---: | ---: | ---: | ---: | ---: |
| 50 | I could tell which mappings were complete and which needed review. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 51 | I could recover from mistakes without external help. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 52 | The platform clearly showed when it was loading or processing. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 53 | Error messages, if any appeared, were understandable. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 54 | Buttons and labels were understandable. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 55 | Tables, forms, and mapping views were readable. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 56 | The terminology used in the platform was clear. | ☐ | ☐ | ☐ | ☐ | ☐ |

### G. Overall Usefulness

| No. | Statement | 1 | 2 | 3 | 4 | 5 |
| ---: | --- | ---: | ---: | ---: | ---: | ---: |
| 57 | MEDIATA is useful for discovering available datasets. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 58 | MEDIATA is useful for managing integration mappings. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 59 | MEDIATA would reduce manual effort compared with spreadsheet-based integration. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 60 | I would recommend MEDIATA for similar integration workflows. | ☐ | ☐ | ☐ | ☐ | ☐ |
| 61 | Overall, I am satisfied with this MEDIATA release. | ☐ | ☐ | ☐ | ☐ | ☐ |

---

## 7. Open Questions

1. What was the easiest part of the workflow?

2. What was the most confusing part of the workflow?

3. Was the tutorial sufficient for learning the tool workflow? If not, what was missing?

4. Which tool action was hardest to find?

5. Did multi-file selection work as expected in Discovery, Integration, and processing?

6. Did the Discovery file/feature visibility controls make sense?

7. Was the planted outlier cleaning task concrete enough to complete independently?

8. Did the generated element metadata workflow make sense?

9. Which mapping or value-mapping interaction was hardest to understand?

10. Did suggested mappings provide a useful starting point? Would you rather use them to start a complete mapping process than the separate present columns from the datasets?

11. Did the mapping-spec upload and file-resolution flow make sense?

12. Did MEDIATA provide enough feedback to trust the processed output? Why or why not?

13. Did you encounter any error, unexpected behavior, or unclear message?

14. What functionality would you expect in a future release?

15. Any additional comments or suggestions?

---

## 8. Submission Confirmation

By submitting this questionnaire, I confirm that I completed the evaluation independently using the provided MEDIATA release, datasets, target schema, and sample mapping specification.

| Field | Answer |
| --- | --- |
| Date | |
| Optional signature/name | |
