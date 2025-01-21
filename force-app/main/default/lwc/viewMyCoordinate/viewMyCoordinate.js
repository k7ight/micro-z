import { LightningElement, api } from 'lwc';

export default class ViewMyCoordinate extends LightningElement {
    @api item;

    handleViewMyCoordinate() {
        const pageRef = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'MZ_MyCoordinate_Tab'
            },
            state: {
                c__recordId: this.item.Id
            }
        };
        
        const event = new CustomEvent('navigate', {
            detail: pageRef,
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(event);
    }
}