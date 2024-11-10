import { LightningElement, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

import getRelatedFiles from "@salesforce/apex/AttachmentsController.getRelatedFiles"

const actions = [
    { label: 'View File', name: 'view_file' }
];

const columns = [
    { label: 'Title', fieldName: 'title' },
    { label: 'Type', fieldName: 'type'},
    { label: 'File Extension', fieldName: 'extension'},
    { label: 'File Size', fieldName: 'size'},
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    }
];

export default class AttachmentsViewAll extends NavigationMixin(LightningElement) {
    @api parentRecordId;
    @api files = [];

    columns = columns;
    isLoading = false;

    handleRowAction(event){
        let actionName = event.detail.action.name;
        let row = event.detail.row;

        if(actionName == 'view_file'){
            this.previewFile(row.fileId);
        }
    }

    // better to use lightning message channel but I don't have so much time
    async handleRefreshComponent(){
        this.isLoading = true;

        try {
            this.files = await getRelatedFiles({recordId: this.parentRecordId});
        } catch (error) {
            this.files = [];
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error while retrieving related files",
                    message: error.body.message,
                    variant: "error"
                })
            );
        }

        this.isLoading = false;
    }

    previewFile(fileId){
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
              pageName: "filePreview",
            },
            state: {
              recordIds: fileId,
              selectedRecordId: fileId,
            },
        });
    }

    get areFilesPresent(){
        return this.files.length > 0 ? true : false;
    }
}