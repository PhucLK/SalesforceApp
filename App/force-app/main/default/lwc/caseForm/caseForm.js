import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createCase from '@salesforce/apex/CaseFormController.createCase';

export default class CaseForm extends LightningElement {
    @track subject;
    @track description;
    @track priority;
    priorityOptions = [
        { label: 'High', value: 'High' },
        { label: 'Medium', value: 'Medium' },
        { label: 'Low', value: 'Low' }
    ];

    handleSubjectChange(event) {
        this.subject = event.target.value;
    }

    handleDescriptionChange(event) {
        this.description = event.target.value;
    }

    handlePriorityChange(event) {
        this.priority = event.detail.value;
    }

    createCase() {
        // Check if required fields are filled
        if (!this.subject || !this.description || !this.priority) {
            this.showToast('Error', 'Please fill in all required fields.', 'error');
            return;
        }

        // Call Apex method to create Case record
        createCase({ subject: this.subject, description: this.description, priority: this.priority })
            .then(result => {
                // Handle success
                console.log('Case created:', result);
                this.showToast('Success', 'Case created successfully.', 'success');
            })
            .catch(error => {
                // Handle error
                console.error('Error creating Case:', error);
                this.showToast('Error', 'An error occurred while creating the Case.', 'error');
            });
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}
