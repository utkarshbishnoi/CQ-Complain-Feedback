@IsTest
public class FeedbackFormPublicControllerTest {
	 @isTest
    static void testSubmitWithValidFeedback() {
		// Create admin user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User admin = new User(
            Alias = 'admin',
			LastName = 'admin',
            Email = 'admin@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'testadminuser@example.com'
        );
        insert admin;
		Id queueId;
        System.runAs(admin) {
			// Create test Queue (Customer Success Team)
            Group queue = new Group(Name = 'Customer Success Team', Type = 'Queue');
            insert queue;

			// Give queue access to the object
            QueueSobject qObj = new QueueSobject(
                QueueId = queue.Id,
                SobjectType = 'SQX_Complaint_Feedback__c'
            );
            insert qObj;

            queueId = queue.Id;
        }
        
 		Test.startTest();
        // Create test Account
        Account acc = new Account(Name = 'Test Account');
		insert acc;

 		// Create test Complaint
		SQX_Complaint__c complaint = new SQX_Complaint__c(
			CQ_Title__c = 'Test Complaint',
			CQ_Customer_Contact_Email__c = 'test@example.com',
			CQ_SQX_Customer__c = acc.Id	
		);
		insert complaint;

        // Create feedback record with status 'Requested'
        SQX_Complaint_Feedback__c feedback = new SQX_Complaint_Feedback__c(
            CQ_SQX_Related_To__c = complaint.Id,
            CQ_Status__c = 'Requested'
        );
        insert feedback;

        // Set test page parameters
        Test.setCurrentPage(Page.FeedbackFormVF);
        ApexPages.currentPage().getParameters().put('id', feedback.Id);

        // Instantiate controller
        FeedbackFormPublicController controller = new FeedbackFormPublicController();

        // Simulate form values
        controller.experience = '3 - Highly Satisfied';
        controller.resolved = 'Yes';
        controller.comment = 'Issue resolved perfectly.';

        // Submit the form
        controller.submit();
        Test.stopTest();

        // Re-query the updated record
        SQX_Complaint_Feedback__c updated = [SELECT CQ_Status__c, CQ_Experience__c, CQ_Issue_Resolved__c, CQ_Comment__c, OwnerId FROM SQX_Complaint_Feedback__c WHERE Id = :feedback.Id];

        System.assertEquals('Customer Success Review', updated.CQ_Status__c);
        System.assertEquals('3 - Highly Satisfied', updated.CQ_Experience__c);
        System.assert(controller.submitted, 'submitted flag should be true');
    }

    @isTest
    static void testInvalidFeedbackId() {
        // No feedback ID passed
        Test.setCurrentPage(Page.FeedbackFormVF);

        FeedbackFormPublicController controller = new FeedbackFormPublicController();
        System.assert(controller.invalid, 'invalid flag should be true');
    }

    @isTest
    static void testMissingFeedbackRecord() {
        // Pass a random ID that doesn't exist
        Test.setCurrentPage(Page.FeedbackFormVF);
        ApexPages.currentPage().getParameters().put('id', 'a0A000000000001');

        FeedbackFormPublicController controller = new FeedbackFormPublicController();
        System.assert(controller.invalid, 'Should be invalid since record does not exist');
    }
}