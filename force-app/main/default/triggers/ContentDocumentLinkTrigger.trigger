trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert, after delete) {
    new ContentDocumentLinkTriggerHandler().run();
}