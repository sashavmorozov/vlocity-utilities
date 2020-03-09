global with sharing class OtterCpqAppHandlerHook implements vlocity_cmt.VlocityOpenInterface {
    public static SObjectType lineItemTypeForPage;

    /**
     * VlocityOpenInterface's invokeMethod method to invoke additional business logic 
     *
     * @param {String>} methodName - Vlocity CPQ API method name with pre/post-indicator
     * @param {Map <String, Object>} inputMap - Vlocity CPQ API call input (cart ID, fields, etc.)
     * @param {Map <String, Object>} outputMap - Vlocity CPQ API call output (line items, attributes, etc.)
     * @param {Map <String, Object>} optionsMap - Additional options for Vlocity CPQ API call
     * @return {Boolean} - true (stub)
     *
     * @example
     *     Not invoked directly. The method is invoked by Vlocity platform 
    */

    global Boolean invokeMethod(string methodName, Map <String, Object> inputMap, Map <String, Object> outputMap, Map <String, Object> optionsMap) {

        //Invoking additional business logic right BEFORE Vlocity getCartsItems API (retrieve items) is invoked
        if (methodName == 'getCartsItems.PreInvoke') {
            getCartsItemsPreInvoke(inputMap, outputMap, optionsMap);
            return true;
        }
        
        //Invoking additional business logic right AFTER Vlocity getCartsItems API (retrieve items) is invoked (but before returning the output to the client)
        if (methodName == 'getCartsItems.PostInvoke') {
            getCartsItemsPostInvoke(inputMap, outputMap, optionsMap);
            return true;
        }

        //Invoking additional business logic right BEFORE Vlocity postCartsItems API (add item) is invoked
        if (methodName == 'postCartsItems.PreInvoke') {
            postCartsItemsPreInvoke(inputMap, outputMap, optionsMap);
            return true;
        }
        
        //Invoking additional business logic right AFTER Vlocity postCartsItems API (add item) is invoked (but before returning the output to the client)
        if (methodName == 'postCartsItems.PostInvoke') {
            postCartsItemsPostInvoke(inputMap, outputMap, optionsMap);
            return true;
        }

        //Invoking additional business logic right BEFORE Vlocity putCartsItems API (modify item) is invoked
        if (methodName == 'putCartsItems.PreInvoke') {
            putCartsItemsPreInvoke(inputMap, outputMap, optionsMap);
            return true;
        }
        
        //Invoking additional business logic right AFTER Vlocity postCartsItems API (modify item) is invoked (but before returning the output to the client)
        if (methodName == 'putCartsItems.PostInvoke') {
            putCartsItemsPostInvoke(inputMap, outputMap, optionsMap);
            return true;
        }

        /*
         * For future, you can also register addition business logic for other events (deleteCartsItems, cloneItems, etc)
         *
         */

        return true;
    }

    /* todo. add apex docs */
    private void postCartsItemsPreInvoke(Map <String, Object> inputMap, Map <String, Object> outputMap, Map <String, Object> optionsMap) {
        String message = 'Hello from postCartsItemsPreInvoke';
        System.debug(LoggingLevel.DEBUG, 'OtterTools > OtterCpqAppHandlerHook > postCartsItemsPreInvoke: ' + message);

    }

    /**
     * Method contains the business logic that is executed AFTER a new line item is added into a cart
     * but BEFORE it is sent back to the client (e.g. CPQ App). This is a great place to 
     * manipulate with the default output of Vlocity CPQ API (e.g. hide specific child items based 
     * on conditions).
     * For more information on Vlocity CPQ API, refer to docs.vlocity.com
     *
     * @param {Map <String, Object>} inputMap - Vlocity CPQ API call input (cart Id, field list, etc.)
     * @param {Map <String, Object>} outputMap - Vlocity CPQ API call output (line items, attributes, etc.)
     * @param {Map <String, Object>} optionsMap - Additional options for Vlocity CPQ API call
     * @return {void} - nothing
     *
     * @example
     *     Not invoked directly. The method is invoked by Vlocity platform. 
    */

    private void postCartsItemsPostInvoke(Map <String, Object> inputMap, Map <String, Object> outputMap, Map <String, Object> optionsMap) {
        String message = 'Hello from postCartsItemsPostInvoke';
        System.debug(LoggingLevel.DEBUG, 'OtterTools > OtterCpqAppHandlerHook > postCartsItemsPostInvoke: ' + message);

    }

    /* todo. add apex docs */
    private void getCartsItemsPreInvoke(Map <String, Object> inputMap, Map <String, Object> outputMap, Map <String, Object> optionsMap) {
        String message = 'Hello from getCartsItemsPreInvoke';
        System.debug(LoggingLevel.DEBUG, 'OtterTools > OtterCpqAppHandlerHook > getCartsItemsPreInvoke: ' + message);

    }

    /**
     * Method contains the business logic that is executed AFTER cart content is retreived 
     * but BEFORE it is sent back to the client (e.g. CPQ App). This is a great place to 
     * manipulate with the default output of Vlocity CPQ API.
     * For more information on Vlocity CPQ API, refer to docs.vlocity.com
     *
     * @param {Map <String, Object>} inputMap - Vlocity CPQ API call input (cart Id, field list, etc.)
     * @param {Map <String, Object>} outputMap - Vlocity CPQ API call output (line items, attributes, etc.)
     * @param {Map <String, Object>} optionsMap - Additional options for Vlocity CPQ API call
     * @return {void} - nothing
     *
     * @example
     *     Not invoked directly. The method is invoked by Vlocity platform. 
    */

    private void getCartsItemsPostInvoke(Map <String, Object> inputMap, Map <String, Object> outputMap, Map <String, Object> optionsMap) {
        String message = 'Hello from getCartsItemsPostInvoke';
        System.debug(LoggingLevel.DEBUG, 'OtterTools > OtterCpqAppHandlerHook > getCartsItemsPostInvoke: ' + message);

        //Getting access to Vlocity API response payload (JSON Result)       
        vlocity_cmt.JSONResult jsonResult = getJSONResult(inputMap, outputMap);        
        System.debug(LoggingLevel.DEBUG, 'OtterTools > OtterCpqAppHandlerHook > getCartsItemsPostInvoke > VARIABLE > inputMap: ' + inputMap);
        System.debug(LoggingLevel.DEBUG, 'OtterTools > OtterCpqAppHandlerHook > getCartsItemsPostInvoke > VARIABLE > outputMap: ' + outputMap);
        
        //Applying custom transformation logic to standard Vlocity CPQ API output

        //This will apply simple conditions for filtering       
        //OtterCPQResponseTransformation.removeNonOrderableRecordsWithSimpleConditions(jsonResult.records);
        
        //This will apply more advanced attribute-based conditions for filtering
        //OtterCPQResponseTransformation.removeNonOrderableChildRecordsWithAdvancedConditionsNew(jsonResult.records, null);
    }

    /* todo. add apex docs */
    private void putCartsItemsPreInvoke(Map <String, Object> inputMap, Map <String, Object> outputMap, Map <String, Object> optionsMap) {
        String message = 'Hello from putCartsItemsPreInvoke';
        System.debug(LoggingLevel.DEBUG, 'OtterTools > OtterCpqAppHandlerHook > putCartsItemsPreInvoke: ' + message);

        System.debug(LoggingLevel.DEBUG, 'OtterTools > OtterCpqAppHandlerHook > putCartsItemsPreInvoke > VARIABLE > inputMap: ' + inputMap);
        System.debug(LoggingLevel.DEBUG, 'OtterTools > OtterCpqAppHandlerHook > putCartsItemsPreInvoke > VARIABLE > outputMap: ' + outputMap);
        
        //navigating through the API input map to access new attribute values
        Map<String, Object> items = (Map<String, Object>) inputMap.get('items');
        List <Object> items_records = (List <Object>) items.get('records');

        for (Object item : items_records) {
            Map<String, Object> attributeCategories = (Map<String, Object>) ((Map<String, Object>) item).get('attributeCategories');
            List <Object> attributeCategories_records = (List <Object>) attributeCategories.get('records');

            for (Object attributeCategory : attributeCategories_records) {
                Map<String, Object> productAttributes = (Map<String, Object>) ((Map<String, Object>) attributeCategory).get('productAttributes');
                List <Object> productAttributes_records = (List <Object>) productAttributes.get('records');

                for (Object productAttribute : productAttributes_records) {
                    Map<String, Object> attr = (Map<String, Object>) productAttribute;
                    System.debug('**** Attribute:value pair: ' + attr.get('code') + ': ' + attr.get('userValues'));

                    //sample condition and attribute update
                    //this is where we can check if an attribute is calculable and how exactly
                    if (attr.get('userValues') == 9) {
                        system.debug('I AM 9');
                        attr.put('userValues', 34);
                    }
                }
            }
    
        }
    }

    /* todo. add apex docs */
    private void putCartsItemsPostInvoke(Map <String, Object> inputMap, Map <String, Object> outputMap, Map <String, Object> optionsMap) {
        String message = 'Hello from putCartsItemsPostInvoke';
        System.debug(LoggingLevel.DEBUG, 'OtterTools > OtterCpqAppHandlerHook > putCartsItemsPostInvoke: ' + message);

    }

    /* helper function. add apex docs */
    //this works for post hooks only
    vlocity_cmt.JSONResult getJSONResult(Map <String, Object> inputMap, Map <String, Object> outputMap) {
        if (outputMap.get('result') != null) {
            Id cartId = (Id) inputMap.get('cartId');
            lineItemTypeForPage = getObjectType(cartId);
            if (lineItemTypeForPage == OrderItem.SObjectType) {
                vlocity_cmt.JSONResult res = (vlocity_cmt.JSONResult) outputMap.get('result');
                //processResultForUpdate(res);
                if (res != null) {
                    return res;
                } else {
                    return null;
                }
            }
        }
        return null;
    }

    /* helper function. add apex docs */
    private SObjectType getObjectType(Id cartId) {
       SobjectType parentObjectTypeForPage;
       parentObjectTypeForPage = cartId.getSObjectType();
       if (parentObjectTypeForPage == Order.SObjectType) {
           lineItemTypeForPage = OrderItem.SObjectType;
       } else if (parentObjectTypeForPage == Quote.SObjectType) {
           lineItemTypeForPage = QuoteLineItem.SObjectType;
       } else if (parentObjectTypeForPage == Opportunity.SObjectType) {
           lineItemTypeForPage = OpportunityLineItem.SObjectType;
       }
       return lineItemTypeForPage;
    }
    
}