# Google Local Services Dispute Notes

Google relies on an automated machine learning system to issue lead credits rather then manual dispute forms. Valid reasons for an automated credit include obvious spam, sales solicitations, employment seekers, wrong numbers, and duplicate inquires. **Mismatched service areas or unoffered job types are not longer accepted as valid reasons for credit.** 

## Automated Credit Categories

- **Spam and Robocalls:** Automated or silent calls that hold no real customer intent. 
- **Solicitation:** Callers trying to sell products, services, or pitch business offers. 
- **Job Seekers:** Individuals calling to ask for employment opportunities. 
- **Wrong Numbers:** Misdialed call or people trying to reach a completely different entity. 
- **Duplicate Leads:** Receiving multiple charged notifications for the exact same customer inquiry. 

## Non-Credited Scenarios

- **Out-of-Area Calls:** Calls from locations outside your set service radius are no longer credited automatically. 
- **Unsupported Job Types:** Inquiries for tasks outside your selected categories are no longer eligible for credit. 
- **Unclosed Jobs:** Prospects who fail to book, choose a competitor, or object to pricing are still billed as valid leads. 



To flag and rate low quality calls in your dashboard, **you must act as the manual trigger for Google's machine learning reviews.** Because the old manual dispute form was removed, the rating system is you primary lever to train the AI algorithm and secure credits. 

You must submit your feedback within 30 days of the lead date to be eligible for a credit review. 

## Step-by-Step Instructions

1. **Access the Leads Tab:** Log into your [Google Local Services Ads Dashboard](https://ads.google.com/localservices). Click on the **Leads** tab in the left-hand menu to open your inbox. [[1](https://www.youtube.com/watch?v=Ojms_u5YpGU&t=140), [2](https://www.smartsites.com/blog/google-local-services-ads-what-you-need-to-know-in-2026/), [3](https://www.bgcollective.com/solutions-lab/dispute-bad-leads-local-services-ads), [4](https://marketingdr.co/guide/managing-leads-in-google-guarantee-local-service-ads/?srsltid=AfmBOooPFdDYSNe9OCHaCd3uH4mXPC14xVkqzqANgXdqkqjuFv2tLrrP)]
2. **Review the Call Details:** Select the specific low-quality call you want to address. Click **Show recording** to listen to the call and verify that the dialogue matches an invalid category (like spam, solicitation, or a wrong number). [, [2](https://buildingblocksdigital.com/grade-google-lsa-leads/), [3](https://www.bgcollective.com/solutions-lab/dispute-bad-leads-local-services-ads)]
3. **Trigger the Review (Rate This Lead):** Look to the top-right corner of the lead detail view and click **Rate this lead**. [[1](https://www.youtube.com/watch?v=Ojms_u5YpGU&t=140), [2](https://www.bgcollective.com/solutions-lab/dispute-bad-leads-local-services-ads)]
4. **Select the Correct Grade:** Choose **Very Dissatisfied**. *Note: Selecting "Somewhat Dissatisfied" only captures feedback and rarely initiates an automated refund evaluation.* [[1](https://www.bgcollective.com/solutions-lab/dispute-bad-leads-local-services-ads)]
5. **Provide a Specific Reason:** A dropdown menu will appear. Select the exact reason for your dissatisfaction (e.g., *Spam*, *Solicitation*, *Wrong Number*, or *Duplicate Lead*). Vague or generic feedback will be ignored by the algorithm. [[1](https://www.smartsites.com/blog/google-local-services-ads-what-you-need-to-know-in-2026/), [2](https://www.bgcollective.com/solutions-lab/dispute-bad-leads-local-services-ads)]
6. **Add Notes and Archive:** Type clear, concise details into the notes field confirming the error (e.g., *"Caller was an automated robocall pitching SEO services"*). Click save, then click the **Archive** button at the top of the page to clean your inbox. [[1](https://support.google.com/google-ads/thread/404476088/charged-for-irrelevant-local-services-lead-service-not-offered-–-how-to-dispute?hl=en), [2](https://localsearchforum.com/threads/does-managing-lsa-leads-in-platform-actually-boost-performance.62609/), [3](https://barkmediasolutions.com/disputing-google-lsa-leads), [4](https://marketingdr.co/guide/managing-leads-in-google-guarantee-local-service-ads/?srsltid=AfmBOooPFdDYSNe9OCHaCd3uH4mXPC14xVkqzqANgXdqkqjuFv2tLrrP)]

Managing Non-Refundable Leads

For leads that are unqualified but no longer eligible for direct automated refunds—such as callers from outside your service area or those requesting a job type you do not support—you should still rate them as Very Dissatisfied. **Write explicit notes about the mismatched geography or service type before archiving them**. While this does not guarantee an immediate credit, **consistently submitting these details trains Google's AI targeting system to stop sending you those types of bad phone calls in the future. [1, 2]**



## Our AI API Prompt

systemPrompt = "You are an expert at analyzing call transcripts for a home services company (HVAC, Plumbing, Electrical) that uses Google Local Services. " & _
        "Extract the following information and return ONLY valid JSON in this exact structure: " & _
        "{""CustomerName"":"""",""Address"":"""",""City"":"""",""State"":"""",""Zip"":"""",""Phone"":"""",""Email"":"""",""WorkNeeded"":"""",""CallStatus"":""Booked"",""DisputeRecommended"":false,""DisputeReason"":"""",""Confidence"":85}. " & _
        "Rules: " & _
        "1. State must be the 2-letter abbreviation only (TX, OK, NM, etc.). Never spell out the full state name. " & _
        "2. CallStatus must be exactly one of: Booked, Lost, Quoted, Voicemail, Other. " & _
        "3. DisputeRecommended = true only for: Spam/robocall, Wrong number, Existing customer follow-up (not a new lead), Extremely short call with no real conversation, Caller clearly outside service area, or Job seeker / employment inquiry. " & _
        "Do NOT recommend dispute just because the customer did not book. " & _
        "Return only the JSON. No extra text."







