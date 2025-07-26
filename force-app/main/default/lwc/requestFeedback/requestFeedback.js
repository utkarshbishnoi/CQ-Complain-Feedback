import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import requestFeedbackApex from '@salesforce/apex/ComplaintFeedbackService.requestFeedback';
import checkFeedbackExists from '@salesforce/apex/ComplaintFeedbackService.checkFeedbackExists';

export default class RequestFeedback extends LightningElement {
    @api recordId;
    isProcessing = false;
    error;
    feedbackAlreadyRequested = false;

    @wire(checkFeedbackExists, { complaintId: '$recordId' })
    wiredFeedbackStatus({ data, error }) {
        if (data !== undefined) {
            this.feedbackAlreadyRequested = data;
        }
        if (error) {
            this.error = error.body ? error.body.message : error.message;
        }
    }

    handleClick() {
        if (this.feedbackAlreadyRequested) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Info',
                    message: 'Feedback has already been requested for this complaint.',
                    variant: 'info'
                })
            );
            return;
        }

        this.isProcessing = true;

        requestFeedbackApex({ complaintId: this.recordId })
            .then(() => {
                this.isProcessing = false;
                this.feedbackAlreadyRequested = true;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Feedback request sent successfully.',
                        variant: 'success'
                    })
                );
            })
            .catch((error) => {
                this.isProcessing = false;
                this.error = error.body ? error.body.message : error.message;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: this.error,
                        variant: 'error'
                    })
                );
            });
    }
}