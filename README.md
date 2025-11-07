# DevOps Auditor Project
# 🛡️ GCP DevOps Auditor Pipeline: Shift Left Security & FinOps

## 🚀 Project Overview

This project demonstrates the creation of a robust and reliable CI/CD pipeline (GitHub Actions) designed to automatically audit and enforce checks on Infrastructure as Code (IaC) targeting Google Cloud Platform (GCP).

The project's goal is to integrate security and cost checks at the earliest stage of development (**Shift Left**), preventing dangerous or overly expensive code from reaching the main branch.



### 🎯 Key Features:

1.  **Security Gate:** The pipeline **blocks the Pull Request merge** if the **Checkov** scanner identifies critical security vulnerabilities or policy violations (e.g., world-open SSH, missing encryption).
2.  **FinOps (Cost Governance):** Uses **Infracost** to calculate and publish a **cost difference (Diff) report** directly within the Pull Request comments, showing the financial impact of the proposed change.
3.  **Reliability:** The project demonstrates expert **GitHub Actions Engineering**, including resolving complex issues with pathing (`cd` command usage) and external action versioning.

## 🛠️ Architecture and Tools

| Category | Tool | Role |
| :--- | :--- | :--- |
| **Infrastructure** | **Terraform** | Infrastructure as Code (IaC) for GCP resources. |
| **CI/CD** | **GitHub Actions** | Orchestration platform for pipeline execution. |
| **Security** | **Checkov** | Static Analysis Security Testing (SAST) for Terraform. Configured for **Hard Fail** on policy violations. |
| **Cost** | **Infracost** | Calculates infrastructure cost and provides a cost comparison (`diff`) between the base branch and the PR branch. |
| **Platform** | **Google Cloud Platform (GCP)** | Target cloud environment. |

## ⚙️ Working Process Demonstration

The pipeline runs on every Pull Request targeting the `main`/`master` branch, executing two jobs in parallel: `security-scan` and `cost-scan`.

### Phase 1: The Block (Initial Failure)

1.  **Action:** A developer creates a PR containing a highly expensive VM (`n2-standard-16`) and an insecure firewall rule (`source_ranges = ["0.0.0.0/0"]`).
2.  **`security-scan`:** **Fails (❌)**. Checkov detects the open SSH port and blocks the merge.
3.  **`cost-scan`:** **Succeeds (✔)**. Infracost publishes a comment: **"Warning: +$350.00 per month"**.
4.  **Result:** The "Merge" button is **blocked**. The pipeline successfully acts as an "auditor," informing the team of the risks.

### Phase 2: The Fix (Successful Merge)

1.  **Action:** The developer commits a fix, changing the VM to an affordable tier (`e2-micro`) and the firewall to a secure range (`source_ranges = ["1.2.3.4/32"]`). A `checkov:skip=` tag is used to manage acceptable, non-critical policies.
2.  **`security-scan`:** **Succeeds (✔)**. All security issues are resolved.
3.  **`cost-scan`:** **Succeeds (✔)**. Infracost **updates the comment**: **"Difference: -$345.00 per month"**.
4.  **Result:** **"All checks have passed"** (✔), and the "Merge" button turns green, allowing the safe merging of the code.

