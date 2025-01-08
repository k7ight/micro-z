trigger ItemTrigger on MZ_Item__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
		    ItemTriggerHandler.TriggerBeforeInsert(Trigger.New);
        } else if (Trigger.isUpdate) {
            ItemTriggerHandler.TriggerBeforeUpdate(Trigger.New);
        } else {
            
        }
    } else {
       
    }
}