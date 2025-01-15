import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
// import { subscribe, MessageContext } from 'lightning/messageService';
// import ITEM_MESSAGE_CHANNEL from '@salesforce/messageChannel/ItemMessageChannel__c';
import { getRecord } from 'lightning/uiRecordApi';
import generateCoordinates from '@salesforce/apex/ItemController.generateCoordinates'
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
    // item;
    category;
    subCategory;
    colorId;
    designType;
    season;
    style;
 
    @wire(CurrentPageReference)
    getPageReference(pageRef) {
        console.log('[DEBUG] getPageReference call');
        if (pageRef) {
            console.log('[DEBUG] pageRef: ' + JSON.stringify(pageRef));
            console.log('[DEBUG] pageRef.state.recordId: ' + pageRef.state.c__recordId);
            this.recordId = pageRef.state.c__recordId;
            console.log('[DEBUG] recordId: ' + this.recordId);
        }
    }

    @wire(getRecord, {recordId: '$recordId', fields: FIELDS})
    item;
    // wiredItem({data, error}) {
    //     if(data) {
    //         console.log('[DEBUG] getRecord data: ' + JSON.stringify(data));
    //         this.item = data;
    //     } else if(error) {
    //         console.log('[DEBUG] getRecord error: ' + JSON.stringify(error));
    //         this.item = null;
    //     }
    // }

    // コーデパターンを生成するApexを呼び出し
    @wire(generateCoordinates, {
        recordId: '$recordId',
        season: '$season'
    })
    recommendCoordinates;

    handleGenerate(event) {
        console.log('[DEBUG] recommendCoordinate handleGenerate call');
        this.category = event.detail.category;
        this.subCategory = event.detail.subCategory;
        this.colorId = event.detail.colorId;
        this.designType = event.detail.designType;
        this.season = event.detail.season;
        this.style = event.detail.style;
        
        console.log(
            '[DEBUG] category: ' + this.category + ', subCategory: ' + this.subCategory + ', colorId: ' + this.colorId +
            ', designType: ' + this.designType + ', season: ' + this.season + ', style: ' + this.style
        );
    }
}