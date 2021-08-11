import tmpl from './fcaSaveForLaterAcknowledge.html';


import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import omniscriptSaveForLaterAcknowledge from 'vlocity_ins/omniscriptSaveForLaterAcknowledge';


const FIELDS = ['vlocity_ins__OmniScriptInstance__c.Save_and_Resume_URL__c'];

export default class fcaSaveForLaterAcknowledge extends omniscriptSaveForLaterAcknowledge {

    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    savedOmni;

    @api
    get resumeLink() {
        return getFieldValue(this.savedOmni.data, FIELDS[0]);        
    }
    
    @api
    get emailLink() {
        return `mailto:?subject=Continue your process&body=${getFieldValue(this.savedOmni.data, FIELDS[0])}`;
    }

    @api
    get result(){
        return super.result;
    }

    set result(e) {
        // console.log(JSON.parse(JSON.stringify(e))); // print to assess the result object
        if(e && e.value) {
            // create a clone to manipulate
            e = JSON.parse(JSON.stringify(e));
            if(e.value.saveUrl) {
                this.recordId = e.value.instanceId;
            }
        }
        super.result = e;
    }

    constructor() {
        super();
    }
 
    connectedCallback() {

    }

    render() {
        return tmpl;
    }
 
    
}