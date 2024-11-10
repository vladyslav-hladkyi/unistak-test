public without sharing class ContentDocumentLinkTriggerHelper {
    public static Map<Id, ContentDocument> getMapContentDocumentByLinkId(List<ContentDocumentLink> links){
        Set<Id> documentIds = new Set<Id>();
        Map<Id, ContentDocument> contentDocumentByLinkId = new Map<Id, ContentDocument>();

        for(ContentDocumentLink link : links){
            documentIds.add(link.ContentDocumentId);
        }

        Map<Id, ContentDocument> contentDocumentByIds = new Map<Id, ContentDocument>([
            SELECT LatestPublishedVersion.Type__c
            FROM ContentDocument
            WHERE Id IN :documentIds
        ]);

        System.debug(contentDocumentByIds);

        for(ContentDocumentLink link : links){
            contentDocumentByLinkId.put(link.Id, contentDocumentByIds.get(link.ContentDocumentId));
        }

        return contentDocumentByLinkId;
    }

    public static void recalculateAccounts(Set<Id> accountIds, Set<Id> deletedDocumentIds){
        Map<Id, Account> accountById = new Map<Id, Account>();

        // default values
        for(Id accountId : accountIds){
            accountById.put(accountId, new Account(Id = accountId, SOW_Count__c = 0));
        }

        // when this method is called from ContentDocument trigger we shoud exlude files that will be deleted
        List<AggregateResult> results = [
            SELECT COUNT(Id) numberOfFiles , LinkedEntityId accId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :accountIds AND ContentDocumentId NOT IN :deletedDocumentIds
                AND ContentDocument.LatestPublishedVersion.Type__c = :ContentDocumentLinkTriggerHandler.SOW_TYPE
            GROUP BY LinkedEntityId 
        ];

        for(AggregateResult result : results){
            accountById.get((Id)result.get('accId')).SOW_Count__c = (Integer)result.get('numberOfFiles');
        }

        update accountById.values();
    }
}