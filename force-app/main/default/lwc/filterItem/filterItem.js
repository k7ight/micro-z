import { LightningElement, wire, api } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import ITEM_OBJECT from '@salesforce/schema/MZ_Item__c';
import COLOR_OBJECT from '@salesforce/schema/MZ_Color__c';
import DESIGN_OBJECT from '@salesforce/schema/MZ_Design__c';
import SUBCATEGORY_FIELD from '@salesforce/schema/MZ_Item__c.MZ_SubCategory__c';
import SEASON_FIELD from '@salesforce/schema/MZ_Item__c.MZ_Season__c';
import COLORGROUP_FIELD from '@salesforce/schema/MZ_Color__c.MZ_ColorGroup__c';
import DESIGNTYPE_FIELD from '@salesforce/schema/MZ_Design__c.MZ_DesignType__c';

export default class FilterItem extends LightningElement {

    category = '';
    subCategory = '';
    colorGroup = '';
    designType = '';
    season = '';
    searchKey = '';
    categoryMap = '';
    
    // デフォルトレコードタイプID（マスタ）を取得
    @wire(getObjectInfo, {objectApiName: ITEM_OBJECT})
    itemInfo;

    // カテゴリ・サブカテゴリを取得
    @wire(getPicklistValues, {recordTypeId: '$itemInfo.data.defaultRecordTypeId', fieldApiName: SUBCATEGORY_FIELD})
    subCategories;

    // シーズンを取得
    @wire(getPicklistValues, {recordTypeId: '$itemInfo.data.defaultRecordTypeId', fieldApiName: SEASON_FIELD})
    seasonOptions;

    // カラーオブジェクト情報を取得し、カラーグループリストを取得
    @wire(getObjectInfo, {objectApiName: COLOR_OBJECT})
    colorInfo;
    @wire(getPicklistValues, {recordTypeId: '$colorInfo.data.defaultRecordTypeId', fieldApiName: COLORGROUP_FIELD})
    colorGroupOptions;

    // デザインオブジェクト情報を取得し、デザイン区分を取得
    @wire(getObjectInfo, {objectApiName: DESIGN_OBJECT})
    designInfo;
    @wire(getPicklistValues, {recordTypeId: '$designInfo.data.defaultRecordTypeId', fieldApiName: DESIGNTYPE_FIELD})
    designTypeOptions;   

    get categoryOptions() {
        // console.log('[DEBUG] categoryOptions call');
        if(this.subCategories.data != undefined) {
            // （category名、通番）のマップ情報を取得
            this.categoryMap = this.subCategories.data.controllerValues;
            // category名のリストを取得し、option形式に変換
            return Object.keys(this.categoryMap).map(key => ({   
                label: key,
                value: key
            }));
        } else {
            return null;
        }
    }

    // プロパティ（category）が変更されるたびに実行
    get subCategoryOptions() {
        // console.log('[DEBUG] subCategoryOptions call');
        if(this.subCategories.data != undefined) {
            // 全subCategoryの選択リスト値を取得し、allSubCategoriesへ格納
            const allSubCategories = this.subCategories.data.values;
            // 選択されたcategoryに連動するsubCategory情報を取得
            const filteredsubCategories = allSubCategories.filter(ele => {
                return ele.validFor.includes(this.categoryMap[this.category]);    // ★文字列→数値に変換して渡せば良いので、categoryMap[this.category]とする、そのためにcategoryMapはグローバルで定義
            });
            // options形式に変換
            return filteredsubCategories.map(ele => ({ label: ele.value, value: ele.value }));
        } else {
            return null;
        }
    }

    handleSearchKeyChange(event) {
        this.searchKey = event.detail.value;
        this.handleFilterSet();
    }
    handleCategoryChange(event) {
        // console.log('[DEBUG] handleCategoryChange call');
        this.category = event.detail.value;
        this.handleFilterSet();

        // console.log('[DEBUG] category=' + this.category);
    }
    handleSubCategoryChange(event) {
        this.subCategory = event.detail.value;
        this.handleFilterSet();
    }
    handleColorGroupChange(event) {
        this.colorGroup = event.detail.value;
        this.handleFilterSet();
    }
    handleDesignTypeChange(event) {
        this.designType = event.detail.value;
        this.handleFilterSet();
    }
    handleSeasonChange(event) {
        this.season = event.detail.value;
        this.handleFilterSet();
    }
    handleFilterSet() {
        // console.log('[DEBUG] filterItem handleFilterSet call');
        // console.log('[DEBUG] category, subCategory, colorGroup, designType, season, searchKey: '
        //     + this.category + ',' + this.subCategory + ',' + this.colorGroup + ',' + this.designType + ','
        //     + this.season +  ',' + this.searchKey);
        const event = new CustomEvent(
            'filterset',
            {
                detail: {
                    category: this.category,
                    subCategory: this.subCategory,
                    colorGroup: this.colorGroup,
                    designType: this.designType,
                    season: this.season,
                    searchKey: this.searchKey
                }
            }
        );
        this.dispatchEvent(event);
    }

    handleFilterClear() {
        // console.log('[DEBUG] filterItem handleFilterClear call');
        this.category = '';
        this.subCategory = '';
        this.colorGroup = '';
        this.designType = '';
        this.season = '';
        this.searchKey = '';
        const event = new CustomEvent('filterclear');
        this.dispatchEvent(event);
    }
}