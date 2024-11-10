public with sharing class ContentDocumentTriggerHandler extends TriggerHandler {
    // intresting fact - ContentDocumentLink trigger on delete doesn't run after deleting ContentDocument
    // so for that wee need this additional trigger
    public override void beforeDelete(){
        Set<Id> accountIdsToRecalculate = new Set<Id>();
        Set<Id> contentDocumnetIds = new Set<Id>();

        for(ContentDocument document : (List<ContentDocument>)Trigger.Old){
            contentDocumnetIds.add(document.Id);
        }

        List<ContentDocumentLink> documentLinks = [
            SELECT Id, LinkedEntityId, ContentDocument.LatestPublishedVersion.Type__c
            FROM ContentDocumentLink
            WHERE ContentDocumentId IN :contentDocumnetIds
        ];

        for(ContentDocumentLink link : documentLinks){
            // recalculate only for Account's SOW files
            if(link.LinkedEntityId.getSObjectType() != Account.getSObjectType()) { continue; }
            if(link.ContentDocument.LatestPublishedVersion.Type__c != ContentDocumentLinkTriggerHandler.SOW_TYPE) { continue; }

            accountIdsToRecalculate.add(link.LinkedEntityId);
        }

        if(accountIdsToRecalculate.size() > 0){
            ContentDocumentLinkTriggerHelper.recalculateAccounts(accountIdsToRecalculate, contentDocumnetIds);
        }
    }
}