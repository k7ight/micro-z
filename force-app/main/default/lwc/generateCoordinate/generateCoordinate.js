import { api, LightningElement } from 'lwc';

export default class GenerateCoordinate extends LightningElement {
    @api item;

    handleGenerateCoordinate() {
        const pageRef = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'MZ_RecommendCoordinate_Tab'
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