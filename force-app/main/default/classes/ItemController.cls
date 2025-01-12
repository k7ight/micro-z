public class ItemController {
    @AuraEnabled(cacheable=true)
    public static List<MZ_Item__c> getItems(String category, String subCategory, String colorGroup, 
                                            String designType, String season, String searchKey, 
                                            String sortKey, String sortOrder) {

        String query = 'SELECT Id, Name, MZ_Category__c, MZ_SubCategory__c, MZ_Color__r.MZ_ColorGroup__c, ';
        query += 'MZ_Design__r.MZ_DesignType__c, MZ_Season__c, MZ_ItemURL__c, MZ_ItemImage__c, ';
        query += 'MZ_PurchaseDate__c, MZ_PurchasePrice__c, MZ_PurchaseShop__c FROM MZ_Item__c ';
        
        // 条件用のリストを定義
        List<String> conditions = new List<String>();
        // バインド変数を定義
        Map<String, Object> binds = new Map<String, Object>();
        
        if (String.isNotBlank(category)) {
            System.debug('category: '+category);
            conditions.add('MZ_Category__c = :category');
            binds.put('category', category);
        }
        if (String.isNotBlank(subCategory)) {
            conditions.add('MZ_SubCategory__c = :subCategory');
            binds.put('subCategory', subCategory);
        }
        if (String.isNotBlank(colorGroup)) {
            conditions.add('MZ_Color__r.MZ_ColorGroup__c = :colorGroup');
            binds.put('colorGroup', colorGroup);
        }
        if (String.isNotBlank(designType)) {
            conditions.add('MZ_Design__r.MZ_DesignType__c = :designType');
            binds.put('designType', designType);
        }
        if (String.isNotBlank(season)) {
            conditions.add('MZ_Season__c INCLUDES (:season)');
            binds.put('season', season);
        }
        if (String.isNotBlank(searchKey)) {
            conditions.add('Name LIKE :searchKey');
            binds.put('searchKey', '%' + searchKey + '%');
        }
    
  		// 条件がある場合はWHERE句を追加
        if (!conditions.isEmpty()) {
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }
                                                
        // ソートキー指定がある場合は指定
        if(String.isNotBlank(sortKey)) {
            query += ' ORDER BY ' + sortKey + ' ' + sortOrder;
        } else {
	        query += ' ORDER BY CreatedDate DESC';            
        }                                       
        System.debug('query: '+query);
		System.debug('binds: '+binds);
        return Database.queryWithBinds(query, binds, AccessLevel.USER_MODE);
	}
}