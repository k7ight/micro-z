import { LightningElement, api } from 'lwc';

export default class Coordinate extends LightningElement {
    @api coordinate;

    get outerImage() {
        // return `
        //     background-image: url('${this.coordinate.MZ_Outer__r.MZ_ItemURL__c}'); 
        //     background-size: cover; 
        //     background-position: center;
        //     aspect-ratio: 1;
        // `;
    }

    get topsImage() {
        // return `
        //     background-image: url('${this.coordinate.MZ_Tops__r.MZ_ItemURL__c}'); 
        //     background-size: cover; 
        //     background-position: center;
        //     aspect-ratio: 1;
        // `;
    }

    get innerImage() {
        // return `
        //     background-image: url('${this.coordinate.MZ_Inner__r.MZ_ItemURL__c}'); 
        //     background-size: cover; 
        //     background-position: center;
        //     aspect-ratio: 1;
        // `;
    }

    get bottomsImage() {
        // return `
        //     background-image: url('${this.coordinate.MZ_Bottoms__r.MZ_ItemURL__c}'); 
        //     background-size: cover; 
        //     background-position: center;
        //     aspect-ratio: 1;
        // `;
    }

    get shoesImage() {
        // return `
        //     background-image: url('${this.coordinate.MZ_Shoes__r.MZ_ItemURL__c}'); 
        //     background-size: cover; 
        //     background-position: center;
        //     aspect-ratio: 1;
        // `;
    }
}