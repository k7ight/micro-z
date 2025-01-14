import { LightningElement, api } from 'lwc';

export default class ViewItem extends LightningElement {
    @api item;
    season = '';

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
        console.log('[DEBUG] season: ' + season);
        return season.map(value => ({
            label: value,
            value: value
        }));
    }

    handleSeasonChange(event) {
        this.season = event.detail.value
    }

    handleGenerate() {
        if(this.season === '') {
            alert('対象シーズンを選択してください。');
            return;
        }
        console.log('[DEBUG] viewItem handleGenerate call');
        const event = new CustomEvent(
            'genarate',
            {
                detail: {
                    category: this.item.MZ_Category__c,
                    subCategory: this.item.MZ_SubCategory__c,
                    colorId: this.item.MZ_Color__r.Id,
                    designType: this.item.MZ_Design__r.MZ_DesignType__c,
                    season: this.season,
                    style: this.item.MZ_Style__c
                }
            }
        );
        this.dispatchEvent(event);
    }
}