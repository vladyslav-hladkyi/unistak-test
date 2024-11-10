public without sharing class ContentVersionTriggerHanddler extends TriggerHandler {
    public override void afterUpdate(){
        Set<Id> accountIdsToRecalculate = new Set<Id>();
        Set<Id> contentDocumentIds = new Set<Id>();
        Map<Id, Id> versionIdByContentDocumentId = new Map<Id, Id>();
        Map<Id, ContentVersion> oldMap = (Map<Id, ContentVersion>)Trigger.oldMap;
        Map<Id, ContentVersion> newMap = (Map<Id, ContentVersion>)Trigger.newMap;

        for(ContentVersion version : (List<ContentVersion>)Trigger.New){
            //additional check if Type chnaged from or to SOW
            if(oldMap.get(version.Id).Type__c != ContentDocumentLinkTriggerHandler.SOW_TYPE 
                && newMap.get(version.Id).Type__c != ContentDocumentLinkTriggerHandler.SOW_TYPE ) { continue; }

            contentDocumentIds.add(version.ContentDocumentId);
        }

        if (contentDocumentIds.size() == 0) { return; }

        List<ContentDocumentLink> documentLinks = [
            SELECT Id, LinkedEntityId, ContentDocument.LatestPublishedVersion.Type__c, ContentDocumentId
            FROM ContentDocumentLink
            WHERE ContentDocumentId IN :contentDocumentIds
        ];

        for(ContentDocumentLink link : documentLinks){
            // recalculate only for Account's SOW files
            if(link.LinkedEntityId.getSObjectType() != Account.getSObjectType()) { continue; }

            accountIdsToRecalculate.add(link.LinkedEntityId);
        }

        if(accountIdsToRecalculate.size() > 0){
            ContentDocumentLinkTriggerHelper.recalculateAccounts(accountIdsToRecalculate, new Set<Id>{});
        }
    }
}