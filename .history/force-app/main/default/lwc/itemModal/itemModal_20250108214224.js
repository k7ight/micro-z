import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ItemModal extends LightningModal {
    @api item;

    handleEditItem() {
        const recordId = this.item.Id;
        const Url = `/lightning/r/MZ_Item__c/${recordId}/view`;
        window.location.href = Url; // 画面遷移
    }

    handleDeleteItem() {
        const retUrl = 'lightning/n/Tab';
        const recordId = this.item.Id;
        deleteRecord(recordId)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'アイテムが削除されました',
                    variant: 'success'
                })
            );
            this.close();
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        })
    }
}