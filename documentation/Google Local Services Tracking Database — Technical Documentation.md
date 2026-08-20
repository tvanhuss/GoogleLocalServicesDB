# Google Local Services Tracking Database
## Technical Documentation

**Application:** Microsoft Access  
**Purpose:** Track Google Local Services charged leads from import through review, reconciliation, completion, and publication to reporting history.

---

# 1. System Purpose

The Google Local Services Tracking Database is used to process and analyze charged leads received from Google Local Services through SearchKings.

The system intentionally tracks only leads that Google originally identifies as charged.

Uncharged calls such as wrong numbers, abandoned calls, and similar contacts are excluded from long-term reporting because they have no meaningful marketing-cost value for this application.

A lead remains part of the historical dataset even if it is later disputed and credited.

---

# 2. Primary Tables

## tblTransProcess

`tblTransProcess` is the active processing/workflow table.

Imported lead records remain in this table while they move through the required review processes.

Typical workflow fields include:

- `callReviewed`
- `leadDisputeReviewed`
- `leadSage300CREReviewed`
- `leadRevenueReviewed`
- `leadGLSChargeReviewed`

These fields should be interpreted primarily as:

**the applicable workflow requirement has been satisfied**

rather than literally meaning that an employee manually performed that review.

For example, a Lost call has no applicable Sage or Revenue processing, so those requirements may be marked satisfied automatically.

## tblCalls

`tblCalls` is the completed historical/reporting dataset.

Only originally charged leads are published to this table.

`leadID` is the Primary Key and prevents the same lead from being published more than once.

## tblAuditLog

`tblAuditLog` records final publish operations, including:

- date/time
- Windows user
- processing period
- records published
- uncharged records deleted
- action notes

---

# 3. Overall Workflow

The current workflow is:

**Import SearchKings data**

→ **Call Review**

→ one of:

- Booked
- Lost
- Disputed

Then:

### Booked

→ Sage 300 CRE Review  
→ Revenue Review if revenue was not already finalized during Sage Review  
→ GLS Charge Processing

### Lost

→ GLS Charge Processing

### Disputed

→ Dispute Follow-up only if Google's decision is Pending  
→ GLS Charge Processing

Once all workflow requirements are satisfied:

→ **Publish Completed Leads**  
→ `tblCalls`

---

# 4. Workflow Design Principle

The application distinguishes between:

**ordinary record editing**

and

**explicit workflow completion**

A user may enter partial information and navigate to another record without advancing the workflow.

Workflow completion occurs only when the user intentionally clicks the applicable business-action command button.

Examples:

- Accept and Update Record
- Update Dispute Status
- Complete Sage Review
- Complete Revenue Review

Completion-specific validation is controlled through form-level logic so ordinary navigation does not force the user to complete a record prematurely.

---

# 5. Call Review

## Forms and Queries

- `frmCallSourceReview`
- `frmSubCallSourceReview`
- Call Review query filters charged calls that have not yet completed Call Review.

Eligibility:

`leadIsCharged = True`

and

`callReviewed = False`

## Business Outcome

The reviewer determines exactly one call disposition:

- Booked
- Lost
- Disputed

## Booked

Application establishes:

- Call Review complete
- Dispute processing not applicable
- Sage Review required
- Revenue Review required
- GLS Charge processing required

## Lost

Application establishes:

- Call Review complete
- Dispute processing not applicable
- Sage Review not applicable
- Revenue Review not applicable
- Revenue = 0
- GLS Charge processing required

## Disputed

A disputed lead represents a call that did not result in booked work.

The reviewer submits the dispute to Google during Call Review and records Google's immediate response when available.

Valid dispute results:

- Pending
- Denied
- Credited

### Pending

- dispute remains open
- `leadDisputeReviewed = False`
- `leadIsCredited = False`

### Denied

- dispute is complete
- `leadDisputeReviewed = True`
- `leadIsCredited = False`

### Credited

- dispute is complete
- `leadDisputeReviewed = True`
- `leadIsCredited = True`

Disputed calls have:

- no Sage processing requirement
- no revenue requirement
- revenue = 0
- GLS charge processing still required

---

# 6. Dispute Follow-up

## Form

`frmProcessGoogleDisputes`

This form contains only disputes whose Google result has not yet been finalized.

The user records:

- Pending
- Denied
- Credited

The user completes the action using:

**Update Dispute Status**

Normal navigation may save an interim credit-status value without completing the workflow.

This is intentional.

If a final result is entered but the completion action is not performed:

- the record remains in the dispute queue
- diagnostics may flag the condition as a warning
- the record is not silently advanced

---

# 7. Sage 300 CRE Review

## Form and Query

- `frmProcessSage300CRE`
- `qryProcessSage300CRE`

Only Booked charged leads requiring Sage processing enter this workflow.

The reviewer attempts to locate the customer/job in Sage 300 CRE using:

- address
- customer
- phone number if necessary

The reviewer records:

- verified customer information
- primary work order number
- whether the lead produced a new customer
- revenue if already final

A single GLS lead may produce multiple work orders.

`leadWONumber` stores the primary/original work order.

`leadRevenue` represents the combined revenue attributable to all related work orders.

## Sage Outcomes

### Still Booked / Revenue Pending

- primary WO required
- Sage Review complete
- Revenue Review remains open

### Still Booked / Revenue Final

- primary WO required
- revenue required
- zero revenue is allowed
- Sage Review complete
- Revenue Review complete

### Changed to Lost

A call may originally be Booked but later be found cancelled.

A work order may not exist if the customer cancelled before AR/work-order setup was completed.

In this case:

- status changes to Lost
- WO is not required
- revenue = 0
- Sage requirement satisfied
- Revenue requirement satisfied

Workflow completion occurs through:

**Complete Sage Review**

