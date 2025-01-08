import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class ItemModal extends LightningModal {
    @api item;

    handleEditItem() {
        const Url = `/flow/${flowApiName}?retURL=${retURL}`; // フローのURLを構築
        window.location.href = flowUrl; // 画面遷移
    }
}