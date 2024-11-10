/*
I decided to do full recalucating when Account's files meets conditions because 

1. It's more solid solution then just adding/substructing numbers from legacy values that is stored in rollup summary fields.
2. If someone updates the rollup summary fields manually, trigger recalculates them and values will be correct
3. To increase SOQL performance and not to hit the limits -> I have used SQOL Aggregating, so it's quite faster even with big date volume
*/
public without sharing class ContentDocumentLinkTriggerHandler extends TriggerHandler{
    public static String SOW_TYPE = 'SOW';

    public override void afterInsert(){
        Set<Id> accountIdsToRecalculate = new Set<Id>();
        Map<Id, ContentDocument> documentByLinkId = ContentDocumentLinkTriggerHelper.getMapContentDocumentByLinkId(
            (List<ContentDocumentLink>)Trigger.New
        );

        for(ContentDocumentLink link : (List<ContentDocumentLink>)Trigger.New){
            // recalculate only for Account's SOW files
            if(link.LinkedEntityId.getSObjectType() != Account.getSObjectType()) { continue; }
            if(documentByLinkId.get(link.Id).LatestPublishedVersion.Type__c != SOW_TYPE) { continue; }

            accountIdsToRecalculate.add(link.LinkedEntityId);
        }

        if(accountIdsToRecalculate.size() > 0){
            ContentDocumentLinkTriggerHelper.recalculateAccounts(accountIdsToRecalculate, new Set<Id>{});
        }
    }

    public override void afterDelete(){
        Set<Id> accountIdsToRecalculate = new Set<Id>();
        Map<Id, ContentDocument> documentByLinkId = ContentDocumentLinkTriggerHelper.getMapContentDocumentByLinkId(
            (List<ContentDocumentLink>)Trigger.Old
        );

        for(ContentDocumentLink link : (List<ContentDocumentLink>)Trigger.Old){
            // recalculate only for Account's SOW files
            if(link.LinkedEntityId.getSObjectType() != Account.getSObjectType()) { continue; }
            if(documentByLinkId.get(link.Id).LatestPublishedVersion.Type__c != SOW_TYPE) { continue; }

            accountIdsToRecalculate.add(link.LinkedEntityId);
        }

        if(accountIdsToRecalculate.size() > 0){
            ContentDocumentLinkTriggerHelper.recalculateAccounts(accountIdsToRecalculate, new Set<Id>{});
        }
    }
}