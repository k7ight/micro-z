import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class ItemModal extends LightningModal {
    @api item;
}