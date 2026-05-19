# Evaluation Tasks

**Evaluation type:** Unsupervised remote evaluation  
**Estimated time:** 30-45 minutes

---

## 1. Before Starting

In this evaluation, you will use MEDIATA to inspect several sample datasets, generate the metadata needed for integration, create or review mappings, process the datasets, and inspect the produced files.

The goal is to evaluate the tool workflow. You are not being evaluated on clinical knowledge nor federated learning. Focus on whether MEDIATA helps you find files, understand columns and values, build mappings, review suggestions, process data, and recover from mistakes.

Before starting:

- Launch the local deployment using the `readme.md` from the umbrella repository (`github.com/tecnomod-um/MEDIATA_project`), section `local deployment`.
- Open the tutorial page from the navigation bar in a new tab.
- Keep this task sheet and the questionnaire available while working.

---

## 2. Evaluation Focus

These tasks evaluate two parts of MEDIATA:

- **Discovery:** finding datasets, selecting several files, inspecting columns, values, data types, filters, aggregate statistics, and data-quality signals.
- **Integration:** generating element metadata, loading those element files, using or creating mappings, reviewing suggested mappings, loading a schema or mapping specification, processing datasets, and checking the resulting files.

When a task asks you to "record" something, write it in the questionnaire.

---

## 3. Node and Metadata Tasks

### Task 0 - Open the Local Node and FAIR Data Point

**Purpose:** Check whether users can reach the local workspace and understand where public metadata is exposed.

1. Log in with `admin` / `admin`.
2. Select the `default` project.
3. Open the `MEDIATA` Node.
4. Open the Node metadata panel.
5. Find the FAIR Data Point badge.
6. Copy the FAIR Data Point URL and open it in another browser tab.

Record whether the project, Node, metadata panel, and FAIR Data Point URL were easy to find.

---

## 4. Discovery Tasks

### Task 1 - Open Discovery and Load Sample Datasets

**Purpose:** Check whether users can find the data inspection area and load several datasets.

1. Open the Discovery tab. The File Explorer will open.
2. Open `sample_dataset_1.csv` first.
3. Reload the page.
4. Then open all four sample datasets together.

Use multi-selection when needed: `Ctrl`-click or `Shift`-click on desktop, or long-press a file row to enter multiple-selection mode.

Record whether file selection, multi-selection, and opening files were clear.

### Task 2 - Select Files and Hide One Feature

**Purpose:** Check whether users understand that loaded files, selected files, and visible features are controlled separately.

1. Use the Discovery file selector to enable all loaded sample datasets.
2. In the feature toggles, search for `fim_total`.
3. Hide `fim_total` from the current view.
4. Confirm that it disappears from the tables/charts.
5. Show `fim_total` again before continuing.

Record whether it was clear how to select files, search for a feature, hide it, and show it again.

### Task 3 - Inspect Columns and Value Summaries

**Purpose:** Check whether users can inspect the information needed before integration.

1. Find a sex or gender column.
2. Find at least one functional score column, such as an eating, bathing, toileting, FIM, or Barthel field.
3. Inspect the displayed type, examples, counts, charts, and missing-value information.
4. If a feature seems to be shown in the wrong type table, use the selected feature type switch to view it as categorical or continuous.

Record whether column names, values, data types, and summaries were understandable.

### Task 4 - Filter One Dataset

**Purpose:** Check whether users can focus on a subset of records without manually scanning the whole table.

1. In Discovery, show only `sample_dataset_1.csv`.
2. Add filters to show male patients with a FIM total under 15, or the closest available fields if names differ.
3. Observe whether the charts and tables change.
4. Reset the filters.
5. Enable all sample files again.

Record whether the filter controls and the updated charts were clear.

### Task 5 - Review Aggregate Metrics

**Purpose:** Check whether users can inspect relationships between columns and understand omitted features.

1. Switch to aggregate metrics.
2. View covariance.
3. Change the metric to Pearson correlation.
4. Change the metric to Spearman correlation.
5. Resize the upper and lower panels.
6. Inspect the omitted-features panel and note one reason why a feature was omitted, if any are listed.

Record whether the metric selector, resizing, and omitted-feature explanations were understandable.

### Task 6 - Detect and Clean a Planted Outlier

**Purpose:** Check whether users can notice an obvious data-quality issue and apply a concrete cleaning step.

1. In Discovery, inspect `sample_dataset_1.csv`.
2. Select `systolic_bp` and use the outliers switch/chart to notice the planted value `999`.
3. Reload Discovery, in the File Explorer, select `sample_dataset_1.csv`, and open Data cleaning.
4. Choose `Remove rows with pattern`.
5. Configure it for column `systolic_bp` with a pattern that removes only the outlier row, for example `^999$`.
6. Apply the cleaning step.
7. Open the cleaned output in Discovery and confirm that the `999` value is gone.

