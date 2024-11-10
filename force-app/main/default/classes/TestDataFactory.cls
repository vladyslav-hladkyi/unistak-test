public with sharing class TestDataFactory {
    public static ContentVersion createContentVersion(String fileType){
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test Data'),
            Type__c = fileType
        );

        insert contentVersion;
        // to get correct ContentDocumentId value
        return [SELECT Id, ContentDocumentId, Type__c FROM ContentVersion WHERE Id = :contentVersion.Id];
    }

    public static ContentDocumentLink createContentDocumentLink(Id recordId, Id documentId){
        ContentDocumentLink contentDocLink = new ContentDocumentLink(
            ContentDocumentId = documentId,
            LinkedEntityId = recordId,
            ShareType = 'V'
        );

        insert contentDocLink;
        return contentDocLink;
    }

    public static Account createAccount(){
        Account testAccount = new Account(Name = 'Test Account');
        
        insert testAccount;
        return testAccount;
    }
}