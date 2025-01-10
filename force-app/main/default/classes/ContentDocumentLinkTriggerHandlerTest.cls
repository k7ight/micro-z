@isTest
private class ContentDocumentLinkTriggerHandlerTest {
    @TestSetup
    static void setupTestData() {
        // Colorレコード、Designレコードを作成
        insert new MZ_Color__c(Name = 'テストカラー', MZ_ColorType__c = 'ベース', MZ_ColorGroup__c = 'その他カラー');
        insert new MZ_Design__c(Name = 'テストデザイン', MZ_DesignType__c = '無地');
        
        // Itemレコードを作成
        MZ_Item__c item = new MZ_Item__c();
        RecordType rt = [select Id from RecordType where DeveloperName = 'MZ_Outer_RecordType' limit 1];
        MZ_Color__c color = [select Id from MZ_Color__c where Name = 'テストカラー' limit 1];
        MZ_Design__c design = [select Id from MZ_Design__c where Name = 'テストデザイン' limit 1];
        item.Name = 'テストアウター';
        item.RecordTypeId = rt.Id;
        item.MZ_Category__c = 'アウター';
        item.MZ_SubCategory__c = 'その他アウター';
        item.MZ_Color__c = color.Id;
        item.MZ_Design__c = design.Id;
        item.MZ_Season__c = '冬';
        item.MZ_Style__c = 'フォーマル';
        insert item;
        
        // ContentVersionレコード（ダミー画像）を作成
        List<ContentVersion> cvList = new List<ContentVersion>();
        for(integer i = 1; i <= 2; i++) {
            ContentVersion cv = new ContentVersion();
            cv.Title = 'テストイメージ' + i;
            cv.PathOnClient = i == 1 ? 'test1.jpg' : 'test2.png';
            cv.VersionData = Blob.valueOf('test' + i); // 文字列からダミー画像（BLOG型）を生成
            cvList.add(cv);
        }
        
        insert cvList;
    }
   
    @isTest
    static void testInsertAndDelete() {
        // テストItemレコード、ContentVersionレコードを取得
        MZ_Item__c item = [select Id, MZ_ContentVersionId__c, MZ_ContentBodyId__c, MZ_ImageFileExtension__c from MZ_Item__c where Name = 'テストアウター' limit 1];
        ContentVersion cv1 = [select Id, ContentDocumentId, ContentBodyId, FileExtension from ContentVersion where Title = 'テストイメージ1' limit 1];
        ContentVersion cv2 = [select Id, ContentDocumentId, ContentBodyId, FileExtension from ContentVersion where Title = 'テストイメージ2' limit 1];
        
        // ContentDocumentLinkレコードを新規作成
        ContentDocumentLink cdl1 = new ContentDocumentLink(LinkedEntityId = item.Id, ContentDocumentId = cv1.ContentDocumentId);
        insert cdl1;
        
        // 結果テスト
        MZ_Item__c updatedItem1 = [select MZ_ContentVersionId__c, MZ_ContentBodyId__c, MZ_ImageFileExtension__c from MZ_Item__c where Name = 'テストアウター' limit 1];
        System.assertEquals(cv1.Id, updatedItem1.MZ_ContentVersionId__c, 'ContentVersionId is not correct.');
        System.assertEquals(cv1.ContentBodyId, updatedItem1.MZ_ContentBodyId__c, 'ContentBodyId is not correct.');
        System.assertEquals('jpg', updatedItem1.MZ_ImageFileExtension__c, 'ImageFileExtension is not correct.');

        // ContentDocumentLinkレコードを追加作成
        ContentDocumentLink cdl2 = new ContentDocumentLink(LinkedEntityId = item.Id, ContentDocumentId = cv2.ContentDocumentId);
        insert cdl2;
        
        // 結果テスト（対象外）
        MZ_Item__c updatedItem2 = [select MZ_ContentVersionId__c, MZ_ContentBodyId__c, MZ_ImageFileExtension__c from MZ_Item__c where Name = 'テストアウター' limit 1];
        System.assertEquals(cv2.Id, updatedItem2.MZ_ContentVersionId__c, 'ContentVersionId is not correct.');
        System.assertEquals(cv2.ContentBodyId, updatedItem2.MZ_ContentBodyId__c, 'ContentBodyId is not correct.');
        System.assertEquals('png', updatedItem2.MZ_ImageFileExtension__c, 'ImageFileExtension is not correct.');

        
        // ContentDocumentLinkレコードを削除（関連ファイル残）
        delete cdl2;
        // 結果テスト
        MZ_Item__c deletedItem1 = [select MZ_ContentVersionId__c, MZ_ContentBodyId__c, MZ_ImageFileExtension__c from MZ_Item__c where Name = 'テストアウター' limit 1];
        System.assertEquals(cv1.Id, deletedItem1.MZ_ContentVersionId__c, 'ContentVersionId is not correct.');
        System.assertEquals(cv1.ContentBodyId, deletedItem1.MZ_ContentBodyId__c, 'ContentBodyId is not correct.');
        System.assertEquals('jpg', deletedItem1.MZ_ImageFileExtension__c, 'ImageFileExtension is not correct.');
        
        // ContentDocumentLinkレコードを削除（関連ファイル無）
        delete cdl1;
        // 結果テスト
        MZ_Item__c deletedItem2 = [select MZ_ContentVersionId__c, MZ_ContentBodyId__c, MZ_ImageFileExtension__c from MZ_Item__c where Name = 'テストアウター' limit 1];
        System.assert(deletedItem2.MZ_ContentVersionId__c == null, 'ContentVersionId is not null.');
        System.assert(deletedItem2.MZ_ContentBodyId__c == null, 'ContentBodyId is not null.');
        System.assert(deletedItem2.MZ_ImageFileExtension__c == null, 'ImageFileExtension is not null.');    
    }
}