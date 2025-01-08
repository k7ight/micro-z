import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ItemModal extends LightningModal {
    @api item;

    handleEditItem() {
        const recordId = this.item.Id;
        const Url = `/lightning/r/MZ_Item__c/${recordId}/view`;
        window.location.href = Url; // 画面遷移
    }

    handleDeleteItem() {
        const recordId = this.item.Id;
        await deleteRecord(recordId);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Account deleted',
                variant: 'success'
            })
        );
        await refreshApex(this.wiredAccountsResult);
    } catch (error) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error deleting record',
                message: reduceErrors(error).join(', '),
                variant: 'error'
            })
        );
    }
}