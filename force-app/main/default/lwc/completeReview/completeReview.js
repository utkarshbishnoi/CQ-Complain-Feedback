import { LightningElement,api } from "lwc";
import completeFeedbackReview from "@salesforce/apex/CompleteReviewService.completeReview";


export default class CompleteReview extends LightningElement {
    @api recordId;
    resolution = '';
    isLoaded = true;
    isSubmitted = false;
    error;

    get resolutionOptions(){
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
        ];
    }

    handleChange(event) {
        this.resolution = event.detail.value;
    }

    completeReview() {
        this.error = null;

        if (!this.resolution) {
            this.error = 'Please select a resolution option.';
            return; 
        } 
        this.isLoaded = false;
        completeFeedbackReview({ feedbackId: this.recordId, resolution: this.resolution })
        .then(() => {
            this.isSubmitted = true;
            this.isLoaded = true;
        })
        .catch(error => {
            console.error('Apex error: ', error);
            this.error = error.body ? error.body.message : error.message;
            this.isLoaded = true;
        });
    }  
    get isDisabled() {
        return this.isSubmitted || !this.isLoaded;
    }      
}