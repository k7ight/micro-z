trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert, after update, after delete) {
    if (Trigger.isInsert || Trigger.isUpdate) {
        ContentDocumentLinkTriggerHandler.updateItemContentInfo(Trigger.newMap, False);
    } else if (Trigger.isDelete) {
        ContentDocumentLinkTriggerHandler.updateItemContentInfo(Trigger.oldMap, True);
    }
}