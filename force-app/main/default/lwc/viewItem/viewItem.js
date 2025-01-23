import { LightningElement, api } from 'lwc';

export default class ViewItem extends LightningElement {
    @api item;
    @api season;

    get itemImage() {
        return `
            background-image: url('${this.item.MZ_ItemURL__c.value}'); 
            background-size: cover; 
            background-position: center;
            aspect-ratio: 1;
        `;
    }

    get seasonOptions() {
        const season = this.item.MZ_Season__c.value.split(';');
        return season.map(value => ({
            label: value,
            value: value
        }));
    }

    handleSeasonChange(event) {
        this.season = event.detail.value;
        const ce = new CustomEvent(
            'selectitem',
            {
                detail: {
                    season: this.season
                }
            }
        );
        this.dispatchEvent(ce);
    }
}