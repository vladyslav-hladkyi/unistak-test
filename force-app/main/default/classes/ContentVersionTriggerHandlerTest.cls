@IsTest
public class ContentVersionTriggerHandlerTest {

    @TestSetup
    static void setup() {
        insert new Account(Name = 'Test Account');
    }

    @IsTest
    static void testAfterUpdateTypeChangeToSOW() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        ContentVersion version = TestDataFactory.createContentVersion(null);
        TestDataFactory.createContentDocumentLink(testAccount.Id, version.ContentDocumentId);

        Test.startTest();
        version.Type__c = ContentDocumentLinkTriggerHandler.SOW_TYPE;
        update version;
        Test.stopTest();

        testAccount = [SELECT SOW_Count__c FROM Account WHERE Id = :testAccount.Id];

        System.assertEquals(1, testAccount.SOW_Count__c, 'SOW_Count__c should be updated to 1 after setting Type__c to SOW');
    }

    @IsTest
    static void testAfterUpdateTypeChangeFromSOW() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        ContentVersion version = TestDataFactory.createContentVersion(ContentDocumentLinkTriggerHandler.SOW_TYPE);
        TestDataFactory.createContentDocumentLink(testAccount.Id, version.ContentDocumentId);

        Test.startTest();
        version.Type__c = null;
        update version;
        Test.stopTest();

        testAccount = [SELECT SOW_Count__c FROM Account WHERE Id = :testAccount.Id];

        System.assertEquals(0, testAccount.SOW_Count__c, 'SOW_Count__c should be updated to 0 after changing Type__c from SOW');
    }
}