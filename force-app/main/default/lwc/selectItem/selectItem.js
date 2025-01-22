import { LightningElement, api } from 'lwc';

export default class SelectItem extends LightningElement {
    @api item;

    get itemImage() {
        return `
            background-image: url('${this.item.MZ_ItemURL__c}'); 
            background-size: cover; 
            background-position: center;
            aspect-ratio: 1;
        `;
    }

    handleSelectItem() {
        this.dispatchEvent(new CustomEvent('selectitem', {detail: this.item}));
    }
}