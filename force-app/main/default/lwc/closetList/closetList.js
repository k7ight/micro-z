import { LightningElement, api } from 'lwc';

export default class ClosetList extends LightningElement {
    /** Whether the tile is draggable. */
    @api draggable;

    _item;
    /** Product__c to display. */
    @api
    get item() {
        return this._item;
    }
    set item(value) {
        this._item = value;
        this.image = value.MZ_ItemImage__c;
        this.name = value.Name;
        this.price = value.MZ_PurchasePrice__c;
    }

    /** Product__c field values to display. */
    image;
    name;
    price;

    handleClick() {
        const selectedEvent = new CustomEvent('selected', {
            detail: this.item.Id
        });
        this.dispatchEvent(selectedEvent);
    }

    handleDragStart(event) {
        event.dataTransfer.setData('item', JSON.stringify(this.item));
    }
}
