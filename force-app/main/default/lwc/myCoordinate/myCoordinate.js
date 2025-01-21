import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import getMyCoordinates from '@salesforce/apex/ItemController.getMyCoordinates'
import deleteMyCoordinates from '@salesforce/apex/ItemController.deleteMyCoordinates';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CATEGORY_FIELD from '@salesforce/schema/MZ_Item__c.MZ_Category__c';
import SUBCATEGORY_FIELD from '@salesforce/schema/MZ_Item__c.MZ_SubCategory__c';
import SEASON_FIELD from '@salesforce/schema/MZ_Item__c.MZ_Season__c';
import COLORID_FIELD from '@salesforce/schema/MZ_Item__c.MZ_Color__r.Id';
import DESIGNTYPE_FIELD from '@salesforce/schema/MZ_Item__c.MZ_Design__r.MZ_DesignType__c';
import STYLE_FIELD from '@salesforce/schema/MZ_Item__c.MZ_Style__c';
import URL_FIELD from '@salesforce/schema/MZ_Item__c.MZ_ItemURL__c';
const FIELDS = [CATEGORY_FIELD, SUBCATEGORY_FIELD, COLORID_FIELD, DESIGNTYPE_FIELD, SEASON_FIELD, STYLE_FIELD, URL_FIELD];

export default class MyCoordinate extends NavigationMixin(LightningElement) {
    recordId;
    season;
    selectedCoordinates = [];
 
    @wire(CurrentPageReference)
    getPageReference(pageRef) {
        if (pageRef) {
            this.recordId = pageRef.state.c__recordId;
            this.season = '';
        }
    }

    @wire(getRecord, {recordId: '$recordId', fields: FIELDS})
    item;

    @wire(getMyCoordinates, {
        itemId: '$recordId',
        season: '$season'
    })
    myCoordinates;

    handleSelectItem(event) {
        this.season = event.detail.season;
    }

    handleCheck(event) {
        this.selectedCoordinates.push(event.detail.myCoordinate);
        console.log('handleCheck call');
        console.log('this.selectedCoordinates: '+ JSON.stringify(this.selectedCoordinates));
    }
    
    handleUncheck(event) {
        let index = this.selectedCoordinates.indexOf(event.detail.myCoordinate);
        if (index > -1) {
            this.selectedCoordinates.splice(index, 1);
            console.log('handleUncheck call');
            console.log('this.selectedCoordinates: '+ JSON.stringify(this.selectedCoordinates));
        }
    }

    async handleDeleteMyCoordinates() {
        console.log('handleDeleteMyCoordinates call');
        console.log('this.selectedCoordinates: '+ JSON.stringify(this.selectedCoordinates));
        // const coordinateComp = this.template.querySelectorAll('c-coordinate')

        if(this.selectedCoordinates.length == 0) {
            alert('削除対象コーデを選択してください。');
            return;
        }

        const dialog = window.confirm('選択したコーデの削除を実行しますか?');
        if (!dialog) {
            return;
        }

        try {
            await deleteMyCoordinates({myCoordinates: this.selectedCoordinates});
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'マイコーデが削除されました',
                    variant: 'success'
                })
            );
            // coordinateComp.forEach((child) => {
            //     child.isChecked = false;
            // });
            // this.selectedCoordinates = [];
            const retUrl = `lightning/n/MZ_MyCoordinate_Tab/?c__recordId=${this.recordId}`;
            setTimeout(() => { window.location.href = retUrl; }, 500);

        } catch(error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'マイコーデの削除に失敗しました: ' + error.body.message,
                    variant: 'error'
                })
            );
        }
    }

    handleTransitSearchItem() {
        const pageRef = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'MZ_SearchItem_Tab'
            }
        };
        this[NavigationMixin.Navigate](pageRef);
    }

    handleTransitRecommendCoordinate() {
        const pageRef = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'MZ_RecommendCoordinate_Tab'
            },
            state: {
                c__recordId: this.recordId
            }
        };
        this[NavigationMixin.Navigate](pageRef);
    }
}