Record whether the outlier was visible, whether the cleaning operation was understandable, and whether the cleaned output was easy to verify.

### Task 7 - Generate Element Metadata for Integration

**Purpose:** Check whether users can move from Discovery into Integration using the intended tool flow.

1. Return to Discovery with all four sample datasets loaded.
2. Use `Upload elements` to generate/upload the element metadata files.
3. Note the generated element files and where they appear.

Record whether it was clear that Integration uses generated element metadata rather than the raw datasets directly.

---

## 5. Integration Tasks

### Task 8 - Open Integration and Load Element Files

**Purpose:** Check whether users can start the mapping workflow with all relevant files.

1. Open the Integration tab.
2. In the File Explorer, select the generated element files for all four sample datasets.
3. Use `Ctrl`-click, `Shift`-click, or long-press to select multiple files.
4. Open them and inspect the Integration screen.

Record whether the feature list, selected feature area, mapping controls, and resulting mapping panel were clear.

### Task 9 - Create a Simple Manual Sex/Gender Mapping

**Purpose:** Check whether users can create a small categorical mapping by hand.

1. Select the available sex or gender columns.
2. Create a target mapping such as `sex`.
3. Add normalized values such as `Female`, `Male`, and `Unknown` when applicable.
4. Assign the source categories to the normalized output values.
5. Add the mapping to the result.

Record whether value selection and categorical mapping were understandable.

### Task 10 - Load the Target Schema and Rename Bathing

**Purpose:** Check whether users can load a schema and use it to guide mapping work.

Use `evaluation/sample_schemas/sample_schema.json`.

1. Open the Schema tab.
2. Upload the target schema.
3. Inspect the target fields.
4. Find or create/review the bathing-related mapping.
5. Using the in-app mapping editor, rename the resulting bathing column to `bathing_status`.
6. Confirm that the result panel shows the renamed mapping.

Record whether the schema loaded, whether target fields were visible, and whether renaming the bathing mapping in the editor was clear.

### Task 11 - Run Suggested Mappings

**Purpose:** Check whether users can generate, inspect, and correct automatic mapping suggestions.

1. Click `Suggest mappings`.
2. Use the option that lets you review or replace the current result, depending on what the UI offers.
3. Inspect the suggested column groups.
4. Inspect the values or numeric ranges inside at least three suggested mappings.
5. Correct one questionable mapping if you find one.

Pay special attention to whether similar concepts are grouped sensibly, such as eating with eating, bathing with bathing, and toileting with toileting. Also check that different categories are not collapsed incorrectly.

Record whether suggestions were useful, whether value assignments were understandable, and what you corrected, if anything.

### Task 12 - Upload the Sample Mapping Specification

**Purpose:** Check whether users can load a prepared mapping file instead of building everything from scratch.

Use `evaluation/sample_mappings/sample_spec.json`.

1. Upload the sample mapping specification.
2. Resolve source files if the interface asks for it.
3. Confirm that mappings appear in the result panel.

Record whether upload, file resolution, and loaded mappings were understandable.

### Task 13 - Edit One Existing Mapping

**Purpose:** Check whether users can safely adjust the mapping specification.

Choose one mapping to inspect or modify. Suggested options:

- `smoker`
- `bmi`
- an eating, bathing, toileting, FIM, or Barthel score mapping

Record what you changed and whether the interface gave enough feedback.

### Task 14 - Process the Datasets

**Purpose:** Check whether users can apply the mapping to produce harmonized output files.

1. Click `Process datasets`.
2. In the processing modal, select each source dataset that should be transformed.
3. Apply the mapping.
4. Observe progress and output feedback.

Record whether it was clear that each file needed to be selected and whether the output was understandable.

### Task 15 - Save, Export, and Reopen the Results in Discovery

**Purpose:** Check whether users can preserve the mapping work and validate the produced files.

1. Save or download the mapping specification.
2. Return to the File Explorer.
3. Find the produced `parsed_` files.
4. Rename the produced files if needed.
5. Open the produced files in Discovery.
6. Enable the relevant produced files.
7. Inspect their shape, columns, and at least one value summary.
8. Use the feature search/toggles to focus on one resulting score column and one resulting categorical column.
9. If you notice a minor format issue, open the Data cleaning panel and inspect the available fix options.

Record whether the output files were easy to find, whether renaming was clear, and whether the parsed files looked usable in Discovery.

---

## 6. After Completing the Tasks

After finishing the workflow:

- Fill in the questionnaire.
- Mark each task as completed, partially completed, or not completed.
- Rate the difficulty of each task.
- Complete the usability statements.
- Add comments where something was confusing, unclear, or unexpected.
- Submit the completed questionnaire using the method provided with the release package.
