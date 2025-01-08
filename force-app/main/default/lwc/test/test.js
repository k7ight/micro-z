import { LightningElement, wire } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import ITEM_OBJECT from '@salesforce/schema/MZ_Item__c';
import ITEM_CATEGORY_FIELD from '@salesforce/schema/MZ_Item__c.MZ_Category__c';

export default class RecordSearchLwc extends LightningElement {
    category = "";

    @wire(getObjectInfo, { objectApiName: ITEM_OBJECT })
    accountObjectInfo;

    @wire(getPicklistValues, { recordTypeId: '$accountObjectInfo.data.defaultRecordTypeId', fieldApiName: ITEM_CATEGORY_FIELD })
    industryOptions;

    handleCategoryChange(event) {
        this.category = event.detail.value;
    }
}