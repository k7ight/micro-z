import { LightningElement, api } from 'lwc';

export default class Item extends LightningElement {
    @api item;

    get itemImage() {
        return `
            background-image: url('${this.item.MZ_ItemURL__c}'); 
            background-size: cover; 
            background-position: center;
            aspect-ratio: 1;
        `;
    }

    handleItemClick() {
        this.dispatchEvent(new CustomEvent('openmodal', { detail: this.item}));
    }
}