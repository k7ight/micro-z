import { LightningElement, api } from 'lwc';

export default class ViewItem extends LightningElement {
    @api item;

    get itemImage() {
        return `
            background-image: url('${this.item.MZ_ItemURL__c.value}'); 
            background-size: cover; 
            background-position: center;
            aspect-ratio: 1;
        `;
    }
}