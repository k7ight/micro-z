import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class ItemModal extends LightningModal {
    @api item;

    handleEditItem() {
        const recordId = this.item.Id;;
        const Url = `/lightning/r/MZ_Item__c/${recordId}/view`;
        window.location.href = flowUrl; // 画面遷移
    }
}