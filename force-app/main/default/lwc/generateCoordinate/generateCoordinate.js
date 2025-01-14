import { api, LightningElement } from 'lwc';

export default class GenerateCoordinate extends LightningElement {
    @api item;

    handleGenerateCoordinate() {
        console.log('[DEBUG] handleGenerateCoordinate call');
        console.log('[DEBUG] this.item.Id:' + this.item.Id);
        const pageRef = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'MZ_RecommendCoordinate_Tab'
            },
            state: {
                c__recordId: this.item.Id
            }
        };
        console.log('[DEBUG] pageRef:' + pageRef.state.c__recordId);
       
        const event = new CustomEvent('navigate', {
            detail: pageRef,
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(event);
    }
}