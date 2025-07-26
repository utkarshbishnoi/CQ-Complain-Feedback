@IsTest
public class FeedbackFormServiceTest {
	@IsTest
	static void testSubmitFeedback(){
		Account acc = new Account(Name = 'Test Account');
		insert acc;

		SQX_Complaint__c complaint = new SQX_Complaint__c(
			CQ_Title__c = 'Test Complaint',
			CQ_Customer_Contact_Email__c = 'test@example.com',
			CQ_SQX_Customer__c = acc.Id	
		);
		insert complaint;

		SQX_Complaint_Feedback__c feedback = new SQX_Complaint_Feedback__c(
			CQ_SQX_Related_To__c = complaint.Id,
			CQ_Status__c = 'Requested'
		);
		insert feedback;

		Test.startTest();
		SQX_Complaint_Feedback__c fetched = FeedbackFormService.getFeedbackRecord(feedback.Id);
		FeedbackFormService.submitFeedback(feedback.Id, '2 - Satisfied','Yes','Looks fine.');
		Test.stopTest();

		feedback = [Select CQ_Status__c,CQ_Comment__c from SQX_Complaint_Feedback__c where Id = :feedback.Id];
		System.assertEquals('Customer Success Review', feedback.CQ_Status__c);
		System.assertEquals('Looks fine.', feedback.CQ_Comment__c);
	}
}