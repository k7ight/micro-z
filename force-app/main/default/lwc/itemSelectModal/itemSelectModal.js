import { wire } from 'lwc';
import LightningModal from 'lightning/modal';
import getItems from '@salesforce/apex/ItemController.getItems';

export default class ItemSelectModal extends LightningModal {

    @wire(getItems, {
        category: '',
        subCategory: '',
        colorGroup: '',
        designType: '',
        season: '',
        searchKey: '',
        sortKey: '',
        sortOrder: ''
    })
    items;

    handleSelectItem(event) {
        this.close(event.detail.Id);
    } 
}