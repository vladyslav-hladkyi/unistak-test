trigger ContentVersionTrigger on ContentVersion (after update) {
    new ContentVersionTriggerHanddler().run();
}