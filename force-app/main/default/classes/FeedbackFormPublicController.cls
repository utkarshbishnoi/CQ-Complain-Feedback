/**
 * Public-facing Apex Controller for the Complaint Feedback form.
 * This controller handles loading feedback details from the URL parameter
 * and updating the feedback record with the user's response.
 */
    public without sharing class FeedbackFormPublicController {
        // Form input parameters
        public String feedbackId { get; set; }     // The ID of the feedback record passed via URL
        public String complaintId { get; set; }    // The associated complaint record ID
        public String experience { get; set; }     // User-selected experience feedback
        public String resolved { get; set; }       // User-selected resolution status
        public String comment { get; set; }        // Additional comments provided by the user
    
        // Form state flags
        public Boolean submitted { get; set; }     // Indicates if the form has been successfully submitted
        public Boolean invalid { get; set; }       // Indicates if the provided feedback ID is invalid

        // Related records
        public SQX_Complaint_Feedback__c feedback { get; set; }
        public SQX_Complaint__c complaint { get; set; }
        

         /**
        * Constructor that initializes the form state.
        * It attempts to load the feedback record based on the 'id' URL parameter.
        * If no valid feedback is found, the form is marked as invalid.
        */
        public FeedbackFormPublicController() {
            submitted = false;
            invalid = false;

            // Get the feedback ID from the current page URL parameter
            feedbackId = ApexPages.currentPage().getParameters().get('id');

            if (String.isNotBlank(feedbackId)) {
                try {
                    // Query the feedback record and its related complaint
                    feedback = [
                    SELECT Id, CQ_SQX_Related_To__c, CQ_Status__c,CQ_SQX_Related_To__r.Name,CQ_SQX_Related_To__r.CQ_Title__c FROM SQX_Complaint_Feedback__c 
                    WHERE Id = :feedbackId LIMIT 1
                ];
                    complaintId = feedback.CQ_SQX_Related_To__c;
                    complaint = feedback.CQ_SQX_Related_To__r;
                } catch (Exception e) {
                    // Mark as invalid if no matching feedback record is found
                    invalid = true;
                }
            } else {
                // Mark as invalid if no feedback ID is provided
                invalid = true;
            }
        }
        
        /**
        * Handles form submission and updates the feedback record
        * with user-provided details (experience, resolution, and comment).
        *
        * @return PageReference - null, since the form stays on the same page.
        */
        public PageReference submit() {

            // Fetch the Customer Success Team queue to assign the feedback record
            Id queueId = [SELECT Id FROM Group WHERE Name = 'Customer Success Team' AND Type = 'Queue' LIMIT 1].Id;

            if (String.isNotBlank(feedbackId)) {
                // Retrieve the feedback record to update
                SQX_Complaint_Feedback__c feedbackToUpdate = [
                    SELECT Id FROM SQX_Complaint_Feedback__c WHERE Id = :feedbackId LIMIT 1
                ];

                // Update the feedback record with form values
                feedbackToUpdate.CQ_Experience__c = experience;
                feedbackToUpdate.CQ_Issue_Resolved__c = resolved;
                feedbackToUpdate.CQ_Comment__c = comment;
                feedbackToUpdate.CQ_Status__c = 'Customer Success Review';
                feedbackToUpdate.OwnerId = queueId;	
                update feedbackToUpdate;
                submitted = true;  // Mark form as submitted

            }
            return null; // Stay on the same page after submission
        }
    }