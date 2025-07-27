/**
 * Service class to handle the completion of customer feedback reviews.
 */
 public with sharing class CompleteReviewService{
    /**
     * Completes the review process for a given feedback record.
     * Updates the feedback status to 'Resolved' and sets the resolution provided by the user.
     *
     * @param feedbackId  The Id of the SQX_Complaint_Feedback__c record to update.
     * @param resolution  The resolution details for the complaint.
     */
    @auraEnabled
    public static void completeReview(Id feedbackId, String resolution) {
        // Validate that resolution text is not blank or null
        if(String.isBlank(resolution)){
            throw new AuraHandledException('Resolution is required.');
        }
        
        // Fetching the feedback record
        SQX_Complaint_Feedback__c feedback = [ Select Id,CQ_Status__c from SQX_Complaint_Feedback__c Where Id =: feedbackId limit 1];
        
        // Ensure the feedback record is in 'Customer Success Review' status before updating
        if(feedback.CQ_Status__c != 'Customer Success Review'){
            throw new AuraHandledException('Feedback is not ready for review.');
        }
        
        // Updating the feedback record with provided details
        feedback.CQ_Issue_Resolved__c = resolution;
        feedback.CQ_Status__c = 'Resolved';
        
        update feedback;
    }
}