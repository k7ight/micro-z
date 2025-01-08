import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class ItemModal extends LightningModal {
    @api item;

    handleEditItem() {
        const retURL = 'lightning/n/Tab'; // フロー終了後の遷移先URL
        const flowUrl = `/flow/${flowApiName}?retURL=${retURL}`; // フローのURLを構築
        window.location.href = flowUrl; // 画面遷移
    }
}