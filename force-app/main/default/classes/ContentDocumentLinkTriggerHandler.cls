public class ContentDocumentLinkTriggerHandler {
    public static void updateItemContentInfo(Map<Id, ContentDocumentLink> cdlMap, Boolean isDelete) {
        // 変数定義
       	Set<Id> itemIdSet = new Set<Id>(); // トリガーされたContentDocumentLinkが参照するItemレコードのId（LinkedEntityId）リストを取得
        Set<Id> cdIdSet = new Set<Id>(); // トリガーされたContentDocumentLinkが参照するContentDocumentIdリストを取得
        for(ContentDocumentLink cdl: cdlMap.values()) {
            if(cdl.LinkedEntityId != null && cdl.LinkedEntityId.getSObjectType() == MZ_Item__c.SObjectType) {  // 関連先IDのオブジェクトがItemの場合
	            itemIdSet.add(cdl.LinkedEntityId);
                cdIdSet.add(cdl.ContentDocumentId);
            }
        }
        
        Map<Id, MZ_Item__c> itemMap = new Map<Id, MZ_Item__c>(
            [SELECT Id, MZ_ContentVersionId__c, MZ_ContentBodyId__c, MZ_ImageFileExtension__c, 
             (SELECT Id, ContentDocumentId FROM ContentDocumentLinks) FROM MZ_Item__c WHERE Id IN :itemIdSet]
        ); // 関連付けられたItemレコードリスト（およびContentDocumentIdリスト）をMap形式で取得
        
        List<ContentVersion> cvList = [
            SELECT Id, ContentDocumentId, ContentBodyId, FileExtension FROM ContentVersion
            WHERE ContentDocumentId IN :cdIdSet AND IsLatest = TRUE
        ]; // 関連付けられたContentVersionレコードリストを取得
        Map<Id, ContentVersion> cdIdToCvMap = new Map<Id, ContentVersion>(); // ContentDocumentIdとContentVersionを一意に紐付け
        for(ContentVersion cv: cvList) {
            cdIdToCvMap.put(cv.ContentDocumentId, cv);
        } 
        
        // 削除処理用変数定義
        Set<Id> remainCdIdSet = new Set<Id>();	// 削除されたContentDocumentLinkの兄弟レコードに存在するContentDocumentIdリストを取得
        for(MZ_Item__c item: itemMap.values()) {
            for(ContentDocumentLink cdl : item.ContentDocumentLinks) {	// afterトリガのため、削除済みは含まれない
                remainCdIdSet.add(cdl.ContentDocumentId);  
            }
        }
        List<ContentVersion> remainCvList = [
            SELECT Id, ContentDocumentId, ContentBodyId, FileExtension FROM ContentVersion
            WHERE ContentDocumentId IN :remainCdIdSet AND IsLatest = TRUE
        ]; // 関連付けられたContentVersionレコードリストを取得
        Map<Id, ContentVersion> remainCdIdToCvMap = new Map<Id, ContentVersion>(); // ContentDocumentIdとContentVersionを一意に紐付け
        for(ContentVersion cv: remainCvList) {
            remainCdIdToCvMap.put(cv.ContentDocumentId, cv);
        } 
                
        if(isDelete) {	// 削除の場合
            for(MZ_Item__c item: itemMap.values()) {
                // Itemに紐づく他のContentDocumentIdがない場合は項目をクリア
                if(item.ContentDocumentLinks.isEmpty()) {
                    item.MZ_ContentVersionId__c = null;
                    item.MZ_ContentBodyId__c = null;
                    item.MZ_ImageFileExtension__c = null;
                } else {
                    for(ContentDocumentLink cdl: item.ContentDocumentLinks) {
                        System.debug('cdl:'+cdl);	// ※削除済みは含まれない
                        // Itemに紐づくContentDocumentIdを検索し、該当アイテムの項目に設定
                        if (remainCdIdToCvMap.containsKey(cdl.ContentDocumentId)) { // ※Mapは削除対象しか含まれないのでヒットしない
                            item.MZ_ContentVersionId__c = remainCdIdToCvMap.get(cdl.ContentDocumentId).Id;
                            item.MZ_ContentBodyId__c = remainCdIdToCvMap.get(cdl.ContentDocumentId).ContentBodyId;
                            item.MZ_ImageFileExtension__c = remainCdIdToCvMap.get(cdl.ContentDocumentId).FileExtension;
                            break;	// 最初の一致で終了
                        }
                    } 
                }
            }
        } else {	// 作成・更新の場合
            // トリガーされたContentDocumentLink.LinkEntityIdがIdに一致するItemの各項目について、ContentDocumentIdが一致するContentVersionの値を設定
            for(ContentDocumentLink cdl: cdlMap.values()) {
                if(itemMap.containskey(cdl.LinkedEntityId)) {	// Item.Id == cdl.LinkEntityId に該当するレコードがある場合
                    if(cdIdToCvMap.containskey(cdl.ContentDocumentId)) { // ContentVersion.ContentDocumentId == cdl.ContentDocumentIdに該当するレコードがある場合
                        itemMap.get(cdl.LinkedEntityId).MZ_ContentVersionId__c = cdIdToCvMap.get(cdl.ContentDocumentId).Id;
                        itemMap.get(cdl.LinkedEntityId).MZ_ContentBodyId__c = cdIdToCvMap.get(cdl.ContentDocumentId).ContentBodyId;
                        itemMap.get(cdl.LinkedEntityId).MZ_ImageFileExtension__c  = cdIdToCvMap.get(cdl.ContentDocumentId).FileExtension;
                        break;	// 最初の一致で終了
                    }
                }
            }
        }
        
        if(!itemMap.isEmpty()) {
            update itemMap.values();
        }
    }
}