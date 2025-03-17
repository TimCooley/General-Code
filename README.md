Financial Operations SQL Scripts

Overview

This repository contains a collection of SQL scripts used for financial operations, reconciliation, and reporting. These scripts facilitate data processing, transaction analysis, and automated reporting for financial case management.

Scripts Included

1. Auto_Recon_Procs.sql

Automates reconciliation procedures for case transactions.

Excludes ineligible instruments and identifies duplicate transactions.

2. CDR Report (Weekly & Monthly).sql

Generates comprehensive reports on financial case tracking.

Includes complaint details, participation types, and case status breakdowns.

3. DIFF_FILE_DUPE_HOLDING PROC.sql

Identifies and excludes duplicate holding positions across different files.

Ensures data consistency in transaction records.

4. DIFF_FILE_DUPE_PROC.sql

Flags duplicate financial transactions across multiple datasets.

Updates records to prevent redundant processing.

5. IN_AND_OUT_SECURITY_IDENTIFIER_MODIFIED proc.sql

Analyzes and modifies security identifiers for transactions.

Validates buy/sell transactions and applies relevant rules.

6. Ineligible Trans Type Exclusion Proc.sql

Excludes transactions involving ineligible instruments like swaps and CFDs.

Applies necessary filters based on client and account statuses.

7. L10 Report.sql

Generates Level 10 Metrics reports for financial analysis.

Tracks outstanding JIRA tickets and reconciliation progress.

8. Recon Percentage.sql

Computes reconciliation percentage metrics.

Differentiates between reconciled and unreconciled accounts.

9. Synth Trade Generator Merger Case (Multi Client & Account).sql

Simulates synthetic trade transactions for merger cases.

Processes multiple clients and accounts to generate financial scenarios.

Usage

Ensure you have appropriate database access and permissions.

Execute these scripts in an Oracle SQL environment.

Modify parameters such as CASE_ID_VAR as needed.
