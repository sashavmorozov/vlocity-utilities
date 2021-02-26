@RestResource(UrlMapping = '/customAsyncCallback/*')

global with sharing class XOMAsyncResponseRESTServiceTemplate {

    /**
     * Contains business logic to be executed upon receiving a callback message. 
     * Sample implmenetation looks up a corresponding running callout and completes it.
     * Extend with the business logic to fit your requirements
     *
     * @return {void} - nothing
     *
     * @example
     *     //not called explicitly, invoked automatically by Salesforce platform
     */

    @HttpPost
    global static void processCallback() {
        RestRequest req = RestContext.request;
        String orchItemId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);

        //retrieve OrchestrationItem with additional paramters that may be needed to execute the business logic
        List <vlocity_cmt__OrchestrationItem__c> items = [
            SELECT 
                vlocity_cmt__State__c,
                vlocity_cmt__ResponseVlocityDataRaptorBundleId__r.Name,
                vlocity_cmt__ResponseItemsVlocityDataRaptorBundleId__r.Name,
                vlocity_cmt__ResponseAttrsVlocityDataRaptorBundleId__r.Name,
                vlocity_cmt__AttributesEncodingStyle__c,
                vlocity_cmt__OrderItemsNodeName__c,
                vlocity_cmt__OrchestrationItemDefinitionId__r.vlocity_cmt__CustomTaskExecutionURL__c,
                vlocity_cmt__OrderItemId__r.OrderId,
                vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__FulfilmentRequestID__c
            FROM 
                vlocity_cmt__OrchestrationItem__c
            WHERE 
                Id =: orchItemId 
                AND vlocity_cmt__State__c = 'Running'
        ];

        //if found
        if (items.size() == 1) {
            vlocity_cmt__OrchestrationItem__c item = items[0];

            //add custom callback processing logic section


            //update orchestration Item state to completed
            item.vlocity_cmt__State__c = 'Completed';
            update item;

            // commit
            // so we can save any changes happen to OrderDomainObject/OrderItemDomainObjects in processResponseDeferred
            vlocity_cmt.XOMObjectFactory.commitObjs();
        } else {
            //skip
            System.debug(LoggingLevel.ERROR, 'Skipping request for orchestration item ' + orchItemId +
                ': No running item is found');
        }

    }

}