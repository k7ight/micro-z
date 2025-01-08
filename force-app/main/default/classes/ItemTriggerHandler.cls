public class ItemTriggerHandler {
    public static void TriggerBeforeInsert(List<MZ_Item__c> items) {
        // アイテムレコードからアイテム画像（リッチテキスト）を取得
        // 取得したテキストの<img src="から"までの文字列をアイテム画像URLに登録（★Afterじゃないと無理？）
    }
    public static void TriggerBeforeUpdate(List<MZ_Item__c> items) {
        
    }
}