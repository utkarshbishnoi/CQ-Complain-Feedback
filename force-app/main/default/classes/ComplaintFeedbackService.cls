/**
 * Service class for managing Complaint Feedback.
 * This class provides methods to request feedback for a complaint 
 * and check if feedback already exists for a complaint.
 */
public with sharing class ComplaintFeedbackService {
    /**
     * Sends a feedback request email to the customer linked with the given complaint.
     * It also creates a new Complaint Feedback record with the status 'Requested'.
     *
     * @param complaintId The Id of the Complaint (SQX_Complaint__c) for which feedback is requested.
     */
    @auraEnabled
    public static void requestFeedback(Id complaintId){
        
        // Validate that complaintId is not null
        if(complaintId == null){
            throw new AuraHandledException('Complaint Id is required.');
        }
        //Getting the Complaint details from Complaint Id
        SQX_Complaint__c complaint = [ Select Id, Name, CQ_Title__c,CQ_Customer_Contact_Email__c from SQX_Complaint__c Where Id =: complaintId limit 1];
        if (String.isBlank(complaint.CQ_Customer_Contact_Email__c)){
            throw new AuraHandledException('Customer contact email is missing.');
        }

        //Creating a complaint feedback record when requesting it
        SQX_Complaint_Feedback__c feedback = new SQX_Complaint_Feedback__c(
        CQ_SQX_Related_To__c = complaint.Id,
        CQ_Status__c = 'Requested');
        insert feedback;
        
        //Experience Cloud Feedback Form Link
        string baseUrl = Label.ExperienceCloudBaseURL;
        string feedbackLink = baseUrl + '?id='+ feedback.Id;
        
        //Prepare email message for sending feedback request
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[]{ complaint.CQ_Customer_Contact_Email__c});
        email.setSubject('We need your valuable Feedback for Complaint '+ complaint.Name);
        email.setHtmlBody('Hi, <br/><br/>Please click the link below to share your valuable feedback:<br/><a href="'+feedbackLink+'">Give Feedback</a><br/><br/>Thanks!');
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
            System.debug('Email Sent Successfully.'); 
        } catch(exception e) {
            System.debug('Email Failed-->'+ e.getMessage());
            throw new AuraHandledException('Failed to send Email: '+ e.getMessage());
        }
        
    }
    /**
     * Checks if a Complaint Feedback record exists for the given complaint.
     *
     * @param complaintId The Id of the Complaint (SQX_Complaint__c).
     * @return Boolean True if a feedback record exists, otherwise false.
     */
    @AuraEnabled(cacheable=true)
public static Boolean checkFeedbackExists(Id complaintId) {
    return [
        SELECT Id FROM SQX_Complaint_Feedback__c
        WHERE CQ_SQX_Related_To__c = :complaintId
        LIMIT 1
    ].size() > 0;
}
}