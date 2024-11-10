@IsTest
public class AttachmentsControllerTest {
    @TestSetup
    static void setup() {
        Account testAccount = TestDataFactory.createAccount();
        ContentVersion version = TestDataFactory.createContentVersion(null);
        TestDataFactory.createContentDocumentLink(testAccount.Id, version.ContentDocumentId);
    }

    @IsTest
    static void testGetRelatedFiles() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<AttachmentsController.FileWrapper> files = AttachmentsController.getRelatedFiles(testAccount.Id);
        Test.stopTest();

        System.assertEquals(1, files.size(), 'File size should be 1');
    }

    @IsTest
    static void testUpdateFileTypes() {
        List<AttachmentsController.FileWrapper> fileWrappers = new List<AttachmentsController.FileWrapper>();
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        ContentDocumentLink contentLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :testAccount.Id LIMIT 1];
        ContentVersion contentVersion = [SELECT Id FROM ContentVersion WHERE ContentDocumentId = :contentLink.ContentDocumentId LIMIT 1];
        
        AttachmentsController.FileWrapper fileWrapper = new AttachmentsController.FileWrapper();
        fileWrapper.fileId = contentVersion.Id;
        fileWrapper.type = ContentDocumentLinkTriggerHandler.SOW_TYPE;
        fileWrappers.add(fileWrapper);

        Test.startTest();
        AttachmentsController.updateFileTypes(fileWrappers);
        Test.stopTest();

        contentVersion = [SELECT Id, Type__c FROM ContentVersion WHERE Id = :contentVersion.Id];
        System.assertEquals(ContentDocumentLinkTriggerHandler.SOW_TYPE, contentVersion.Type__c, 'The file type should have been updated');
    }
}