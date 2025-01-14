import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import getItems from '@salesforce/apex/ItemController.getItems';
import ItemModal from 'c/itemModal';
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

    // isModalVisible = false;
    // item = '';


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

    // 非同期ロジック
    async handleOpenModal(event) {
        console.log('[DEBUG] handleOpenModal call');
        const result = await ItemModal.open({
            size: 'small',
            item: event.detail,
            onnavigate: (e) => {
                console.log('[DEBUG] onnavigate: ' + JSON.stringify(e.detail));
                this[NavigationMixin.Navigate](e.detail);
            }
        });
    }
    // // 子コンポーネント呼び出しロジック
    // handleOpenModal(event) {
    //     this.isModalVisible = true;
    //     this.item = event.detail;
    // }

    handleSortKeyChange(event) {
        const sortCondition = JSON.parse(event.detail.value);
        this.sortKey = sortCondition.key;
        this.sortOrder = sortCondition.order;
        // console.log('[DEBUG] sortKey: ' + this.sortKey + ', sortOrder: ' + this.sortOrder);
    }

    handleFilterSet(event) {
        // console.log('[DEBUG] itemList handleFilterSet call');
        this.category = event.detail.category;
        this.subCategory = event.detail.subCategory;
        this.colorGroup = event.detail.colorGroup;
        this.designType = event.detail.designType;
        this.season = event.detail.season;
        this.searchKey = event.detail.searchKey;
        // console.log('[DEBUG] category, subCategory, colorGroup, designType, season, searchKey: '
        //     + this.category + ',' + this.subCategory + ',' + this.colorGroup + ',' + this.designType + ','
        //     + this.season +  ',' + this.searchKey);
    }

    handleFilterClear() {
        // console.log('[DEBUG] itemList handleFilterClear call');
        this.category = '';
        this.subCategory = '';
        this.colorGroup = '';
        this.designType = '';
        this.season = '';
        this.searchKey = '';
    }

    handleCreateItem() {
        const flowApiName = 'MZ_FL_CreateItem'; // フローのAPI名を指定
        const retUrl = 'lightning/n/MZ_SearchItem_Tab'; // フロー終了後の遷移先URL
        const flowUrl = `/flow/${flowApiName}?retURL=${retUrl}`; // フローのURLを構築
        window.location.href = flowUrl; // 画面遷移
    }

}