@IsTest
public class ContentDocumentTriggerHandlerTest {

    @TestSetup
    static void setup() {
        insert new Account(Name = 'Test Account');
    }

    @IsTest
    static void testBeforeDelete() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        ContentVersion version = TestDataFactory.createContentVersion(ContentDocumentLinkTriggerHandler.SOW_TYPE);
        TestDataFactory.createContentDocumentLink(testAccount.Id, version.ContentDocumentId);

        Test.startTest();
        delete new ContentDocument(Id = version.ContentDocumentId);
        Test.stopTest();

        testAccount = [SELECT SOW_Count__c FROM Account WHERE Id = :testAccount.Id];

        System.assertEquals(0, testAccount.SOW_Count__c, 'SOW_Count__c should be updated to 0 after ContentDocument deletion');
    }
}