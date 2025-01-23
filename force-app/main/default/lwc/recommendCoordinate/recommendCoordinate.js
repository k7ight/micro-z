import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import generateCoordinates from '@salesforce/apex/ItemController.generateCoordinates'
import createMyCoordinates from '@salesforce/apex/ItemController.createMyCoordinates';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ItemSelectModal from 'c/itemSelectModal';
import CATEGORY_FIELD from '@salesforce/schema/MZ_Item__c.MZ_Category__c';
import SUBCATEGORY_FIELD from '@salesforce/schema/MZ_Item__c.MZ_SubCategory__c';
import SEASON_FIELD from '@salesforce/schema/MZ_Item__c.MZ_Season__c';
import COLORID_FIELD from '@salesforce/schema/MZ_Item__c.MZ_Color__r.Id';
import DESIGNTYPE_FIELD from '@salesforce/schema/MZ_Item__c.MZ_Design__r.MZ_DesignType__c';
import STYLE_FIELD from '@salesforce/schema/MZ_Item__c.MZ_Style__c';
import URL_FIELD from '@salesforce/schema/MZ_Item__c.MZ_ItemURL__c';
const FIELDS = [CATEGORY_FIELD, SUBCATEGORY_FIELD, COLORID_FIELD, DESIGNTYPE_FIELD, SEASON_FIELD, STYLE_FIELD, URL_FIELD];

export default class RecommendCoordinate extends NavigationMixin(LightningElement) {
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
        if(this.selectedSeason == undefined) {
            alert('対象シーズンを選択してください。');
            return;
        }
        this.season = this.selectedSeason;
        this.isLoading = true;
    }

    handleCheck(event) {
        this.myCoordinates.push(event.detail.myCoordinate);
    }
    
    handleUncheck(event) {
        let index = this.myCoordinates.indexOf(event.detail.myCoordinate);
        if (index > -1) {
            this.myCoordinates.splice(index, 1);
        }
    }

    async handleCreateMyCoordinates() {
        const coordinateComp = this.template.querySelectorAll('c-coordinate')

        if(this.myCoordinates.length == 0) {
            alert('登録対象コーデを選択してください。');
            return;
        }

        try {
            const errors = await createMyCoordinates({myCoordinates: this.myCoordinates});
            if(errors.length > 0) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: errors.length + '件のマイコーデの登録に失敗しました: '  + errors.join(', '),
                        variant: 'error'
                    })
                );
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'マイコーデに登録されました',
                        variant: 'success'
                    })
                );
            }
            coordinateComp.forEach((child) => {
                child.isChecked = false;
            });
            this.myCoordinates = [];
        } catch(error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'マイコーデの登録中に問題が発生しました: ' + error.body.message,
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

    handleTransitMyCoordinate() {
        const pageRef = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'MZ_MyCoordinate_Tab'
            },
            state: {
                c__recordId: this.recordId
            }
        };
        this[NavigationMixin.Navigate](pageRef);
    }

    get noItem() {
        return `
            background-color: #EEEEEE;
            background-size: cover; 
            background-position: center;
            aspect-ratio: 1;
        `;
    }

    async handleOpenModal() {
        const result = await ItemSelectModal.open({
            size: 'large'
        });
        this.recordId = result;
    }
}