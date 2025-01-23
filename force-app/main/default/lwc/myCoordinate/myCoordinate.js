import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import getMyCoordinates from '@salesforce/apex/ItemController.getMyCoordinates'
import deleteMyCoordinates from '@salesforce/apex/ItemController.deleteMyCoordinates';
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

export default class MyCoordinate extends NavigationMixin(LightningElement) {
    recordId;
    season;
    selectedCoordinates = [];
    seasonOptions = [
        { label: '春', value: '春' },
        { label: '夏', value: '夏' },
        { label: '秋', value: '秋' },
        { label: '冬', value: '冬' }
    ];
 
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

    connectedCallback() {
        if(this.recordId == undefined) {
            this.recordId = '';
        }
    }

    get ExistMyCoordinates() {
        return this.myCoordinates.data && this.myCoordinates.data.length > 0;
    }

    handleSelectItem(event) {
        this.season = event.detail.season;
    }

    handleCheck(event) {
        this.selectedCoordinates.push(event.detail.myCoordinate);
    }
    
    handleUncheck(event) {
        let index = this.selectedCoordinates.indexOf(event.detail.myCoordinate);
        if (index > -1) {
            this.selectedCoordinates.splice(index, 1);
        }
    }

    async handleDeleteMyCoordinates() {
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

    handleItemClear() {
        this.recordId = '';
        this.item.data = undefined;
        this.season = '';
        this.template.querySelector('c-view-item').season = '';
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
        if(result != undefined) {
            this.recordId = result;
        } else {
            this.recordId = '';
        }
    }

    handleSeasonChange(event) {
        this.season = event.detail.value;
    }
}