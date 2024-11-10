import { LightningElement, wire, track, api } from 'lwc';
import {openSubtab, EnclosingTabId, getTabInfo, IsConsoleNavigation } from 'lightning/platformWorkspaceApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import { NavigationMixin } from "lightning/navigation";

import getRelatedFiles from "@salesforce/apex/AttachmentsController.getRelatedFiles"
import updateFileTypes from "@salesforce/apex/AttachmentsController.updateFileTypes"
import UploadFileModal from 'c/attachmentsUploadFileModal'

export default class AttachmentsRelatedList extends NavigationMixin(LightningElement) {
    @api recordId;
    @track files = [];
    primaryTabId;
    isLoading = true;

    @wire(EnclosingTabId) tabId;
    @wire(IsConsoleNavigation) isConsoleNavigation;

    async connectedCallback() {
        if(this.isConsoleNavigation){
            await this.invokeGetTabInfo();
        }

        await this.invokeGetRelatedFiles();
        this.isLoading = false;
    }

    handlePreviewFile(event){
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
              pageName: "filePreview",
            },
            state: {
              recordIds: event.target.dataset.id,
              selectedRecordId: event.target.dataset.id,
            },
        });
    }

    async handleRefreshComponent(){
        this.isLoading = true;

        await this.invokeGetRelatedFiles();
        this.dispatchEvent(new RefreshEvent());

        this.isLoading = false;
    }

    async handleUploadFile(){
        let result = await UploadFileModal.open({
            size: 'small',
            content: {recordId: this.recordId}
        });

        if(result.length == 0) { return;}

        this.isLoading = true;

        await updateFileTypes({files: result});
        await this.invokeGetRelatedFiles();
        this.dispatchEvent(new RefreshEvent());
        
        this.isLoading = false;
    }

    async handleOpenViewAll(){
        if(!this.isConsoleNavigation){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Please use Console Navigation",
                    message: "This functionality currently unavailable for standard navigation",
                    variant: "warning"
                })
            );
            return;
        }

        let cmpDef = {
            componentDef: "c:attachmentsViewAll",
            attributes:{
                files: this.files,
                parentRecordId: this.recordId
            }
        };
        let encodedDef = btoa(JSON.stringify(cmpDef));

        try {
            await openSubtab(
                this.primaryTabId, 
                {
                    url:"/one/one.app#" + encodedDef,
                    icon:'utility:file', 
                    label:'Notes & Attachments'
                }
            )
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error while opening subtab",
                    message: error.body.message,
                    variant: "error"
                })
            );
        }
    }

    async invokeGetRelatedFiles(){
        try {
            this.files = await getRelatedFiles({recordId: this.recordId});
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
    }

    async invokeGetTabInfo(){
        const tabInfo = await getTabInfo(this.tabId);
        this.primaryTabId = tabInfo.isSubtab ? tabInfo.parentTabId : tabInfo.tabId;
    }

    get firstSixFiles(){
        return this.files.slice(0, 6);
    }

    get areFilesPresent(){
        return this.files.length > 0 ? true : false;
    }

    get formattedCountOfAttachments(){
        if(this.files.length > 6) { return '(6+)'; }
        if(this.files.length == 0) { return ''; }

        return '(' + this.files.length.toString() +')';
    }
}