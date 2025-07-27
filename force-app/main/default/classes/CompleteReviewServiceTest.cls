/**
 * Test class for CompleteReviewService.
 * This class verifies the behavior of the completeReview method with positive and negative scenarios.
 */
@IsTest
public class CompleteReviewServiceTest {

    /**
     * Positive test case for completeReview.
     * Verifies that the feedback record is correctly updated to 'Resolved'
     * when the status is 'Customer Success Review' and a valid resolution is provided.
     */
	@IsTest
	static void testCompleteReview(){

        //create a feedback
		SQX_Complaint_Feedback__c feedback = new SQX_Complaint_Feedback__c(CQ_Status__c = 'Customer Success Review');
		insert feedback;

		Test.startTest();
		CompleteReviewService.completeReview(feedback.Id,'Yes');
		Test.stopTest();

        //Fetch the updated feedback 
		feedback = [Select CQ_Status__c,CQ_Issue_Resolved__c from SQX_Complaint_Feedback__c where Id = :feedback.Id];
		System.assertEquals('Resolved', feedback.CQ_Status__c);
		System.assertEquals('Yes', feedback.CQ_Issue_Resolved__c);
	}

    /**
     * Negative test case for completeReview.
     * Verifies that an AuraHandledException is thrown when the feedback
     * record is not in 'Customer Success Review' status.
     */
	@IsTest
    static void testCompleteReview_InvalidStatus() {

        // Create and insert a feedback record with an invalid status
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