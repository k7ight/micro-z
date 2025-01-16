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
    
    @AuraEnabled(cacheable=true)
    public static List<MZ_Coordinate__c> generateCoordinates(Id recordId, String season) {
        // アウター、トップス、インナー、ボトムス、シューズのリスト格納用
        List<List<MZ_Item__c>> outerList = new List<List<MZ_Item__c>>();
        List<List<MZ_Item__c>> topsList = new List<List<MZ_Item__c>>();
        List<List<MZ_Item__c>> innerList = new List<List<MZ_Item__c>>();
        List<List<MZ_Item__c>> bottomsList = new List<List<MZ_Item__c>>();
        List<List<MZ_Item__c>> shoesList = new List<List<MZ_Item__c>>();
        
        // コーデリスト格納用
        List<List<MZ_Coordinate__c>> coordList = new List<List<MZ_Coordinate__c>>();
        List<MZ_Coordinate__c> recommendCoordList = new List<MZ_Coordinate__c>();
        
        // アウター、トップス、インナー、ボトムス、シューズのリスト取得
        List<MZ_Item__c> outers = [SELECT Id, MZ_Color__r.Id, MZ_Color__r.MZ_ColorType__c, MZ_Design__r.MZ_DesignType__c, MZ_Style__c, MZ_ItemURL__c FROM MZ_Item__c 
                                   WHERE MZ_Category__c = 'アウター' AND MZ_Season__c INCLUDES(:season)];
        List<MZ_Item__c> outerTops = [SELECT Id, MZ_Color__r.Id, MZ_Color__r.MZ_ColorType__c, MZ_Design__r.MZ_DesignType__c, MZ_Style__c, MZ_ItemURL__c FROM MZ_Item__c 
                                      WHERE MZ_SubCategory__c IN ('ニット', 'カーディガン', 'ベスト', 'アンサンブル', 'パーカー', 'スウェット', 'チュニック', 'その他トップス') 
                                      AND MZ_Season__c INCLUDES(:season)];
        List<MZ_Item__c> innerTops = [SELECT Id, MZ_Color__r.Id, MZ_Color__r.MZ_ColorType__c, MZ_Design__r.MZ_DesignType__c, MZ_Style__c, MZ_ItemURL__c FROM MZ_Item__c 
                                      WHERE MZ_SubCategory__c IN ('シャツ・ブラウス', 'ポロシャツ') AND MZ_Season__c INCLUDES(:season)];
        List<MZ_Item__c> allTops = new List<MZ_Item__c>();
        allTops.addAll(outerTops);
        allTops.addAll(innerTops);
		List<MZ_Item__c> topsInners = [SELECT Id, MZ_Color__r.Id, MZ_Color__r.MZ_ColorType__c, MZ_Design__r.MZ_DesignType__c, MZ_Style__c, MZ_ItemURL__c FROM MZ_Item__c 
                                       WHERE MZ_SubCategory__c IN ('シャツ・ブラウス', 'Tシャツ・カットソー') AND MZ_Season__c INCLUDES(:season)];
        List<MZ_Item__c> inners = [SELECT Id, MZ_Color__r.Id, MZ_Color__r.MZ_ColorType__c, MZ_Design__r.MZ_DesignType__c, MZ_Style__c, MZ_ItemURL__c FROM MZ_Item__c 
                                   WHERE MZ_SubCategory__c IN ('Tシャツ・カットソー', 'タンクトップ') AND MZ_Season__c INCLUDES(:season)];
        List<MZ_Item__c> bottoms = [SELECT Id, MZ_Color__r.Id, MZ_Color__r.MZ_ColorType__c, MZ_Design__r.MZ_DesignType__c, MZ_Style__c, MZ_ItemURL__c FROM MZ_Item__c 
                                    WHERE MZ_Category__c IN ('パンツ', 'スカート') AND MZ_Season__c INCLUDES(:season)];
        List<MZ_Item__c> shoes = [SELECT Id, MZ_Color__r.Id, MZ_Color__r.MZ_ColorType__c, MZ_Design__r.MZ_DesignType__c, MZ_Style__c, MZ_ItemURL__c FROM MZ_Item__c 
                                  WHERE MZ_Category__c = 'シューズ' AND MZ_Season__c INCLUDES(:season)]; 
        
        // Idが存在する場合は該当カテゴリを固定アイテムにセット
        outers = setSelectedItem(recordId, outers);
       	outerTops = setSelectedItem(recordId, outerTops);
        innerTops = setSelectedItem(recordId, innerTops);
        allTops = setSelectedItem(recordId, allTops);
        topsInners = setSelectedItem(recordId, topsInners);
        inners = setSelectedItem(recordId, inners);
        bottoms = setSelectedItem(recordId, bottoms);
        shoes = setSelectedItem(recordId, shoes);    
        
        // カラーマッチングテーブルを取得
        List<MZ_ColorMatching__c> colorMatchingTable = [SELECT Id, MZ_Color1__c, MZ_Color2__c, MZ_MatchingScore__c FROM MZ_ColorMatching__c];
        
        // シーズンに応じたコーデパターンをセット
        switch on season {
            when '春', '秋' {
                outerList.add(outers);
                outerList.add(null);
                outerList.add(null);
            	topsList.add(null);
                topsList.add(outerTops);
                topsList.add(innerTops);
                innerList.add(topsInners);
                innerList.add(topsInners);
                innerList.add(inners);
                bottomsList.add(bottoms);
                bottomsList.add(bottoms);
                bottomsList.add(bottoms);
                shoesList.add(shoes);
                shoesList.add(shoes);
                shoesList.add(shoes);
            }
            when '夏' {
                outerList.add(outers);
                outerList.add(null);
                outerList.add(null);
            	topsList.add(null);
                topsList.add(allTops);
                topsList.add(null);
                innerList.add(inners);
                innerList.add(inners);
                innerList.add(inners);
                bottomsList.add(bottoms);
                bottomsList.add(bottoms);
                bottomsList.add(bottoms);
                shoesList.add(shoes);
                shoesList.add(shoes);
                shoesList.add(shoes);
            }
            when '冬' {
                outerList.add(outers);
                outerList.add(outers);
                topsList.add(outerTops);
                topsList.add(innerTops);
                innerList.add(topsInners);
                innerList.add(inners);
                bottomsList.add(bottoms);
                bottomsList.add(bottoms);
                shoesList.add(shoes);
                shoesList.add(shoes);
            }
            when else {
                System.debug('[ERROR] Season is not set.');
            }
        }
        
        System.debug('outerList: ' + outerList);
        System.debug('topsList: ' + topsList);
        System.debug('innerList: ' + innerList);
        System.debug('bottomsList: ' + bottomsList);
        System.debug('shoesList: ' + shoesList);
        
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
                                        MZ_Coordinate__c coordinate = new MZ_Coordinate__c(MZ_Outer__c = otrs.Id, MZ_Tops__c = tps.Id, MZ_Inner__c = inrs.Id, MZ_Bottoms__c = btms.Id, MZ_Shoes__c = shs.Id);

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
                                        
                                        System.debug('coordinate: ' + coordinate);
                                        coordinate.MZ_CoordinateScore__c = calcCoordinateScore(coordinate, colorMatchingTable);
                                        coordinates.add(coordinate);
                                        System.debug('coordinates: ' + coordinates);
                                    }
                                }
                            }
                        }
                    } else {
                        for(MZ_Item__c inrs: innerList[i]) {
                            for(MZ_Item__c btms: bottomsList[i]) {
                                for(MZ_Item__c shs: shoesList[i]) {
                                    MZ_Coordinate__c coordinate = new MZ_Coordinate__c(MZ_Outer__c = otrs.Id, MZ_Inner__c = inrs.Id, MZ_Bottoms__c = btms.Id, MZ_Shoes__c = shs.Id);
                                    
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
                                    
                                    System.debug('coordinate: ' + coordinate);
                                    coordinate.MZ_CoordinateScore__c = calcCoordinateScore(coordinate, colorMatchingTable);
                                    coordinates.add(coordinate);
                                    System.debug('coordinates: ' + coordinates);
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
                                MZ_Coordinate__c coordinate = new MZ_Coordinate__c(MZ_Tops__c = tps.Id, MZ_Inner__c = inrs.Id, MZ_Bottoms__c = btms.Id, MZ_Shoes__c = shs.Id);
                                
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
                                
                                System.debug('coordinate: ' + coordinate);
                                coordinate.MZ_CoordinateScore__c = calcCoordinateScore(coordinate, colorMatchingTable);
                                coordinates.add(coordinate);
                                System.debug('coordinates: ' + coordinates);
                            }
                        }
                    }
                }
            } else {
                for(MZ_Item__c inrs: innerList[i]) {
                    for(MZ_Item__c btms: bottomsList[i]) {
                        for(MZ_Item__c shs: shoesList[i]) {
                            MZ_Coordinate__c coordinate = new MZ_Coordinate__c(MZ_Inner__c = inrs.Id, MZ_Bottoms__c = btms.Id, MZ_Shoes__c = shs.Id);
                            coordinate.MZ_Inner__r = new MZ_Item__c(Id = inrs.Id, MZ_Style__c = inrs.MZ_Style__c, MZ_ItemURLText__c = inrs.MZ_ItemURL__c);
                            coordinate.MZ_Inner__r.MZ_Color__r = new MZ_Color__c(Id = inrs.MZ_Color__r.Id, MZ_ColorType__c = inrs.MZ_Color__r.MZ_ColorType__c);
                            coordinate.MZ_Inner__r.MZ_Design__r = new MZ_Design__c(Id = inrs.MZ_Design__r.Id, MZ_DesignType__c = inrs.MZ_Design__r.MZ_DesignType__c);
                            
                            coordinate.MZ_Bottoms__r = new MZ_Item__c(Id = btms.Id, MZ_Style__c = btms.MZ_Style__c, MZ_ItemURLText__c = btms.MZ_ItemURL__c);
                            coordinate.MZ_Bottoms__r.MZ_Color__r = new MZ_Color__c(Id = btms.MZ_Color__r.Id, MZ_ColorType__c = btms.MZ_Color__r.MZ_ColorType__c);
                            coordinate.MZ_Bottoms__r.MZ_Design__r = new MZ_Design__c(Id = btms.MZ_Design__r.Id, MZ_DesignType__c = btms.MZ_Design__r.MZ_DesignType__c);
                            
                            coordinate.MZ_Shoes__r = new MZ_Item__c(Id = shs.Id, MZ_Style__c = shs.MZ_Style__c, MZ_ItemURLText__c = shs.MZ_ItemURL__c);
                            coordinate.MZ_Shoes__r.MZ_Color__r = new MZ_Color__c(Id = shs.MZ_Color__r.Id, MZ_ColorType__c = shs.MZ_Color__r.MZ_ColorType__c);
                            coordinate.MZ_Shoes__r.MZ_Design__r = new MZ_Design__c(Id = shs.MZ_Design__r.Id, MZ_DesignType__c = shs.MZ_Design__r.MZ_DesignType__c);
                            
                            System.debug('coordinate: ' + coordinate);
                            coordinate.MZ_CoordinateScore__c = calcCoordinateScore(coordinate, colorMatchingTable);
                            coordinates.add(coordinate);
                            System.debug('coordinates: ' + coordinates);
                        }
                    }
                }
            }
            coordList.add(coordinates);
            System.debug('coordList: ' + coordList);
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
    
    // Idに一致するレコードがあれば固定値をセット
    static List<MZ_Item__c> setSelectedItem(Id recordId, List<MZ_Item__c> itemList) {
        for(MZ_Item__c item: itemList) {
            if(item.Id == recordId) {
                return new List<MZ_Item__c>{item};
            }
        }
        return itemList;
    }
    
    // コーデスコアを計算
    static Integer calcCoordinateScore(MZ_Coordinate__c coordinate, List<MZ_ColorMatching__c> colorMatchingTable) {
        Integer score = 0;
        Integer accentCnt = 0;
        Integer designCnt = 0;
        Integer formalCnt = 0;
        Integer casualCnt = 0;
        Decimal formalRate = 0;
        
        System.debug('coordinate: ' + coordinate);
        
        List<MZ_Item__c> itemList = new List<MZ_Item__c>{
            coordinate.MZ_Outer__r, 
            coordinate.MZ_Tops__r,
            coordinate.MZ_Inner__r,
            coordinate.MZ_Bottoms__r,
            coordinate.MZ_Shoes__r
        };
        
        // カラーマッチングテーブルに基づき各アイテムの組み合わせからスコアを算出
        for(MZ_ColorMatching__c cm: colorMatchingTable) {
            for(Integer i = 0; i < itemList.size(); i++) {
                for(Integer j = 0; j < itemList.size(); j++) {
                    if(i < j) {
                        if(itemList[i] != null && itemList[j] != null) {
                            if(itemList[i].MZ_Color__c == cm.MZ_Color1__c && itemList[j].MZ_Color__c == cm.MZ_Color2__c) {
                                score += Integer.valueOf(cm.MZ_MatchingScore__c);
                            } else if(itemList[i].MZ_Color__c == cm.MZ_Color2__c && itemList[j].MZ_Color__c == cm.MZ_Color1__c) {
                                score += Integer.valueOf(cm.MZ_MatchingScore__c);
                            } else {
                                // System.debug('[ERROR] ColorMatching is not registered.');
                            }
                        }
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
            formalRate = formalCnt / (formalCnt + casualCnt);
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
}