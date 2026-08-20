# Google Local Services Tracking Database
## User Guide

## Purpose

The Google Local Services Tracking Database helps process charged Google Local Services leads from the initial call review through Sage, revenue, Google charge processing, and final reporting.

The database is designed so the reviewer focuses on **what happened with the lead** rather than remembering which database fields need to be updated.

Whenever possible:

**You provide the business answer.  
The database manages the workflow.**

---

# 1. Main Workflow

The normal process is:

**Import GLS Leads**

→ **Review Calls**

→ **Review Disputes if necessary**

→ **Review Sage 300 CRE Information**

→ **Review Revenue if necessary**

→ **Add GLS Charges**

→ **Review Open Workflow Items**

→ **Publish Completed Leads**

---

# 2. Review Calls

Use the Call Review form to determine what happened during the customer call.

Valid Call Status values are:

- Booked
- Lost
- Disputed

The database automatically determines which later processing steps are required.

## Booked

Choose Booked when the customer scheduled work.

Customer information should be captured so the lead can later be matched in Sage 300 CRE.

Booked calls continue to Sage Review.

## Lost

Choose Lost when the call did not result in booked work and the call should not be disputed.

The database automatically knows that Sage and Revenue processing are not required.

## Disputed

Choose Disputed when the call did not result in work and should be disputed with Google.

Enter the dispute reason.

Submit the dispute through Google's website and record the current Google result:

- Pending
- Denied
- Credited

### Pending

Use Pending when Google has not yet made a final decision.

The lead will remain available for Dispute Follow-up.

### Denied

Use Denied when Google rejects the dispute.

No further dispute review is required.

### Credited

Use Credited when Google grants the dispute.

No further dispute review is required.

---

# 3. Dispute Follow-up

Only Pending disputes should normally appear in this form.

Open the Google lead and check the current dispute result.

Choose:

- Pending
- Denied
- Credited

When finished, click:

**Update Dispute Status**

If the result is still Pending, the record remains available for later follow-up.

If the result is Denied or Credited, the dispute process is completed and the record leaves the dispute queue.

## Important

You may enter information and move to another record without completing the workflow step.

Use the **Update Dispute Status** button when you are intentionally finished with that dispute review.

---

# 4. Sage 300 CRE Review

Use Sage Review for calls that were classified as Booked.

Locate the customer/job in Sage using:

- address
- customer
- phone number if needed

Review or enter:

- customer information
- primary work order number
- new customer status
- revenue if already final

## Primary Work Order

A GLS lead may produce more than one work order.

Enter the primary/original work order number.

Revenue may later include amounts from additional work orders related to the same original GLS lead.

## If Work Is Still Booked

Leave Call Status as Booked.

A primary work order is required.

If revenue is already final:

- enter the revenue
- select **Revenue Is Final**

If revenue is not final:

- leave Revenue Is Final unchecked

Then click:

**Complete Sage Review**

## If the Customer Cancelled

A call originally marked Booked may later become Lost.

If Sage review shows the customer cancelled:

- change Call Status to Lost
- a work order is not required if one was never created
- the database will set revenue to zero
- Sage and Revenue processing will be considered complete

Click:

**Complete Sage Review**

---

# 5. Revenue Review

Revenue Review contains Booked leads for which final revenue was not available during Sage Review.

Review the applicable work orders in Sage.

`Revenue` should represent the total revenue attributable to the original GLS lead, even if more than one work order was created.

Revenue may legitimately be `$0.00`.

Revenue may not be negative.

When the amount is final, click:

**Complete Revenue Review**

## Important

If the work is still underway, you may enter partial information and move to another record.

Do not click **Complete Revenue Review** until the revenue is truly final.

---

# 6. Add GLS Charges

GLS charges are normally added after SearchKings provides average lead cost information for the reporting period.

Enter:

- Start Date
- End Date
- Department
- average GLS charge

Departments are:

