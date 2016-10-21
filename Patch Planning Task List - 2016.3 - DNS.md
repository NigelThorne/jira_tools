Project Planning
================
// * Change Request (CR9362)
* Software Patch Plan
* QMS Deviations (as applicable)
* Risk Register in the Patch Plan
* Document Map -- DHFR_8870_A05 APiQ Documents Map
* Software Readiness Review
* Defect Review Board

Design Inputs / Outputs
=======================
* Requirements
** Update existing Requirements & close gaps
** Requirements review and Minutes
** Requirements approval 
//** Review/Update Compatibility Matrix (ios10 & Ios 9.3.5)

//* Update DIs and DOs
//** Review DIs and DOs to see if any are impacted (DHFR 6806.14 and 6806.15)
//** Update where required 

* Update Solution Architecture
//** Review/Update Compatibility Matrix (ios10 & Ios 9.3.5)

* Baseline PreFormal Requirements & Test cases
* Baseline PostFormal Requirements & Test cases
* Detailed Design Review

Verification & Validation
=========================
* V&V environment plans
* Automation planning in Patch Plan
* Change Impact Analysis for Patch in Patch Plan
* Software Test Completion Report (QF0208)

Product Safety
==============
* Safety Impact Analysis
** Safety Analysis for Patch (FHA | FMEA)
** FMEA / FHA review minutes -- Update Patch Plan to refer to the appropriate SARs for this impact assessment.
* Safety Assessment Report (for Cloud)
// * Safety Assessment Report (for ID)
// * Safety Assessment Report (for IM)
* Perform "Process FMEA"

Software Production
===================
* APiQ Back Office Software - DMR
* APiQ Back Office SVD - DHFR
//* APiQ Application Software - DMR
//* APiQ Application SVD - DHFR
* Snapshot / Archive Build Pipeline for Formal Release
** Backup Build Agent 
** Backup Team City project
* Software Equivalence Statement
// * Smoke test HUB and Cloud

Software Release
================
* Software Release External Notes + Appendices
//* Upload IM Software to AppStore
//** create records - version change only
//** DO NOT RELEASE!! - leave as Manual release
//** You need a shadow
//* Verify IM AppStore settings and records
//* Upload ID Software to AppStore
//** create records - version change only
//** DO NOT RELEASE!! - leave as Manual release
//** You need a shadow
//* Verify ID AppStore settings and records
* Smoke test
