import { LightningElement} from "lwc";
import getFeedbackDetails from "@salesforce/apex/FeedbackFormService.getFeedbackRecord";   
import submitFeedbackForm from "@salesforce/apex/FeedbackFormService.submitFeedback";

export default class FeedbackForm extends LightningElement{
    complaintId;
    feedbackId;
    experience = '';
    resolved = '';
    comment = '';
    isLoaded = false;
    isSubmitted = false;
    error;
    complaintNumber = '';
    complaintTitle = '';

    experienceOptions = [
        { label: '1 - Highly Unsatisfied', value: '1 - Highly Unsatisfied' },
        { label: '2 - Satisfied', value: '2 - Satisfied' },
        { label: '3 - Highly Satisfied', value: '3 - Highly Satisfied' }
    ];
    resolvedOptions = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' }
    ];
    
    connectedCallback(){
        const feedbackId = this.getUrlParam('id');
        //const urlParams = new URLSearchParams(window.location.search);
        //this.feedbackId = urlParams.get('id');

        if(feedbackId){
            getFeedbackDetails({ feedbackId})
                .then(result => {
                    this.complaintId = result.CQ_SQX_Related_To__c;
                    this.complaintNumber = result.CQ_SQX_Related_To__r?.Name;
                    this.complaintTitle = result.CQ_SQX_Related_To__r?.CQ_Title__c;
                    this.feedbackId = feedbackId;
                    this.isLoaded = true;
                })
                .catch(error => {
                    this.error = 'Invalid or Expired Feedback Link';  
                });
        } else {
            this.error = 'Feedback ID is missing in the URL.';
        }
    }
    getUrlParam(param){
        const url = new URL(window.location.href);
        return url.searchParams.get(param);
    }

    handleChange(event) {
        const {name,value} = event.target;
        this[name] = value;
    }
    submitFeedbackForm(){
        submitFeedbackForm({
            feedbackId: this.feedbackId,
            experience: this.experience,
            resolved: this.resolved,
            comment: this.comment
        })
        .then(() => {
            this.isSubmitted = true;
            this.isLoaded = false;
        })
        .catch(error => {
            this.error = 'Error submitting feedback: ';
        });
    }
}