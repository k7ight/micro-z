import { LightningElement } from 'lwc';
import LightningModal from 'lightning/modal';

export default class ItemCreateModal extends LightningModal {
    handleStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            this.close('OK');
        }
    }
}