Normal navigation saves interim edits without completing the workflow.

---

# 8. Revenue Review

## Form and Query

- `frmProcessRevenue`
- `qryProcessRevenue`

Typical eligibility:

- call remains Booked
- lead is charged
- Sage Review complete
- Revenue Review incomplete
- lead is at least seven calendar days old

The waiting period allows work to progress before revenue follow-up.

## Revenue Rules

`leadRevenue` is the total revenue attributable to the GLS lead across all related work orders.

Revenue may legitimately equal zero even if the call remains Booked.

Revenue may not be negative.

Workflow completion occurs through:

**Complete Revenue Review**

Normal navigation may save interim revenue information without completing Revenue Review.

---

# 9. GLS Charge Processing

## Form and Query

- `frmProcessGLSCharges`
- `qryProcessGLSCharges`

GLS charges are applied in bulk by:

- Start Date
- End Date
- Department
- SearchKings average GLS charge

Departments include:

- ELEC
- HVAC
- PLUM

GLS cost varies by department and reporting period.

## Gross Charge Rule

`leadChargeAmount` stores the estimated gross GLS charge.

A credited dispute still retains the original gross charge.

Therefore:

- `leadIsCharged = True`
- `leadChargeAmount > 0`
- `leadIsCredited = True`

is a valid combination.

Credits are treated separately in reporting.

## Bulk-Update Safeguards

The process validates:

- Start Date
- End Date
- Start Date <= End Date
- valid department
- numeric GLS charge
- nonnegative GLS charge

The application counts eligible records and displays a confirmation before the update runs.

Records already marked `leadGLSChargeReviewed = True` are excluded from reprocessing.

---

# 10. Date/Time Range Standard

`leadDate` may contain a time component.

Inclusive calendar date ranges must therefore use:

`Field >= StartDate`

and

`Field < DateAdd("d", 1, EndDate)`

rather than:

`Between StartDate And EndDate`

This prevents records later in the selected End Date from being silently excluded.

This pattern is used for:

- SELECT queries
- UPDATE queries
- DELETE operations
- APPEND operations
- preview filters
- publication logic

---

# 11. Workflow Diagnostics

The system contains a diagnostic layer independent of the normal workflow forms.

## qryWorkflowOpenItems

Interprets workflow fields into a readable business state.

Typical `OpenReason` values:

- Call Review
- Dispute Follow-up
- Sage Review
- Revenue Review
- GLS Charge
- Complete

Also provides a human-readable `NextAction`.

## qryWorkflowStillOpen

Filters completed records from the workflow evaluation query.

Used by:

`frmWorkflowOpenItems`

## frmWorkflowOpenItems

Read-only operational dashboard showing:

- Lead Date
- Lead ID
- Call Status
- Department
- What's Still Open
- Next Action

Future enhancement:

Allow drill-down directly to the applicable processing form and record.

## qryWorkflowExceptions

Identifies contradictory or suspicious workflow states.

Exceptions are assigned a severity:

- BLOCKER
- WARNING

A single record may return more than one diagnostic result.

## qryWorkflowBlockers

Contains diagnostic conditions that make final publication unsafe.

## qryWorkflowWarnings

Contains conditions requiring attention but which do not necessarily prevent completed records from being published.

## qryWorkflowStranded

Identifies charged records that cannot be classified into a recognized workflow state.

## frmWorkflowDiagnostics

Administrative diagnostic dashboard providing access to:

- Open Workflow Items
- Workflow Exceptions
- Stranded Records

---

# 12. Publish Completed Leads

## Form

`frmProcessedToTblCalls`

The final process:

1. validates the selected period
2. checks workflow readiness
3. counts uncharged records
4. counts completed charged records
5. displays readiness information
6. deletes uncharged records
7. appends completed charged leads to `tblCalls`
8. deletes those published records from `tblTransProcess`
9. writes an audit record
10. commits the entire operation

## Completion Requirements

A charged lead is eligible for publication only when:

- `callReviewed = True`
- `leadDisputeReviewed = True`
- `leadSage300CREReviewed = True`
- `leadRevenueReviewed = True`
- `leadGLSChargeReviewed = True`

## Transaction Protection

The process uses a DAO Workspace transaction.

All operations succeed together or all changes are rolled back.

The process verifies that:

**records appended to `tblCalls` = records deleted from `tblTransProcess`**

If those counts disagree, an error is raised and the transaction is rolled back.

## Diagnostic Readiness

Before publication:

### BLOCKERS

Prevent publication.

### WARNINGS

Require acknowledgement but do not automatically prevent completed leads from publishing.

### Open Items

Remain in `tblTransProcess`.

They do not prevent otherwise completed leads from being published.

---

# 13. Uncharged Lead Policy

Originally uncharged leads are intentionally excluded from historical reporting.

Examples include:

- hang-ups before meaningful contact
- wrong numbers
- other contacts Google determines are non-chargeable

These records have little value to the current marketing-cost analysis and would complicate reporting.

Originally charged leads are retained even when later credited.

---

# 14. Current Architecture Decision

A `CurrentPhaseID` / `CurrentStatusID` redesign was considered during discovery.

At the current stage it is intentionally deferred.

The existing design has been significantly strengthened through:

- explicit business-action buttons
- automatic workflow-field management
- completion-specific validation
- safe interim editing
- workflow diagnostics
- blocker/warning detection
- stranded-record detection
- safer bulk processing
- transactional publication

A larger workflow-state redesign should only be reconsidered if production use demonstrates a remaining business need.

---

# 15. Remaining Work for This Version

- Production-test August GLS charge processing
- Production-test Publish Completed Leads
- Complete form opening/closing/navigation cleanup
- Add optional drill-down from Workflow Open Items
- Build and document reporting layer
- Update technical documentation as reporting is finalized