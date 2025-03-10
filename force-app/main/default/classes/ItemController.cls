public class ItemController {
    
    @AuraEnabled(cacheable=true)
    public static List<MZ_Item__c> getItems(String category, String subCategory, String colorGroup, 
                                            String designType, String season, String searchKey, 
                                            String sortKey, String sortOrder) {

        String query = 'SELECT Id, Name, MZ_Category__c, MZ_SubCategory__c, MZ_Color__r.MZ_ColorGroup__c, MZ_Color__r.Name, ';
        query += 'MZ_Design__r.MZ_DesignType__c, MZ_Design__r.Name, MZ_Season__c, MZ_Style__c, MZ_ItemURL__c, MZ_ItemImage__c, ';
        query += 'MZ_PurchaseDate__c, MZ_PurchasePrice__c, MZ_PurchaseShop__c FROM MZ_Item__c ';
        
        // 条件用のリストを定義
        List<String> conditions = new List<String>();
        // バインド変数を定義
        Map<String, Object> binds = new Map<String, Object>();
        
        if (String.isNotBlank(category)) {
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
        return Database.queryWithBinds(query, binds, AccessLevel.USER_MODE);
	}
    
    @AuraEnabled(cacheable=true)
    public static List<MZ_Coordinate__c> getMyCoordinates(String itemId, String season) {
        
        String query = 'SELECT Id, MZ_Outer__r.MZ_ItemURL__c, MZ_Tops__r.MZ_ItemURL__c, MZ_Inner__r.MZ_ItemURL__c, ';
        query += 'MZ_Bottoms__r.MZ_ItemURL__c, MZ_Shoes__r.MZ_ItemURL__c, MZ_CoordinateScore__c FROM MZ_Coordinate__c ';
        
        // 条件用のリストを定義
        List<String> conditions = new List<String>();
        // バインド変数を定義
        Map<String, Object> binds = new Map<String, Object>();
        
        // 選択アイテムがある場合はコーデのいずれかのアイテムに一致するものを取得
         if (String.isNotBlank(itemId)) {
            conditions.add('(MZ_Outer__r.Id = :itemId OR MZ_Tops__r.Id = :itemId OR MZ_Inner__r.Id = :itemId OR MZ_Bottoms__r.Id = :itemId OR MZ_Shoes__r.Id = :itemId)');
            binds.put('itemId', itemId);
        }
        // シーズンが指定されている場合はシーズンに一致するものを取得
        if (String.isNotBlank(season)) {
            conditions.add('MZ_Season__c = :season');
            binds.put('season', season);
        }
    
  		// 条件がある場合はWHERE句を追加
        if (!conditions.isEmpty()) {
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }
        
        // スコア降順にソート
        query += ' ORDER BY MZ_CoordinateScore__c DESC';
                           
        return Database.queryWithBinds(query, binds, AccessLevel.USER_MODE);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<MZ_Coordinate__c> generateCoordinates(Id itemId, String season) {

        // アウター、トップス、インナー、ボトムス、シューズのコーデパターン別リスト格納用
        List<List<MZ_Item__c>> outerList = new List<List<MZ_Item__c>>();
        List<List<MZ_Item__c>> topsList = new List<List<MZ_Item__c>>();
        List<List<MZ_Item__c>> innerList = new List<List<MZ_Item__c>>();
        List<List<MZ_Item__c>> bottomsList = new List<List<MZ_Item__c>>();
        List<List<MZ_Item__c>> shoesList = new List<List<MZ_Item__c>>();
        
        // アウター、トップス、インナー、ボトムス、シューズリスト格納用
        Map<Id, MZ_Item__c> outers = new Map<Id, MZ_Item__c>();
        Map<Id, MZ_Item__c> outerTops = new Map<Id, MZ_Item__c>();
        Map<Id, MZ_Item__c> innerTops = new Map<Id, MZ_Item__c>();
        Map<Id, MZ_Item__c> allTops = new Map<Id, MZ_Item__c>();
        Map<Id, MZ_Item__c> topsInners = new Map<Id, MZ_Item__c>();
        Map<Id, MZ_Item__c> inners = new Map<Id, MZ_Item__c>();
        Map<Id, MZ_Item__c> bottoms = new Map<Id, MZ_Item__c>();
        Map<Id, MZ_Item__c> shoes = new Map<Id, MZ_Item__c>();
        
        // コーデリスト格納用
        List<List<MZ_Coordinate__c>> coordList = new List<List<MZ_Coordinate__c>>();
        List<MZ_Coordinate__c> recommendCoordList = new List<MZ_Coordinate__c>();
        
        // 対象アイテムを取得
       	List<MZ_Item__c> selectedItem = [SELECT Id, MZ_Category__c, MZ_SubCategory__c, MZ_Color__r.Id, MZ_Color__r.MZ_ColorType__c, 
                                   MZ_Design__r.MZ_DesignType__c, MZ_Style__c, MZ_ItemURL__c FROM MZ_Item__c WHERE Id = :itemId];
        
        // アウター、トップス、インナー、ボトムス、シューズのリスト取得
        if(selectedItem[0].MZ_Category__c == 'アウター') {
            outers = new Map<Id, MZ_Item__c>(selectedItem);
        } else {
            outers = new Map<Id, MZ_Item__c>([SELECT Id, MZ_Color__r.Id, MZ_Color__r.MZ_ColorType__c, MZ_Design__r.MZ_DesignType__c, MZ_Style__c, MZ_ItemURL__c FROM MZ_Item__c 
                      WHERE MZ_Category__c = 'アウター' AND MZ_Season__c INCLUDES(:season)]);
        }
        
        if(selectedItem[0].MZ_SubCategory__c == 'ニット' || selectedItem[0].MZ_SubCategory__c == 'カーディガン' || selectedItem[0].MZ_SubCategory__c == 'ベスト' 
           || selectedItem[0].MZ_SubCategory__c == 'アンサンブル' || selectedItem[0].MZ_SubCategory__c == 'パーカー' || selectedItem[0].MZ_SubCategory__c == 'スウェット'
           || selectedItem[0].MZ_SubCategory__c == 'チュニック' || selectedItem[0].MZ_SubCategory__c == 'その他トップス') {
               outerTops = new Map<Id, MZ_Item__c>(selectedItem);
               allTops = new Map<Id, MZ_Item__c>(selectedItem);
           } else {
               outerTops = new Map<Id, MZ_Item__c>([SELECT Id, MZ_Color__r.Id, MZ_Color__r.MZ_ColorType__c, MZ_Design__r.MZ_DesignType__c, MZ_Style__c, MZ_ItemURL__c FROM MZ_Item__c 
                            WHERE MZ_SubCategory__c IN ('ニット', 'カーディガン', 'ベスト', 'アンサンブル', 'パーカー', 'スウェット', 'チュニック', 'その他トップス') 
                            AND MZ_Season__c INCLUDES(:season)]);
           }
        
        if(selectedItem[0].MZ_SubCategory__c == 'シャツ・ブラウス' || selectedItem[0].MZ_SubCategory__c == 'ポロシャツ') {
            innerTops = new Map<Id, MZ_Item__c>(selectedItem);
            allTops = new Map<Id, MZ_Item__c>(selectedItem);
        } else {
            innerTops = new Map<Id, MZ_Item__c>([SELECT Id, MZ_Color__r.Id, MZ_Color__r.MZ_ColorType__c, MZ_Design__r.MZ_DesignType__c, MZ_Style__c, MZ_ItemURL__c FROM MZ_Item__c 
                         WHERE MZ_SubCategory__c IN ('シャツ・ブラウス', 'ポロシャツ') AND MZ_Season__c INCLUDES(:season)]);
            if(allTops.isEmpty()) {
                allTops.putAll(outerTops);
                allTops.putAll(innerTops);
            }
        }
        
        if(selectedItem[0].MZ_SubCategory__c == 'シャツ・ブラウス' || selectedItem[0].MZ_SubCategory__c == 'Tシャツ・カットソー') {
            topsInners = new Map<Id, MZ_Item__c>(selectedItem);
        } else {
            topsInners = new Map<Id, MZ_Item__c>([SELECT Id, MZ_Color__r.Id, MZ_Color__r.MZ_ColorType__c, MZ_Design__r.MZ_DesignType__c, MZ_Style__c, MZ_ItemURL__c FROM MZ_Item__c 
                          WHERE MZ_SubCategory__c IN ('シャツ・ブラウス', 'Tシャツ・カットソー') AND MZ_Season__c INCLUDES(:season)]);
        }
        
        if(selectedItem[0].MZ_SubCategory__c == 'Tシャツ・カットソー' || selectedItem[0].MZ_SubCategory__c == 'タンクトップ') {
            inners = new Map<Id, MZ_Item__c>(selectedItem);
        } else {
            inners = new Map<Id, MZ_Item__c>([SELECT Id, MZ_Color__r.Id, MZ_Color__r.MZ_ColorType__c, MZ_Design__r.MZ_DesignType__c, MZ_Style__c, MZ_ItemURL__c FROM MZ_Item__c 
                      WHERE MZ_SubCategory__c IN ('Tシャツ・カットソー', 'タンクトップ') AND MZ_Season__c INCLUDES(:season)]);
        }
        
        if(selectedItem[0].MZ_Category__c == 'パンツ' || selectedItem[0].MZ_Category__c == 'スカート') {
            bottoms = new Map<Id, MZ_Item__c>(selectedItem);
        } else {
            bottoms = new Map<Id, MZ_Item__c>([SELECT Id, MZ_Color__r.Id, MZ_Color__r.MZ_ColorType__c, MZ_Design__r.MZ_DesignType__c, MZ_Style__c, MZ_ItemURL__c FROM MZ_Item__c 
                       WHERE MZ_Category__c IN ('パンツ', 'スカート') AND MZ_Season__c INCLUDES(:season)]);
        }
        
        if(selectedItem[0].MZ_Category__c == 'シューズ') {
            shoes = new Map<Id, MZ_Item__c>(selectedItem);
        } else {
            shoes = new Map<Id, MZ_Item__c>([SELECT Id, MZ_Color__r.Id, MZ_Color__r.MZ_ColorType__c, MZ_Design__r.MZ_DesignType__c, MZ_Style__c, MZ_ItemURL__c FROM MZ_Item__c 
                     WHERE MZ_Category__c = 'シューズ' AND MZ_Season__c INCLUDES(:season)]); 
        }

        // カラーマッチングテーブルを取得
        List<MZ_ColorMatching__c> colorMatchingTable = [SELECT Id, MZ_Color1__c, MZ_Color2__c, MZ_MatchingScore__c FROM MZ_ColorMatching__c];
        Map<String, Integer> colorMatchingMap = new Map<String, Integer>();
        for (MZ_ColorMatching__c cm : colorMatchingTable) {
            String key = cm.MZ_Color1__c + '-' + cm.MZ_Color2__c;
            colorMatchingMap.put(key, Integer.valueOf(cm.MZ_MatchingScore__c));
            String reverseKey = cm.MZ_Color2__c + '-' + cm.MZ_Color1__c;
            colorMatchingMap.put(reverseKey, Integer.valueOf(cm.MZ_MatchingScore__c));
        }
        
        // シーズンに応じたコーデパターンをセット
        switch on season {
            when '春', '秋' {
                if(outers.containsKey(itemId) || topsInners.containsKey(itemId) || bottoms.containsKey(itemId) || shoes.containsKey(itemId)) {
                    outerList.add(outers.values());
                    topsList.add(null);
                    innerList.add(topsInners.values());
                    bottomsList.add(bottoms.values());
                    shoesList.add(shoes.values());
                }
                
                if(outerTops.containsKey(itemId) || topsInners.containsKey(itemId) || bottoms.containsKey(itemId) || shoes.containsKey(itemId)) {
           		    outerList.add(null);
                    topsList.add(outerTops.values());
                    innerList.add(topsInners.values()); 
                    bottomsList.add(bottoms.values());
                    shoesList.add(shoes.values());
                }
                
                if(innerTops.containsKey(itemId) || inners.containsKey(itemId) || bottoms.containsKey(itemId) || shoes.containsKey(itemId)) {
                    outerList.add(null);
                    topsList.add(innerTops.values());
                    innerList.add(inners.values());
                    bottomsList.add(bottoms.values());
                    shoesList.add(shoes.values());
            	}
            }
            when '夏' {
                if(outers.containsKey(itemId) || inners.containsKey(itemId) || bottoms.containsKey(itemId) || shoes.containsKey(itemId)) {
                    outerList.add(outers.values());
                    topsList.add(null);
                    innerList.add(inners.values());
                    bottomsList.add(bottoms.values());
                    shoesList.add(shoes.values());
                }
                
                if(allTops.containsKey(itemId) || inners.containsKey(itemId) || bottoms.containsKey(itemId) || shoes.containsKey(itemId)) {
                    outerList.add(null);
                    topsList.add(allTops.values());
                    innerList.add(inners.values());
                    bottomsList.add(bottoms.values());
                    shoesList.add(shoes.values());
                }
                
                if(inners.containsKey(itemId) || bottoms.containsKey(itemId) || shoes.containsKey(itemId)) {
                    outerList.add(null);
                    topsList.add(null);
                    innerList.add(inners.values());
                    bottomsList.add(bottoms.values());
                    shoesList.add(shoes.values());
                }
            }
            when '冬' {
                if(outers.containsKey(itemId) || outerTops.containsKey(itemId) || topsInners.containsKey(itemId) || bottoms.containsKey(itemId) || shoes.containsKey(itemId)) {
                    outerList.add(outers.values());
                    topsList.add(outerTops.values());
                    innerList.add(topsInners.values());
                    bottomsList.add(bottoms.values());
                    shoesList.add(shoes.values());
                }
                    
                if(outers.containsKey(itemId) || innerTops.containsKey(itemId) || inners.containsKey(itemId) || bottoms.containsKey(itemId) || shoes.containsKey(itemId)) {
                    outerList.add(outers.values());
                    topsList.add(innerTops.values());
                    innerList.add(inners.values());
                    bottomsList.add(bottoms.values());
                    shoesList.add(shoes.values());
                }
            }
            when else {
                System.debug('[ERROR] Season is not set.');
            }
        }
        
        // outerList[i]〜shoesList[i]（レコードリスト）からcoordList[i]（レコードリスト）を総当りで作成
        for(Integer i = 0; i < outerList.size(); i++) {
            List<MZ_Coordinate__c> coordinates = new List<MZ_Coordinate__c>();
            if(outerList[i] != null) {
                for(MZ_Item__c otrs : outerList[i]) {
                    if(topsList[i] != null) {
                        for(MZ_Item__c tps: topsList[i]) {
                            for(MZ_Item__c inrs: innerList[i]) {
                                for(MZ_Item__c btms: bottomsList[i]) {
                                    for(MZ_Item__c shs: shoesList[i]) {
                                        MZ_Coordinate__c coordinate = new MZ_Coordinate__c(MZ_Outer__c = otrs.Id, MZ_Tops__c = tps.Id, MZ_Inner__c = inrs.Id, MZ_Bottoms__c = btms.Id, MZ_Shoes__c = shs.Id, MZ_season__c = season);

                                        coordinate.MZ_Outer__r = new MZ_Item__c(Id = otrs.Id, MZ_Style__c = otrs.MZ_Style__c, MZ_ItemURLText__c = otrs.MZ_ItemURL__c);
                                        coordinate.MZ_Outer__r.MZ_Color__r = new MZ_Color__c(Id = otrs.MZ_Color__r.Id, MZ_ColorType__c = otrs.MZ_Color__r.MZ_ColorType__c);
                                        coordinate.MZ_Outer__r.MZ_Design__r = new MZ_Design__c(Id = otrs.MZ_Design__r.Id, MZ_DesignType__c = otrs.MZ_Design__r.MZ_DesignType__c);
                                        
                                        coordinate.MZ_Tops__r = new MZ_Item__c(Id = tps.Id, MZ_Style__c = tps.MZ_Style__c, MZ_ItemURLText__c = tps.MZ_ItemURL__c);
                                        coordinate.MZ_Tops__r.MZ_Color__r = new MZ_Color__c(Id = tps.MZ_Color__r.Id, MZ_ColorType__c = tps.MZ_Color__r.MZ_ColorType__c);
                                        coordinate.MZ_Tops__r.MZ_Design__r = new MZ_Design__c(Id = tps.MZ_Design__r.Id, MZ_DesignType__c = tps.MZ_Design__r.MZ_DesignType__c);
                                        
                                        coordinate.MZ_Inner__r = new MZ_Item__c(Id = inrs.Id, MZ_Style__c = inrs.MZ_Style__c, MZ_ItemURLText__c = inrs.MZ_ItemURL__c);
                                        coordinate.MZ_Inner__r.MZ_Color__r = new MZ_Color__c(Id = inrs.MZ_Color__r.Id, MZ_ColorType__c = inrs.MZ_Color__r.MZ_ColorType__c);
                                        coordinate.MZ_Inner__r.MZ_Design__r = new MZ_Design__c(Id = inrs.MZ_Design__r.Id, MZ_DesignType__c = inrs.MZ_Design__r.MZ_DesignType__c);

                                        coordinate.MZ_Bottoms__r = new MZ_Item__c(Id = btms.Id, MZ_Style__c = btms.MZ_Style__c, MZ_ItemURLText__c = btms.MZ_ItemURL__c);
                                        coordinate.MZ_Bottoms__r.MZ_Color__r = new MZ_Color__c(Id = btms.MZ_Color__r.Id, MZ_ColorType__c = btms.MZ_Color__r.MZ_ColorType__c);
                                        coordinate.MZ_Bottoms__r.MZ_Design__r = new MZ_Design__c(Id = btms.MZ_Design__r.Id, MZ_DesignType__c = btms.MZ_Design__r.MZ_DesignType__c);
                                        
                                        coordinate.MZ_Shoes__r = new MZ_Item__c(Id = shs.Id, MZ_Style__c = shs.MZ_Style__c, MZ_ItemURLText__c = shs.MZ_ItemURL__c);
                                        coordinate.MZ_Shoes__r.MZ_Color__r = new MZ_Color__c(Id = shs.MZ_Color__r.Id, MZ_ColorType__c = shs.MZ_Color__r.MZ_ColorType__c);
                                        coordinate.MZ_Shoes__r.MZ_Design__r = new MZ_Design__c(Id = shs.MZ_Design__r.Id, MZ_DesignType__c = shs.MZ_Design__r.MZ_DesignType__c);
                                        
                                        coordinate.MZ_CoordinateScore__c = calcCoordinateScore(coordinate, colorMatchingMap);
                                        coordinates.add(coordinate);
                                    }
                                }
                            }
                        }
                    } else {
                        for(MZ_Item__c inrs: innerList[i]) {
                            for(MZ_Item__c btms: bottomsList[i]) {
                                for(MZ_Item__c shs: shoesList[i]) {
                                    MZ_Coordinate__c coordinate = new MZ_Coordinate__c(MZ_Outer__c = otrs.Id, MZ_Inner__c = inrs.Id, MZ_Bottoms__c = btms.Id, MZ_Shoes__c = shs.Id, MZ_season__c = season);
                                    
                                    coordinate.MZ_Outer__r = new MZ_Item__c(Id = otrs.Id, MZ_Style__c = otrs.MZ_Style__c, MZ_ItemURLText__c = otrs.MZ_ItemURL__c);
                                    coordinate.MZ_Outer__r.MZ_Color__r = new MZ_Color__c(Id = otrs.MZ_Color__r.Id, MZ_ColorType__c = otrs.MZ_Color__r.MZ_ColorType__c);
                                    coordinate.MZ_Outer__r.MZ_Design__r = new MZ_Design__c(Id = otrs.MZ_Design__r.Id, MZ_DesignType__c = otrs.MZ_Design__r.MZ_DesignType__c);
                                    
                                    coordinate.MZ_Inner__r = new MZ_Item__c(Id = inrs.Id, MZ_Style__c = inrs.MZ_Style__c, MZ_ItemURLText__c = inrs.MZ_ItemURL__c);
                                    coordinate.MZ_Inner__r.MZ_Color__r = new MZ_Color__c(Id = inrs.MZ_Color__r.Id, MZ_ColorType__c = inrs.MZ_Color__r.MZ_ColorType__c);
                                    coordinate.MZ_Inner__r.MZ_Design__r = new MZ_Design__c(Id = inrs.MZ_Design__r.Id, MZ_DesignType__c = inrs.MZ_Design__r.MZ_DesignType__c);
                                    
                                    coordinate.MZ_Bottoms__r = new MZ_Item__c(Id = btms.Id, MZ_Style__c = btms.MZ_Style__c, MZ_ItemURLText__c = btms.MZ_ItemURL__c);
                                    coordinate.MZ_Bottoms__r.MZ_Color__r = new MZ_Color__c(Id = btms.MZ_Color__r.Id, MZ_ColorType__c = btms.MZ_Color__r.MZ_ColorType__c);
                                    coordinate.MZ_Bottoms__r.MZ_Design__r = new MZ_Design__c(Id = btms.MZ_Design__r.Id, MZ_DesignType__c = btms.MZ_Design__r.MZ_DesignType__c);
                                    
                                    coordinate.MZ_Shoes__r = new MZ_Item__c(Id = shs.Id, MZ_Style__c = shs.MZ_Style__c, MZ_ItemURLText__c = shs.MZ_ItemURL__c);
                                    coordinate.MZ_Shoes__r.MZ_Color__r = new MZ_Color__c(Id = shs.MZ_Color__r.Id, MZ_ColorType__c = shs.MZ_Color__r.MZ_ColorType__c);
                                    coordinate.MZ_Shoes__r.MZ_Design__r = new MZ_Design__c(Id = shs.MZ_Design__r.Id, MZ_DesignType__c = shs.MZ_Design__r.MZ_DesignType__c);
                                    
                                    coordinate.MZ_CoordinateScore__c = calcCoordinateScore(coordinate, colorMatchingMap);
                                    coordinates.add(coordinate);
                                }
                            }
                        }
                    }
                }
            } else if(topsList[i] != null) {
                for(MZ_Item__c tps: topsList[i]) {
                    for(MZ_Item__c inrs: innerList[i]) {
                        for(MZ_Item__c btms: bottomsList[i]) {
                            for(MZ_Item__c shs: shoesList[i]) {
                                MZ_Coordinate__c coordinate = new MZ_Coordinate__c(MZ_Tops__c = tps.Id, MZ_Inner__c = inrs.Id, MZ_Bottoms__c = btms.Id, MZ_Shoes__c = shs.Id, MZ_season__c = season);
                                
                                coordinate.MZ_Tops__r = new MZ_Item__c(Id = tps.Id, MZ_Style__c = tps.MZ_Style__c, MZ_ItemURLText__c = tps.MZ_ItemURL__c);
                                coordinate.MZ_Tops__r.MZ_Color__r = new MZ_Color__c(Id = tps.MZ_Color__r.Id, MZ_ColorType__c = tps.MZ_Color__r.MZ_ColorType__c);
                                coordinate.MZ_Tops__r.MZ_Design__r = new MZ_Design__c(Id = tps.MZ_Design__r.Id, MZ_DesignType__c = tps.MZ_Design__r.MZ_DesignType__c);
                                
                                coordinate.MZ_Inner__r = new MZ_Item__c(Id = inrs.Id, MZ_Style__c = inrs.MZ_Style__c, MZ_ItemURLText__c = inrs.MZ_ItemURL__c);
                                coordinate.MZ_Inner__r.MZ_Color__r = new MZ_Color__c(Id = inrs.MZ_Color__r.Id, MZ_ColorType__c = inrs.MZ_Color__r.MZ_ColorType__c);
                                coordinate.MZ_Inner__r.MZ_Design__r = new MZ_Design__c(Id = inrs.MZ_Design__r.Id, MZ_DesignType__c = inrs.MZ_Design__r.MZ_DesignType__c);
                                
                                coordinate.MZ_Bottoms__r = new MZ_Item__c(Id = btms.Id, MZ_Style__c = btms.MZ_Style__c, MZ_ItemURLText__c = btms.MZ_ItemURL__c);
                                coordinate.MZ_Bottoms__r.MZ_Color__r = new MZ_Color__c(Id = btms.MZ_Color__r.Id, MZ_ColorType__c = btms.MZ_Color__r.MZ_ColorType__c);
                                coordinate.MZ_Bottoms__r.MZ_Design__r = new MZ_Design__c(Id = btms.MZ_Design__r.Id, MZ_DesignType__c = btms.MZ_Design__r.MZ_DesignType__c);
                                
                                coordinate.MZ_Shoes__r = new MZ_Item__c(Id = shs.Id, MZ_Style__c = shs.MZ_Style__c, MZ_ItemURLText__c = shs.MZ_ItemURL__c);
                                coordinate.MZ_Shoes__r.MZ_Color__r = new MZ_Color__c(Id = shs.MZ_Color__r.Id, MZ_ColorType__c = shs.MZ_Color__r.MZ_ColorType__c);
                                coordinate.MZ_Shoes__r.MZ_Design__r = new MZ_Design__c(Id = shs.MZ_Design__r.Id, MZ_DesignType__c = shs.MZ_Design__r.MZ_DesignType__c);
                                
                                coordinate.MZ_CoordinateScore__c = calcCoordinateScore(coordinate, colorMatchingMap);
                                coordinates.add(coordinate);
                            }
                        }
                    }
                }
            } else {
                for(MZ_Item__c inrs: innerList[i]) {
                    for(MZ_Item__c btms: bottomsList[i]) {
                        for(MZ_Item__c shs: shoesList[i]) {
                            MZ_Coordinate__c coordinate = new MZ_Coordinate__c(MZ_Inner__c = inrs.Id, MZ_Bottoms__c = btms.Id, MZ_Shoes__c = shs.Id, MZ_season__c = season);
                            
                            coordinate.MZ_Inner__r = new MZ_Item__c(Id = inrs.Id, MZ_Style__c = inrs.MZ_Style__c, MZ_ItemURLText__c = inrs.MZ_ItemURL__c);
                            coordinate.MZ_Inner__r.MZ_Color__r = new MZ_Color__c(Id = inrs.MZ_Color__r.Id, MZ_ColorType__c = inrs.MZ_Color__r.MZ_ColorType__c);
                            coordinate.MZ_Inner__r.MZ_Design__r = new MZ_Design__c(Id = inrs.MZ_Design__r.Id, MZ_DesignType__c = inrs.MZ_Design__r.MZ_DesignType__c);
                            
                            coordinate.MZ_Bottoms__r = new MZ_Item__c(Id = btms.Id, MZ_Style__c = btms.MZ_Style__c, MZ_ItemURLText__c = btms.MZ_ItemURL__c);
                            coordinate.MZ_Bottoms__r.MZ_Color__r = new MZ_Color__c(Id = btms.MZ_Color__r.Id, MZ_ColorType__c = btms.MZ_Color__r.MZ_ColorType__c);
                            coordinate.MZ_Bottoms__r.MZ_Design__r = new MZ_Design__c(Id = btms.MZ_Design__r.Id, MZ_DesignType__c = btms.MZ_Design__r.MZ_DesignType__c);
                            
                            coordinate.MZ_Shoes__r = new MZ_Item__c(Id = shs.Id, MZ_Style__c = shs.MZ_Style__c, MZ_ItemURLText__c = shs.MZ_ItemURL__c);
                            coordinate.MZ_Shoes__r.MZ_Color__r = new MZ_Color__c(Id = shs.MZ_Color__r.Id, MZ_ColorType__c = shs.MZ_Color__r.MZ_ColorType__c);
                            coordinate.MZ_Shoes__r.MZ_Design__r = new MZ_Design__c(Id = shs.MZ_Design__r.Id, MZ_DesignType__c = shs.MZ_Design__r.MZ_DesignType__c);
                            
                            coordinate.MZ_CoordinateScore__c = calcCoordinateScore(coordinate, colorMatchingMap);
                            coordinates.add(coordinate);
                        }
                    }
                }
            }
            coordList.add(coordinates);
        }
        // コーデパターン毎にスコア順に並び替え、上位100件を取得
        for(Integer i = 0; i < outerList.size(); i++) {
            coordList[i].sort(new CoordinateComparator());
            for (Integer j = 0; j < 100 && j < coordList[i].size(); j++) {
                recommendCoordList.add(coordList[i][j]);
            }	
        }
        
		return recommendCoordList;                                                                                                         
    }
    
    // コーデスコアを計算
    static Integer calcCoordinateScore(MZ_Coordinate__c coordinate, Map<String, Integer> colorMatchingMap) {
        Integer score = 0;
        Integer accentCnt = 0;
        Integer designCnt = 0;
        Integer formalCnt = 0;
        Integer casualCnt = 0;
        Decimal formalRate = 0;
        
        List<MZ_Item__c> itemList = new List<MZ_Item__c>{
            coordinate.MZ_Outer__r, 
            coordinate.MZ_Tops__r,
            coordinate.MZ_Inner__r,
            coordinate.MZ_Bottoms__r,
            coordinate.MZ_Shoes__r
        };
        
        // カラーマッチングテーブルに基づき各アイテムの組み合わせからスコアを算出
        for (Integer i = 0; i < itemList.size(); i++) {
            for (Integer j = i + 1; j < itemList.size(); j++) { // i < j を暗黙的に実現
                if (itemList[i] != null && itemList[j] != null) {
                    String key = itemList[i].MZ_Color__r.Id + '-' + itemList[j].MZ_Color__r.Id;
                    if (colorMatchingMap.containsKey(key)) {
                        score += colorMatchingMap.get(key);
                    }
                }
            }
        }
        
        // アクセントカラー、デザイン有無、フォーマル/カジュアル数を集計
        for(MZ_Item__c item: itemList) {
            if(item != null) {
                if(item.MZ_Color__r.MZ_ColorType__c == 'アクセント') {
                    accentCnt += 1;
                }
                if(item.MZ_Design__r.MZ_DesignType__c == 'デザイン') {
                    designCnt += 1;
                }
                if(item.MZ_Style__c == 'フォーマル') {
                    formalCnt += 1;
                } else if (item.MZ_Style__c == 'カジュアル') {
                    casualCnt += 1;
                }
            }
        }
        
        // 集計値に応じてスコアを調整
        if(formalCnt + casualCnt > 0) {
            formalRate = (Decimal)formalCnt / (formalCnt + casualCnt);
        } else {
            formalRate = 0;
        }
        if(accentCnt == 1) {
            score += 3;
        } else if(accentCnt >= 2) {
            score -= 3;
        }
        if(designCnt == 1) {
            score += 3;
        } else if(designCnt >= 2) {
            score -= 3;
        }
        if(formalRate <= 0.5) {
            score -= 3;
        } else if(formalRate > 0.5 && formalRate <= 0.8) {
            score += 3;
        } else {
            score -= 3;
        }
        return score;
    }
    
    @AuraEnabled
    public static List<String> createMyCoordinates(List<MZ_Coordinate__c> myCoordinates) {
        List<String> errors = new List<String>();
        if (myCoordinates != null || !myCoordinates.isEmpty()) {
            Database.SaveResult[] results = Database.insert(myCoordinates, false);
            for(Database.SaveResult result: results) {
                if(!result.isSuccess()) {
                    for(Database.Error error: result.getErrors()) {
                        errors.add(error.getMessage());                      
                    }
                }
            }
        }
        return errors;
     }
    
    @AuraEnabled
    public static void deleteMyCoordinates(List<MZ_Coordinate__c> myCoordinates) {
        if (myCoordinates != null || !myCoordinates.isEmpty()) {
            try {
                delete myCoordinates;
            } catch(DmlException e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
    }
}