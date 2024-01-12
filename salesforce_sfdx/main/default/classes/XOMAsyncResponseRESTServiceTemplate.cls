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
		
        system.debug('*** RestContext.request.requestBody.toString(): ' + req.requestBody.toString());
        
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
            
        orchItemId = (String) responseBody.get('orchestration_item_id');
        system.debug('*** orchestration_item_id: ' + orchItemId);
        
        //retrieve OrchestrationItem with additional paramters that may be needed to execute the business logic
        List <vlocity_cmt__OrchestrationItem__c> items = [
            SELECT 
                Name,
                vlocity_cmt__State__c
            FROM 
                vlocity_cmt__OrchestrationItem__c
            WHERE 
                Id =: orchItemId 
                //AND vlocity_cmt__State__c = 'Running'
        ];

        system.debug('*** items: ' + items);
        //if orchestration item is found
        if (items.size() == 1) {
            vlocity_cmt__OrchestrationItem__c item = items[0];

            //add custom callback processing logic section. The template implementation includes only task completion action
			item.vlocity_cmt__State__c = 'Completed';                
            update item;

            // commit
            // so we can save any changes happen to OrderDomainObject/OrderItemDomainObjects in processResponseDeferred
            vlocity_cmt.XOMObjectFactory.commitObjs();
        } else {
            //skip if orchestration item is not found
            System.debug(LoggingLevel.ERROR, 'Skipping request for orchestration item ' + orchItemId + ': No running item is found');
        }

    }
    
}