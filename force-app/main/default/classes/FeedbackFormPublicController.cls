public without sharing class FeedbackFormPublicController {
    public String feedbackId { get; set; }
	public String complaintId { get; set; }
    public String experience { get; set; }
    public String resolved { get; set; }
    public String comment { get; set; }
    public Boolean submitted { get; set; }
    public Boolean invalid { get; set; }

	public SQX_Complaint_Feedback__c feedback { get; set; }
    public SQX_Complaint__c complaint { get; set; }
    

    public FeedbackFormPublicController() {
        submitted = false;
        invalid = false;
		
        feedbackId = ApexPages.currentPage().getParameters().get('id');

        if (String.isNotBlank(feedbackId)) {
            try {
				feedback = [
                SELECT Id, CQ_SQX_Related_To__c, CQ_Status__c,CQ_SQX_Related_To__r.Name,CQ_SQX_Related_To__r.CQ_Title__c FROM SQX_Complaint_Feedback__c 
                WHERE Id = :feedbackId LIMIT 1
            ];
                complaintId = feedback.CQ_SQX_Related_To__c;
				complaint = feedback.CQ_SQX_Related_To__r;
            } catch (Exception e) {
                invalid = true;
            }
        } else {
            invalid = true;
        }
    }

    public PageReference submit() {
		Id queueId = [SELECT Id FROM Group WHERE Name = 'Customer Success Team' AND Type = 'Queue' LIMIT 1].Id;
        if (String.isNotBlank(feedbackId)) {
            SQX_Complaint_Feedback__c feedbackToUpdate = [
                SELECT Id FROM SQX_Complaint_Feedback__c WHERE Id = :feedbackId LIMIT 1
            ];
            feedbackToUpdate.CQ_Experience__c = experience;
            feedbackToUpdate.CQ_Issue_Resolved__c = resolved;
            feedbackToUpdate.CQ_Comment__c = comment;
			feedbackToUpdate.CQ_Status__c = 'Customer Success Review';
			feedbackToUpdate.OwnerId = queueId;	
            update feedbackToUpdate;
            submitted = true;
        }
        return null;
    }
}