@IsTest
public class ComplaintFeedbackServiceTest {
	@IsTest
	static void testRequestFeedback_Sucess(){
		Account acc = new Account(Name = 'Test Account');
		insert acc;

		SQX_Complaint__c complaint = new SQX_Complaint__c(
			CQ_Title__c = 'Test Complaint',
			CQ_Customer_Contact_Email__c = 'test@example.com',
			CQ_SQX_Customer__c = acc.Id	
		);
		insert complaint;

		Test.startTest();
		ComplaintFeedbackService.requestFeedback(complaint.Id);
		Test.stopTest();

		SQX_Complaint_Feedback__c[] feedbacks = [Select Id from SQX_Complaint_Feedback__c where CQ_SQX_Related_To__c = :complaint.Id];
		System.assertEquals(1,feedbacks.size());
	}
	@IsTest
    static void testCheckFeedbackExists_True() {
        Account acc = new Account(Name = 'Check Exists Account');
        insert acc;

        SQX_Complaint__c complaint = new SQX_Complaint__c(
            CQ_Title__c = 'Check Feedback',
            CQ_Customer_Contact_Email__c = 'test@check.com',
            CQ_SQX_Customer__c = acc.Id
        );
        insert complaint;

        SQX_Complaint_Feedback__c feedback = new SQX_Complaint_Feedback__c(
            CQ_SQX_Related_To__c = complaint.Id,
            CQ_Status__c = 'Requested'
        );
        insert feedback;

        Test.startTest();
        Boolean exists = ComplaintFeedbackService.checkFeedbackExists(complaint.Id);
        Test.stopTest();

        System.assertEquals(true, exists, 'Feedback should exist');
    }
}