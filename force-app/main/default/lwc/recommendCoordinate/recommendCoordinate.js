import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import generateCoordinates from '@salesforce/apex/ItemController.generateCoordinates'
import createMyCoordinates from '@salesforce/apex/ItemController.createMyCoordinates';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CATEGORY_FIELD from '@salesforce/schema/MZ_Item__c.MZ_Category__c';
import SUBCATEGORY_FIELD from '@salesforce/schema/MZ_Item__c.MZ_SubCategory__c';
import SEASON_FIELD from '@salesforce/schema/MZ_Item__c.MZ_Season__c';
import COLORID_FIELD from '@salesforce/schema/MZ_Item__c.MZ_Color__r.Id';
import DESIGNTYPE_FIELD from '@salesforce/schema/MZ_Item__c.MZ_Design__r.MZ_DesignType__c';
import STYLE_FIELD from '@salesforce/schema/MZ_Item__c.MZ_Style__c';
import URL_FIELD from '@salesforce/schema/MZ_Item__c.MZ_ItemURL__c';
const FIELDS = [CATEGORY_FIELD, SUBCATEGORY_FIELD, COLORID_FIELD, DESIGNTYPE_FIELD, SEASON_FIELD, STYLE_FIELD, URL_FIELD];

export default class RecommendCoordinate extends LightningElement {
    recordId;
    season;
    selectedSeason;
    isLoading = false;
    recommendCoordinates;
    myCoordinates = [];
 
    @wire(CurrentPageReference)
    getPageReference(pageRef) {
        if (pageRef) {
            this.recordId = pageRef.state.c__recordId;
        }
    }

    @wire(getRecord, {recordId: '$recordId', fields: FIELDS})
    item;

    @wire(generateCoordinates, {
        itemId: '$recordId',
        season: '$season'
    })
    wiredCoordinates({data, error}) {
        if (data) {
            this.recommendCoordinates = data;
        } else if (error) {
            this.recommendCoordinates = undefined;
            console.log('wiredCoordinates error: ' + error.message);
        } 
        this.isLoading = false;
    }

    handleSelectItem(event) {
        this.selectedSeason = event.detail.season;
    }

    handleGenerate(event) {
        this.season = this.selectedSeason;
        this.isLoading = true;
    }

    handleCheck(event) {
        this.myCoordinates.push(event.detail.myCoordinate);
        console.log('handleCheck call');
        console.log('this.myCoordinates: '+ JSON.stringify(this.myCoordinates));
    }
    
    handleUncheck(event) {
        let index = this.myCoordinates.indexOf(event.detail.myCoordinate);
        if (index > -1) {
            this.myCoordinates.splice(index, 1);
            console.log('handleUncheck call');
            console.log('this.myCoordinates: '+ JSON.stringify(this.myCoordinates));
        }
    }

    async handleCreateMyCoordinates() {
        console.log('handleCreateMyCoordinates call');
        console.log('this.myCoordinates: '+ JSON.stringify(this.myCoordinates));
        const coordinateComp = this.template.querySelectorAll('c-coordinate')

        if(this.myCoordinates.length == 0) {
            alert('登録対象コーデを選択してください。');
            return;
        }

        try {
            await createMyCoordinates({myCoordinates: this.myCoordinates});
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'マイコーデに登録されました',
                    variant: 'success'
                })
            );
            coordinateComp.forEach((child) => {
                child.isChecked = false;
            });
            this.myCoordinates = [];
        } catch(error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'マイコーデの登録に失敗しました: ' + error.body.message,
                    variant: 'error'
                })
            );
        }
    }
}