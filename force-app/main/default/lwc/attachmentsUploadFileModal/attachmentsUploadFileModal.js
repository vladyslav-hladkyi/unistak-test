import { api, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import TYPE_FIELD from "@salesforce/schema/ContentVersion.Type__c";

export default class AttachmentsUploadFileModal extends LightningModal {
    @api content;
    uploadedFiles = [];
    options = [];
    selectedType = '';

    @wire(getPicklistValues, { fieldApiName: TYPE_FIELD, recordTypeId: '012000000000000AAA'})
    picklistResults({ error, data }) {
        if (data) {
            this.options = data.values;
        }
        else{
            this.options = [];
            console.log(error);
        }
    }

    // for future improvements
    handleClose() {
        this.close(this.uploadedFiles);
    }

    handleTypeChange(event){
        this.selectedType = event.detail.value;
    }

    handleUploadFinished(event){
        this.uploadedFiles.push(...event.detail.files.map(file => {
            return {type: this.selectedType, fileId: file.contentVersionId}
        }));

        this.close(this.uploadedFiles);
    }

    get isDisabled() {
        return this.selectedType == '' ? true : false;
    }
}