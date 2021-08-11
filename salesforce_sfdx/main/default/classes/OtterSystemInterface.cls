/***************************************************************************************************************
* @description custom extension of a default order management integration adapter for sync communication mode 
*/

global virtual class OtterSystemInterface extends vlocity_cmt.DefaultSystemInterface {
    global OtterSystemInterface() {
        
    }
    
    /***************************************************************************************************************
    * @description invokes default request generation logic and then stores generated request payload into a field
    * @param 
    * @return request payload 
    * @example
    *
    *   invoked by Vlocity XOM, not invoked directly
    */

    global override virtual String generatePayload(vlocity_cmt__OrchestrationItem__c item, vlocity_cmt.XOMOrderDomainObject orderObj) {
        
        String request = super.generatePayload(item, orderObj);
        item.vlocity_cmt__Request__c = request;
        
        return request;
    }

    /***************************************************************************************************************
    * @description invokes default response processing logic and then stores received payload into a field
    * @param 
    * @return nothing
    * @example
    *
    *   invoked by Vlocity XOM, not invoked directly
    */
    
    global override virtual void processResponse(
        vlocity_cmt__OrchestrationItem__c item,
        String url,
        String path,
        vlocity_cmt.XOMOrderDomainObject orderObj,
        HttpResponse resp) {

        //extension: log the timestamp of receiveing a sync-response
        //item.Callout_Response_Sync_Received__c = datetime.now();

        //extension: add supporting information to the response to facilitate response processing business logic
        String responseBody = resp.getBody();
        Map<String, Object> responseObj = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        responseObj.put('orchestrationItemId', item.Id);
        responseObj.put('orchestrationPlanId', orderObj.getOrchestrationPlanId());

        String orchestrationPlanSourceEntityType = orderObj.getObjectType().getDescribe().getLabel();
        responseObj.put('orchestrationPlanSourceEntityType', orchestrationPlanSourceEntityType);

        if (orchestrationPlanSourceEntityType == 'Order') {
            responseObj.put('orderId', orderObj.getId());
        } else {
            //this is executed if orchestrationPlanSourceEntityType is Fulfilment Request
            responseObj.put('fulfilmentRequestId', orderObj.getId());
        }

        resp.setBody(JSON.serialize(responseObj));

        super.processResponse(item, url, path, orderObj, resp);
        
        String response = resp.getBody();
        item.vlocity_cmt__Response__c = response;

        /* additional error processing business logic */
        /*
        if (errorCodeFound) {
            throw new DefaultInterfaceUnrecoverableException (errorDesc);
        }
        */
    }

    global override virtual void executeItem(
        String url, 
        String path, 
        vlocity_cmt__OrchestrationItem__c item) {
        super.executeItem(url, path, item);
        //item.Callout_Request_Issued__c = datetime.now();
    }
}