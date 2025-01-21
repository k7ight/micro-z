import { LightningElement, api } from 'lwc';

export default class ViewItem extends LightningElement {
    @api item;
    @api season = '';

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

    // handleGenerate() {
    //     if(this.season === '') {
    //         alert('対象シーズンを選択してください。');
    //         return;
    //     }

    //     const event = new CustomEvent(
    //         'generate',
    //         {
    //             detail: {
    //                 category: this.item.MZ_Category__c.value,
    //                 subCategory: this.item.MZ_SubCategory__c.value,
    //                 colorId: this.item.MZ_Color__r.value.fields.Id.value,
    //                 designType: this.item.MZ_Design__r.value.fields.MZ_DesignType__c.value,
    //                 season: this.season,
    //                 style: this.item.MZ_Style__c.value
    //             }
    //         }
    //     );
    //     this.dispatchEvent(event);
    // }
}