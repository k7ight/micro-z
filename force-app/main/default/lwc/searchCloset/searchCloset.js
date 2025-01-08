import { LightningElement, wire } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import ITEM_OBJECT from '@salesforce/schema/MZ_Item__c';
import COLOR_OBJECT from '@salesforce/schema/MZ_Color__c';
import DESIGN_OBJECT from '@salesforce/schema/MZ_Design__c';
// import ITEM_CATEGORY_FIELD from '@salesforce/schema/MZ_Item__c.MZ_Category__c';
import ITEM_SUBCATEGORY_FIELD from '@salesforce/schema/MZ_Item__c.MZ_SubCategory__c';
import ITEM_SEASON_FIELD from '@salesforce/schema/MZ_Item__c.MZ_Season__c';
import COLOR_COLORGROUP_FIELD from '@salesforce/schema/MZ_Color__c.MZ_ColorGroup__c';
import DESIGN_DESIGNTYPE_FIELD from '@salesforce/schema/MZ_Design__c.MZ_DesignType__c';


export default class SearchCloset extends LightningElement {

    recordTypeId = '';
    searchKey = '';
    category = '';
    category_num = '';
    subCategory = '';
    colorGroup = '';
    designType = '';
    season = '';

    // アイテムオブジェクトのマスタレコードタイプを取得
    @wire(getObjectInfo, {objectApiName: ITEM_OBJECT})
    itemObjectInfo({data, error}) {
        if(data) {
            const rtis = data.recordTypeInfos;
            this.recordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === '00_マスタ');
            this.subRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === '');
        } else if(error) {
            console.log('getObjectInfo error');
        } 
    }
    // サブカテゴリリストを項目連動関係を含めて取得
    @wire(getPicklistValues, {recordTypeId:'$recordTypeId', fieldApiName: ITEM_SUBCATEGORY_FIELD})
    subCategoryList;
    // シーズンリストを取得
    @wire(getPicklistValues, {recordTypeId:'$recordTypeId', fieldApiName: ITEM_SEASON_FIELD})
    seasonOptions;


    // カラーオブジェクト情報を取得し、カラーグループリストを取得
    @wire(getObjectInfo, {objectApiName: COLOR_OBJECT})
    colorObjectInfo;
    @wire(getPicklistValues, {recordTypeId: '$colorObjectInfo.data.defaultRecordTypeId', fieldApiName: COLOR_COLORGROUP_FIELD})
    colorGroupOptions;

    // デザインオブジェクト情報を取得し、デザイン区分を取得
    @wire(getObjectInfo, {objectApiName: DESIGN_OBJECT})
    designObjectInfo;
    @wire(getPicklistValues, {recordTypeId: '$designObjectInfo.data.defaultRecordTypeId', fieldApiName: DESIGN_DESIGNTYPE_FIELD})
    designTypeOptions;   
    



    get categoryOptions() {
        if(this.subCategoryList.data != undefined){
            const values = this.subCategoryList.data.controllerValues;
            let list = [];
            for(let key in values){
                let result = {label: key, value: String(values[key])}
                list.push(result);
            }
            return list;
        }else{
            return null;
        }
    }

    get subCategoryOptions() {
        console.log('get subCategoryOptions() call');
        if(this.subCategoryList.data != undefined){
            const values = this.subCategoryList.data.values;
            const filterValues = values.filter(ele => {
                return ele.validFor[0] == this.category;
            })
            let list = [];
            for(let i = 0; i < filterValues.length; i++){
                let result = { label: filterValues[i].value, value: filterValues[i].value }
                list.push(result);
            }
            return list;
        }else{
            return null;
        }
    }

    handleSearchKeyChange(event) {
        this.searchKey = event.detail.value;
    }
    handleCategoryChange(event) {
        this.category = Number(event.detail.value);
    }
    handleSubCategoryChange(event) {
        this.subCategory = event.detail.value;
    }
    handleColorGroupChange(event) {
        this.colorGroup = event.detail.value;
    }
    handleDesignTypeChange(event) {
        this.designType = event.detail.value;
    }
    handleSeasonChange(event) {
        this.season = event.detail.value;
    }
}