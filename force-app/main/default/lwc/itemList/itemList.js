import { LightningElement, wire } from 'lwc';
import getItems from '@salesforce/apex/ItemController.getItems';
import ItemModal from 'c/itemModal';

export default class ItemList extends LightningElement {
    category = '';
    subCategory = '';
    colorGroup = '';
    designType = '';
    season = '';
    searchKey = '';

    // 絞り込み条件に該当するitemを取得
    @wire(getItems, {
        category: '$category',
        subCategory: '$subCategory',
        colorGroup: '$colorGroup',
        designType: '$designType',
        season: '$season',
        searchKey: '$searchKey'
    })
    items;

    async handleOpenModal(event) {
        const result = await ItemModal.open({
            size: 'small',
            item: event.detail
        });
    }

    handleFilterSet(event) {
        console.log('[DEBUG] itemList handleFilterSet call');
        this.category = event.detail.category;
        this.subCategory = event.detail.subCategory;
        this.colorGroup = event.detail.colorGroup;
        this.designType = event.detail.designType;
        this.season = event.detail.season;
        this.searchKey = event.detail.searchKey;
        console.log('[DEBUG] category, subCategory, colorGroup, designType, season, searchKey: '
            + this.category + ',' + this.subCategory + ',' + this.colorGroup + ',' + this.designType + ','
            + this.season +  ',' + this.searchKey);
    }

    handleFilterClear() {
        console.log('[DEBUG] itemList handleFilterClear call');
        this.category = '';
        this.subCategory = '';
        this.colorGroup = '';
        this.designType = '';
        this.season = '';
        this.searchKey = '';
    }

    handleCreateItem() {
        const flowApiName = 'MZ_FL_CreateItem';
        const retUrl = 'lightning/n/Tab';
        const flowUrl = `/flow/${flowApiName}?retURL=${retUrl}`; 
        window.location.href = flowUrl;
    }

}