public with sharing class AttachmentsController {
    @AuraEnabled
    public static List<FileWrapper> getRelatedFiles(Id recordId){
        try {
            List<FileWrapper> files = new List<FileWrapper>();
            List<ContentDocumentLink> documentLinks = [
                SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.ContentSize, 
                    ContentDocument.FileExtension, ContentDocument.LatestPublishedVersion.Type__c  
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :recordId
                ORDER BY ContentDocument.Title
            ];

            for (ContentDocumentLink documentLink : documentLinks) {
                files.add(new FileWrapper(documentLink));
            }

            return files;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateFileTypes(List<FileWrapper> files){
        try {
            List<ContentVersion> documentsToUpdate = new List<ContentVersion>();

            for(FileWrapper file : files) {
                if(file.type != null && file.type != ''){
                    documentsToUpdate.add(new ContentVersion(Id = file.fileId, Type__c = file.type));
                }
            }

            update documentsToUpdate;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class FileWrapper {
        @AuraEnabled
        public String title {get; set;}
        @AuraEnabled
        public String information {get; set;}
        @AuraEnabled
        public String iconName {get; set;}
        @AuraEnabled
        public String size {get; set;}
        @AuraEnabled
        public String extension {get; set;}
        @AuraEnabled
        public String type {get; set;}
        @AuraEnabled
        public Id fileId {get; set;}
        @AuraEnabled
        public Id linkId {get; set;}

        public FileWrapper(){

        }

        public FileWrapper(ContentDocumentLink documentLink){
            this.fileId = documentLink.ContentDocumentId;
            this.title = documentLink.ContentDocument.Title;
            this.linkId = documentLink.Id;
            this.size = AttachmentsControllerHelper.formatBytes(documentLink.ContentDocument.ContentSize);
            this.extension = documentLink.ContentDocument.FileExtension;
            this.type = documentLink.ContentDocument.LatestPublishedVersion.Type__c;
            this.iconName = AttachmentsControllerHelper.mapFileIcon(documentLink.ContentDocument.FileExtension);
            this.information = (this.type == null ? 'none' : this.type) + ' - ' + this.size + ' - ' + this.extension;
        }
    }
}