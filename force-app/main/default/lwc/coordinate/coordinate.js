import { LightningElement, api } from 'lwc';

export default class Coordinate extends LightningElement {
    @api coordinate;
    @api isChecked = false;
    myCoordinates = [];

    get outerImage() {
        const itemURL = this.coordinate.MZ_Outer__r.MZ_ItemURL__c != null ? this.coordinate.MZ_Outer__r.MZ_ItemURL__c : this.coordinate.MZ_Outer__r.MZ_ItemURLText__c;
        return `
            background-image: url('${itemURL}'); 
            background-size: cover; 
            background-position: center;
            aspect-ratio: 1;
        `;
    }

    get topsImage() {
        const itemURL = this.coordinate.MZ_Tops__r.MZ_ItemURL__c != null ? this.coordinate.MZ_Tops__r.MZ_ItemURL__c : this.coordinate.MZ_Tops__r.MZ_ItemURLText__c;
        return `
            background-image: url('${itemURL}'); 
            background-size: cover; 
            background-position: center;
            aspect-ratio: 1;
        `;
    }

    get innerImage() {
        const itemURL = this.coordinate.MZ_Inner__r.MZ_ItemURL__c != null ? this.coordinate.MZ_Inner__r.MZ_ItemURL__c : this.coordinate.MZ_Inner__r.MZ_ItemURLText__c;
        return `
            background-image: url('${itemURL}'); 
            background-size: cover; 
            background-position: center;
            aspect-ratio: 1;
        `;
    }

    get bottomsImage() {
        const itemURL = this.coordinate.MZ_Bottoms__r.MZ_ItemURL__c != null ? this.coordinate.MZ_Bottoms__r.MZ_ItemURL__c : this.coordinate.MZ_Bottoms__r.MZ_ItemURLText__c;
        return `
            background-image: url('${itemURL}'); 
            background-size: cover; 
            background-position: center;
            aspect-ratio: 1;
        `;
    }

    get shoesImage() {
        const itemURL = this.coordinate.MZ_Shoes__r.MZ_ItemURL__c != null ? this.coordinate.MZ_Shoes__r.MZ_ItemURL__c : this.coordinate.MZ_Shoes__r.MZ_ItemURLText__c;
        return `
            background-image: url('${itemURL}'); 
            background-size: cover; 
            background-position: center;
            aspect-ratio: 1;
        `;
    }

    handleCheckboxChange(event) {
        this.isChecked = event.target.checked;
        const eventName = this.isChecked ? 'check' : 'uncheck'
        console.log('handleCheckboxChange call');
        console.log(event.target.checked);
        console.log(event.target.name);
        const ce = new CustomEvent(
            eventName,
            {
                detail: {
                    myCoordinate: event.target.name
                }
            }

        );
        this.dispatchEvent(ce);
    }
}