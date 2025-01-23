import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import getItems from '@salesforce/apex/ItemController.getItems';
import ItemModal from 'c/itemModal';
import ItemCreateModal from 'c/itemCreateModal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PURCHASEDATE_FIELD from '@salesforce/schema/MZ_Item__c.MZ_PurchaseDate__c';
import PURCHASEPRICE_FIELD from '@salesforce/schema/MZ_Item__c.MZ_PurchasePrice__c';

export default class ItemList extends NavigationMixin(LightningElement) {
    category = '';
    subCategory = '';
    colorGroup = '';
    designType = '';
    season = '';
    searchKey = '';
    sortKey = '';
    sortOrder = '';

    sortKeyOptions = [
        {label: '購入日昇順' , value: JSON.stringify({key: PURCHASEDATE_FIELD.fieldApiName, order: 'ASC'})},
        {label: '購入日降順' , value: JSON.stringify({key: PURCHASEDATE_FIELD.fieldApiName, order: 'DESC'})},
        {label: '購入価格昇順', value: JSON.stringify({key: PURCHASEPRICE_FIELD.fieldApiName, order: 'ASC'})},
        {label: '購入価格降順', value: JSON.stringify({key: PURCHASEPRICE_FIELD.fieldApiName, order: 'DESC'})}
    ];

    // 絞り込み条件に該当するitemを取得
    @wire(getItems, {
        category: '$category',
        subCategory: '$subCategory',
        colorGroup: '$colorGroup',
        designType: '$designType',
        season: '$season',
        searchKey: '$searchKey',
        sortKey: '$sortKey',
        sortOrder: '$sortOrder'
    })
    items;

    async handleOpenModal(event) {
        const result = await ItemModal.open({
            size: 'small',
            item: event.detail,
            onnavigate: (e) => {
                this[NavigationMixin.Navigate](e.detail);
            }
        });
    }

    async handleOpenItemCreateModal() {
        const result = await ItemCreateModal.open({
            size: 'large'
        });
        if(result == 'OK') {     
            const retUrl = '/lightning/n/MZ_SearchItem_Tab';      
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'アイテムが登録されました',
                    variant: 'success'
                })
            );
            setTimeout(() => { window.location.href = retUrl; }, 500);
        }
    }

    handleSortKeyChange(event) {
        const sortCondition = JSON.parse(event.detail.value);
        this.sortKey = sortCondition.key;
        this.sortOrder = sortCondition.order;
    }

    handleFilterSet(event) {
        this.category = event.detail.category;
        this.subCategory = event.detail.subCategory;
        this.colorGroup = event.detail.colorGroup;
        this.designType = event.detail.designType;
        this.season = event.detail.season;
        this.searchKey = event.detail.searchKey;
    }

    handleFilterClear() {
        this.category = '';
        this.subCategory = '';
        this.colorGroup = '';
        this.designType = '';
        this.season = '';
        this.searchKey = '';
    }

    // handleCreateItem() {
    //     const flowApiName = 'MZ_FL_CreateItem'; 
    //     const retUrl = '/lightning/n/MZ_SearchItem_Tab'; 
    //     const flowUrl = `/flow/${flowApiName}?retURL=${retUrl}`;
    //     window.location.href = flowUrl;
    // }
}