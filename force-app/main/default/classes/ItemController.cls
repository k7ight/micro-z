public class ItemController {
    @AuraEnabled(cacheable=true)
    public static List<MZ_Item__c> getItems() {
        return [
            SELECT 
            Id, Name, MZ_Category__c, MZ_SubCategory__c,
            MZ_Color__r.MZ_ColorGroup__c, MZ_Design__r.MZ_DesignType__c, MZ_Season__c 
            FROM MZ_Item__c
        ];
	}
}