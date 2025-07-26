public without sharing class FeedbackFormService {
    @auraEnabled(cacheable=true)
    public static SQX_Complaint_Feedback__c getFeedbackRecord(Id feedbackId){
        SQX_Complaint_Feedback__c feedback = [ Select Id, CQ_SQX_Related_To__c, CQ_Status__c,CQ_SQX_Related_To__r.Name,CQ_SQX_Related_To__r.CQ_Title__c from SQX_Complaint_Feedback__c Where Id =: feedbackId limit 1];
        
        if(feedback.CQ_Status__c != 'Requested'){
            throw new AuraHandledException('Feedback already submitted  or inactive.');
        }
        return feedback;
    }
    @auraEnabled
    public static void submitFeedback(Id feedbackId, String experience, String resolved, String comment) {
        String groupId = [Select Id from Group Where Name = 'Customer Success Team' limit 1].Id;
        SQX_Complaint_Feedback__c feedback = [ Select Id from SQX_Complaint_Feedback__c Where Id =: feedbackId limit 1];
        feedback.CQ_Experience__c = experience;
        feedback.CQ_Issue_Resolved__c = resolved;
        feedback.CQ_Comment__c = comment;
        feedback.CQ_Status__c = 'Customer Success Review';
        feedback.OwnerId = groupId;
        update feedback;
    }
}