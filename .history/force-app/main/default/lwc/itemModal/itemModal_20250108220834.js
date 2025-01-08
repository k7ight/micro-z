import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ItemModal extends LightningModal {
    @api item;
    @api itemList;

    handleEditItem() {
        const recordId = this.item.Id;
        const Url = `/lightning/r/MZ_Item__c/${recordId}/view`;
        window.location.href = Url; // 画面遷移
    }

    async handleDeleteItem() {
        const retUrl = 'lightning/n/Tab';
        const recordId = this.item.Id;
    
        try {
            await deleteRecord(recordId);
    
            // 削除成功時のトースト通知
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'アイテムが削除されました',
                    variant: 'success'
                })
            );
    
            // アイテムリストのリフレッシュ（@wireの結果をリフレッシュ）

            // モーダルを閉じる処理
            this.close();
        } catch (error) {
            // 削除失敗時のエラートースト通知
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'アイテムが削除できませんでした\n' + error.body.message,
                    variant: 'error'
                })
            );
        }
    }
}