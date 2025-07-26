public with sharing class CompleteReviewService{
    @auraEnabled
    public static void completeReview(Id feedbackId, String resolution) {
        if(String.isBlank(resolution)){
            throw new AuraHandledException('Resolution is required.');
        }
        
        // Fetching the feedback record
        SQX_Complaint_Feedback__c feedback = [ Select Id,CQ_Status__c from SQX_Complaint_Feedback__c Where Id =: feedbackId limit 1];
        
        if(feedback.CQ_Status__c != 'Customer Success Review'){
            throw new AuraHandledException('Feedback is not ready for review.');
        }
        // Updating the feedback record with provided details
        
        feedback.CQ_Issue_Resolved__c = resolution;
        feedback.CQ_Status__c = 'Resolved';
        
        update feedback;
    }
}