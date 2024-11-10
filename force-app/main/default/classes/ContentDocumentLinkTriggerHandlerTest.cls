@IsTest
public class ContentDocumentLinkTriggerHandlerTest {

    @TestSetup
    static void setup() {
        insert new Account(Name = 'Test Account');
    }

    @IsTest
    static void testAfterInsert() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        ContentVersion version = TestDataFactory.createContentVersion(ContentDocumentLinkTriggerHandler.SOW_TYPE);
        
        Test.startTest();
        TestDataFactory.createContentDocumentLink(testAccount.Id, version.ContentDocumentId);
        Test.stopTest();

        testAccount = [SELECT SOW_Count__c FROM Account WHERE Id = :testAccount.Id];

        System.assertEquals(1, testAccount.SOW_Count__c, 'SOW_Count__c should be updated to 1 after after insert');
    }

    @IsTest
    static void testAfterDelete() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        ContentVersion version = TestDataFactory.createContentVersion(ContentDocumentLinkTriggerHandler.SOW_TYPE);
        ContentDocumentLink link = TestDataFactory.createContentDocumentLink(testAccount.Id, version.ContentDocumentId);
        
        Test.startTest();
        delete link;
        Test.stopTest();

        testAccount = [SELECT SOW_Count__c FROM Account WHERE Id = :testAccount.Id];

        System.assertEquals(0, testAccount.SOW_Count__c, 'SOW_Count__c should be updated after delete');
    }
}