# Data Extraction Prompt for Adult ADHD Diagnostic Tool Studies

## DOMAIN
Neuropsychological, Cognitive and Psychoeducational Tests for Adult ADHD Diagnosis

## OBJECTIVE
Extract comprehensive diagnostic accuracy data from published studies evaluating adult ADHD assessment measures to create a structured summary table for meta-analysis and clinical reference.

## EXTRACTION PROCEDURE

### Phase 1: Document Processing
1. Upload each PDF file containing study data on adult ADHD diagnostic tools
2. Index the full text content with particular attention to methods, results, and tables sections
3. Identify tables reporting diagnostic accuracy metrics (sensitivity, specificity, PPV, NPV)
4. Flag sections discussing sample characteristics and demographic information

### Phase 2: Data Extraction
For each identified study, extract the following variables:

**Study Identification:**
- Study (Author(s), Year)
- Journal, Volume, Pages
- Country where study was conducted

**Sample Characteristics - ADHD Group:**
- Sample Size ADHD (n)
- Age (Mean ± SD) ADHD
- Gender ADHD (% male/female)
- ADHD subtype distribution (if reported)
- Medication status during assessment (if reported)
- Comorbidities (if reported)

**Sample Characteristics - Control Group:**
- Sample Size Controls
- Control group type (healthy volunteers, clinical controls, or mixed)
- Age (Mean ± SD) Controls
- Gender Controls (% male/female)
- Exclusion criteria for controls

**Assessment Measures:**
- Measure Name (full name and abbreviation)
- Measure type (self-report, informant-report, performance-based, interview)
- Administration format (paper-pencil, computerized, clinician-administered)
- Scoring method and cutoff criteria used

**Diagnostic Performance Metrics:**
- Sensitivity (%) with confidence intervals if available
- Specificity (%) with confidence intervals if available
- Positive Predictive Value (PPV) (%) if available
- Negative Predictive Value (NPV) (%) if available
- Area Under Curve (AUC) if available
- Likelihood ratios (positive and negative) if available
- Diagnostic odds ratio if available

**Methodological Quality:**
- Reference standard used for ADHD diagnosis
- Blinding procedures (if reported)
- Time interval between index test and reference standard (if reported)
- Study limitations noted by authors

### Phase 3: Data Formatting
1. Compile all extracted data into a structured markdown table
2. Format the table with clear column headers and consistent data presentation
3. Include footnotes for any special considerations or important methodological notes
4. Sort the table by publication year (newest to oldest) or alphabetically by first author
5. Include full citation information for each study in a references section

## OUTPUT FORMAT
Create a markdown-formatted table with the following columns:

| Study | Sample Size ADHD | Age (Mean ± SD) ADHD | Gender ADHD | Sample Size Controls | Control Type | Age (Mean ± SD) Controls | Gender Controls | Measure Name | Sensitivity (%) | Specificity (%) | PPV (%) | NPV (%) | Notes |
|-------|-----------------|---------------------|-------------|---------------------|--------------|--------------------------|-----------------|--------------|----------------|-----------------|---------|---------|-------|

## SPECIAL INSTRUCTIONS
- When multiple measures or cutoffs are reported in a single study, include separate rows for each
- For studies reporting diagnostic accuracy across different subgroups, extract data for each subgroup
- If confidence intervals are reported for sensitivity/specificity, include these in parentheses
- If certain data fields are not reported in a study, indicate with "NR" (Not Reported)
- For studies reporting ranges instead of means and SDs for age, record as reported
- If diagnostic accuracy metrics are presented in figures rather than tables, extract approximate values and note with asterisk
