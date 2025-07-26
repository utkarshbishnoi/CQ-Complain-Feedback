@IsTest
public class CompleteReviewServiceTest {
	@IsTest
	static void testCompleteReview(){
		SQX_Complaint_Feedback__c feedback = new SQX_Complaint_Feedback__c(CQ_Status__c = 'Customer Success Review');
		insert feedback;

		Test.startTest();
		CompleteReviewService.completeReview(feedback.Id,'Yes');
		Test.stopTest();

		feedback = [Select CQ_Status__c,CQ_Issue_Resolved__c from SQX_Complaint_Feedback__c where Id = :feedback.Id];
		System.assertEquals('Resolved', feedback.CQ_Status__c);
		System.assertEquals('Yes', feedback.CQ_Issue_Resolved__c);
	}
	@IsTest
    static void testCompleteReview_InvalidStatus() {
        SQX_Complaint_Feedback__c feedback = new SQX_Complaint_Feedback__c(
            CQ_Status__c = 'Requested'
        );
        insert feedback;

        Test.startTest();
        try {
            CompleteReviewService.completeReview(feedback.Id, 'Yes');
            System.assert(false, 'Expected AuraHandledException for invalid status');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
}