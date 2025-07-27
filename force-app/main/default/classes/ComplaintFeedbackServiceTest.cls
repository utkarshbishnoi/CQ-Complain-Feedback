/**
 * Test class for ComplaintFeedbackService.
 * It validates the behavior of requestFeedback and checkFeedbackExists methods.
 */
 @IsTest
public class ComplaintFeedbackServiceTest {
    /**
     * Test case to verify that a complaint feedback record is created 
     * and email sending logic executes successfully when a valid complaint is provided.
     */
	@IsTest
	static void testRequestFeedback_Sucess(){
        //Create a test account
		Account acc = new Account(Name = 'Test Account');
		insert acc;

        //Create a test complaint
		SQX_Complaint__c complaint = new SQX_Complaint__c(
			CQ_Title__c = 'Test Complaint',
			CQ_Customer_Contact_Email__c = 'test@example.com',
			CQ_SQX_Customer__c = acc.Id	
		);
		insert complaint;

		Test.startTest();
		ComplaintFeedbackService.requestFeedback(complaint.Id);
		Test.stopTest();

        // Query feedback records to ensure one was created
		SQX_Complaint_Feedback__c[] feedbacks = [Select Id from SQX_Complaint_Feedback__c where CQ_SQX_Related_To__c = :complaint.Id];
		System.assertEquals(1,feedbacks.size());
	}

    /**
     * Test case to verify that checkFeedbackExists returns true 
     * when a complaint feedback record exists for the given complaint.
     */
	@IsTest
    static void testCheckFeedbackExists_True() {

        //Create a test account
        Account acc = new Account(Name = 'Check Exists Account');
        insert acc;

        //Create a test complaint
        SQX_Complaint__c complaint = new SQX_Complaint__c(
            CQ_Title__c = 'Check Feedback',
            CQ_Customer_Contact_Email__c = 'test@check.com',
            CQ_SQX_Customer__c = acc.Id
        );
        insert complaint;

        //Create a test feedback
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