import { api, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import { NavigationMixin } from 'lightning/navigation';
// import { publish, MessageContext } from 'lightning/messageService';
// import ITEM_MESSAGE_CHANNEL from '@salesforce/messageChannel/ItemMessageChannel__c';

export default class ItemModal extends LightningModal {
    @api item;
    // @api scrollPosition;

    // @wire(MessageContext)
    // messageContext;

    handleEditItem() {
        const recordId = this.item.Id;
        const Url = `/lightning/r/MZ_Item__c/${recordId}/view`;
        this.close();
        window.location.href = Url; // 画面遷移
    }

    async handleDeleteItem() {
        const retUrl = 'lightning/n/MZ_SearchItem_Tab';
        const recordId = this.item.Id;
        const dialog = window.confirm('このアイテムの削除を実行しますか?');

        if (!dialog) {
            return;
        }
    
        try {
            await deleteRecord(recordId);
    
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'アイテムが削除されました',
                    variant: 'success'
                })
            );

            this.close();
            setTimeout(() => { window.location.href = retUrl; }, 1000);

        } catch (error) {

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'アイテムの削除に失敗しました:' + error.body.message,
                    variant: 'error'
                })
            );
        }
    }

    handleCloseModal() {
        console.log('[DEBUG] handleCloseModal call');
        this.close();
    }
    // close() {
    //     console.log('[DEBUG] close() call');
    //     console.log('[DEBUG] scrollPosition: ' + this.scrollPosition);
    //     super.close();
    //     window.scrollTo(0, this.scrollPosition);
    // }
}