- ELEC
- HVAC
- PLUM

The database will show how many records are about to be updated before anything is changed.

Review the information carefully before confirming the bulk update.

## Credited Calls

A credited lead still retains the original gross Google charge.

The credit is tracked separately.

Do not expect a credited call's original charge to be zero.

---

# 7. Review Open Workflow Items

Use:

**Review Open Workflow Items**

to see what processing remains unfinished.

The form shows:

- Lead Date
- Lead ID
- Call Status
- Department
- What's Still Open
- Next Action

Typical Open Reasons include:

- Call Review
- Dispute Follow-up
- Sage Review
- Revenue Review
- GLS Charge

This screen is intended to answer:

**What still needs attention, and what should I do next?**

---

# 8. Workflow Diagnostics

Workflow Diagnostics is primarily an administrative/troubleshooting tool.

It identifies:

## Open Items

Normal work that is not yet complete.

## Warnings

Information has been entered, but the related workflow action may not have been completed.

Example:

A final dispute result was entered but **Update Dispute Status** was not clicked.

## Blockers

Contradictory or invalid data that must be corrected before final publication.

## Stranded Records

Records that do not fit any recognized workflow state.

If diagnostics show no exceptions or stranded records, that is the desired result.

---

# 9. Interim Editing vs Completing Work

This is an important operating rule.

You may edit a record and use the navigation buttons to move to another record.

The database will save your interim information without automatically completing the workflow step.

When you are actually finished with the current process, use the appropriate completion button:

- Accept and Update Record
- Update Dispute Status
- Complete Sage Review
- Complete Revenue Review

Think of navigation as:

**Save what I know and move on**

and the command button as:

**I am finished with this review step**

---

# 10. Publish Completed Leads

At the end of the processing period, use:

**Publish Completed Leads**

The application will display a readiness summary before making changes.

The summary may include:

- completed leads ready to publish
- open workflow items
- workflow warnings
- uncharged records that will be removed

## Blockers

If workflow blockers exist, publishing will stop until those problems are corrected.

## Warnings

Warnings may be reviewed before continuing.

They do not necessarily prevent otherwise completed records from publishing.

## Open Items

Open leads remain in processing and can be completed later.

They do not prevent other completed leads from moving into history/reporting.

## What Happens During Publish

The database:

1. removes uncharged records for the selected period
2. copies completed charged leads to the reporting/history table
3. removes those completed records from active processing
4. records the operation in the audit log

The process is protected so that if any database operation fails, partial changes are rolled back.

---

# 11. Which Leads Are Kept?

The application keeps leads Google originally charged for.

This includes:

- Booked charged leads
- Lost charged leads
- Disputed charged leads
- Charged leads that were later credited

Originally uncharged calls are not kept in historical reporting.

---

# 12. General Workflow Tips

- Work from the processing forms rather than manually editing workflow fields.
- Use the command button when a review step is actually complete.
- Use navigation buttons when you need to skip a record and return later.
- Use Review Open Workflow Items whenever you are unsure what remains.
- If a record behaves unexpectedly, check Workflow Diagnostics.
- Do not manually manipulate the underlying workflow fields unless troubleshooting requires it.
- If you are unsure whether a record is ready to complete, leave it open rather than forcing completion.

---

# 13. End-of-Period Procedure

A typical end-of-period sequence is:

1. Finish available Call Reviews.
2. Resolve available disputes.
3. Complete available Sage Reviews.
4. Complete Revenue Reviews that are ready.
5. Review Open Workflow Items.
6. Obtain SearchKings average GLS charges.
7. Apply GLS charges by department.
8. Review Workflow Diagnostics.
9. Review remaining open items.
10. Publish Completed Leads.
11. Leave legitimate unfinished records in processing for later completion.

---

# 14. Reporting

Completed leads are stored in `tblCalls` for marketing and performance reporting.

Reporting will be documented separately as the reporting layer is finalized.