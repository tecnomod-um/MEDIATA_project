# Evaluation Tasks

**Evaluation type:** Unsupervised remote evaluation  
**Estimated time:** 30-45 minutes

---

## 1. Before Starting

You have received a prepared MEDIATA release with sample CSV datasets, a target schema, and a sample mapping specification.

Please complete the evaluation independently. The goal is to evaluate MEDIATA as a tool, not your knowledge of the sample datasets.

Before starting:

- Open the MEDIATA release.
- Log in with username `admin` and password `admin`.
- Open the tutorial/help page.
- Keep the questionnaire PDF available while completing the tasks.

---

## 2. Evaluation Focus

MEDIATA is intended to support two related activities:

- **Discovery:** finding available datasets and understanding their columns, values, and basic quality before integration.
- **Integration:** loading or creating a mapping specification, connecting source columns to a target schema, reviewing value mappings, running the harmonization workflow, and saving or exporting the result.

The tasks below are designed to test whether the tool makes those activities understandable and efficient. The sample datasets are only test material.

---

## 3. Discovery Tasks

### Task 1 - Find the Discovery Area

Open the Discovery area of the application.

**Purpose:** Evaluate whether users can locate the part of the tool used to inspect available data.

Record whether you could find the Discovery area without external help.

### Task 2 - Confirm Available Datasets

Find the list of available sample datasets.

**Purpose:** Evaluate whether MEDIATA clearly shows what files are available for inspection.

Suggested UI steps:

- In Discovery, enable or select **all files** so every available sample dataset is shown.
- If the UI provides file checkboxes or a multi-file selector, press and hold briefly when selecting files if a normal click only opens a single file.
- Confirm that all four sample datasets are visible before continuing.

Record:

- how many datasets you see,
- whether their names are readable,
- whether it is clear how to open one.

### Task 3 - Open a Dataset Preview

Open any sample dataset and inspect its preview or table view.

**Purpose:** Evaluate whether the preview helps users understand the shape of a file before mapping it.

Record:

- whether the table loaded,
- whether columns and values were readable,
- whether horizontal scrolling, paging, or table controls were clear.

### Task 4 - Inspect Column Information

Inspect the column list, metadata, or generated element information for at least two datasets.

**Purpose:** Evaluate whether users can see the column names and basic column details needed for integration.

Record whether you could find column names, data types, examples, or summaries.

### Task 5 - Search or Filter

Use a search, filter, or table-control feature to find a column or value.

Suggested terms to try: `sex`, `gender`, `date`, `fim`, `barthel`, or `diagnosis`.

**Purpose:** Evaluate whether users can quickly locate relevant fields without manually scanning every column.

Record which term you searched for and whether the result was useful.

### Task 6 - Spot Data Quality Signals

Use previews or summaries to look for missing values, inconsistent values, or columns that may need transformation.

**Purpose:** Evaluate whether MEDIATA helps users notice issues before they start mapping.

Record at least one issue or uncertainty you noticed. You do not need to solve it.

---

## 4. Integration Tasks

### Task 7 - Find the Integration Area

Open the Integration or Harmonization area.

**Purpose:** Evaluate whether users can locate the part of the tool used to map and harmonize datasets.

Record whether the entry point was clear.

### Task 8 - Load the Target Schema

Upload or select the provided target schema file.

**Purpose:** Evaluate whether users can provide the schema that defines the expected integrated structure.

Use:

- `evaluation/sample_schemas/sample_schema.json`

Suggested UI steps:

- In Integration, find the schema upload or schema selection control.
- If the file picker is filtered, switch it to show all files so `.json` files are visible.
- Choose the target schema JSON file.
- Confirm that the schema panel or target-field list updates.
- If the app shows a parse or validation message, read it before continuing.

Record whether the schema loaded and whether the target fields were visible.

### Task 9 - Load the Sample Mapping Specification

Upload the provided sample mapping specification.

**Purpose:** Evaluate whether users can load an existing integration draft rather than starting from zero.

Use:

- `evaluation/sample_mappings/sample_spec.json`

Suggested UI steps:

- In Integration, find the mapping-spec upload/import control.
- If the file picker is filtered, switch it to show all files so `.json` files are visible.
- Choose `sample_spec.json`.
- If MEDIATA opens a resolution dialog, review each referenced source file.
- For each unresolved source, select the local node that contains the sample datasets.
- Match each referenced element file to the corresponding local element file, for example `sample_dataset_1_elements.csv` to the local file with the same name.
- Check any compatibility warning shown by the dialog.
- Confirm the resolution and wait for the mappings to load.

Record whether the upload and any required resolution steps were understandable.

### Task 10 - Review Loaded Mappings

Review the loaded mappings in the Integration area.

**Purpose:** Evaluate whether users can understand an existing mapping specification after upload.

Look for mappings such as:

- `patient_id`
- `sex`
- `age`
- `admission_date`
- `diagnosis_code`
- `fim_eating`
- `barthel_total`

Record whether mappings are easy to browse, expand, and inspect.

### Task 11 - Review a Value Mapping

Open the mapping for `sex` and inspect how source values are normalized.

**Purpose:** Evaluate whether categorical value mapping is understandable.

Check whether values such as `M`, `F`, `Male`, `Female`, `1`, and `0` are visible in a way that makes sense.

Record whether you trust the mapping and whether anything is unclear.

### Task 12 - Edit or Add a Mapping

Make one small change to a mapping, or add one simple mapping if editing is clearer than changing an existing one.

Suggested options:

- add or inspect `smoker`,
- add or inspect `bmi`,
- review a FIM or Barthel score field.

**Purpose:** Evaluate whether users can safely modify the mapping specification.

Record what you changed and whether the interface gave useful feedback.

### Task 13 - Run or Preview Harmonization

Run the harmonization/integration workflow, or generate a preview if the release supports preview before running.

**Purpose:** Evaluate whether users can move from mapping configuration to an integrated output.

Record:

- whether the action was easy to find,
- whether loading/progress feedback was clear,
- whether the output or preview was understandable.

### Task 14 - Save or Export

Save or export the mapping specification or harmonized result.

**Purpose:** Evaluate whether users can preserve work and share it with collaborators.

Record:

- whether save/export was available,
- whether the resulting file was easy to find,
- whether you would know what to send to another user.

---

## 5. After Completing the Tasks

After finishing the workflow:

- Fill in the questionnaire PDF.
- Answer the task completion questions.
- Rate the task difficulty.
- Complete the usability questionnaire.
- Add comments where something was confusing, unclear, or unexpected.
- Submit the completed questionnaire using the method provided with the release package.
