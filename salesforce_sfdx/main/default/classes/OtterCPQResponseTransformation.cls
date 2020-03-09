global with sharing class OtterCPQResponseTransformation {
    public OtterCPQResponseTransformation() {

    }

    /**
     * This method decides if a given JSON record (line item) is orderable or non-orderable based on certain criteria
     * The method also accepts a map of attribute-value pairs from the parent line item to support filtering rules based of attributes from the parent line item
     * The map includes [attribute code; attribute value] pairs
     *
     * @param {List<vlocity_cmt.JSONRecord>} record - Vlocity CPQ API response content structured as vlocity_cmt.JSONRecord-s
     * @return {Boolean} - decision
     *
     * @example
     *    isRecordOrderable(record, parentRecordAttributesWithValues);
    */

    public static Boolean isRecordOrderable(vlocity_cmt.JSONRecord record, Map<String, Object> parentRecordAttributesWithValues) {

        //if no conditions provided - assume the line item is orderable
        if (parentRecordAttributesWithValues.isEmpty()) {
            return true;
        }

        /* if (parentRecordAttributesWithValues.size() == 0) {
            return true;
        } */

        String productName = (String)record.fields.get(vlocity_cmt.JSONResult.JSON_KEY_NAME);
        String itemType = (String)record.fields.get('itemType'); // can be: productGroup, lineItem -or- childProduct

        if (itemType == 'lineItem') {
            // line items are already added products, we never want to drop these records. Be very careful before deciding to filter these, as they will be in the order line item.
            return true;
        }

        if (itemType == 'productGroup') {
            // leave product groups (virtual PCIs) alone for this POC
            return true;
        }

        /* Filter sample:
         * exclude 'Zoom Large Meeting Plan' product if:
         * - VEPC_ATTRIBUTE_DEMO_1_ATTRIBUTE_TEXT == 333 on the parent product
         */

        if (productName.contains('EoS. Sample Child Offer 1')) {    
            if (parentRecordAttributesWithValues.get('VEPC_ATTR_EOS_DEMO_ATTRIBUTE_TEXT') == 'Exclude') {
                
                return false;
            } 
        }

        /*
        * Describe other offers that are considered orderable in a given context
        * For example, you may want to filter out all incompatible or conflicting child offers
        * Similarly, you may want to filter out all items with prices higher than X
        *
        * IMPORTANT: the implementation in the Apex class should be as configurable as possible.
        * So that introduction of new rules ideally should not require any Apex developent.
        * Rather you should be able to define such rules in catalog configuration (you are free to 
        * decide how to express such rules)
        *
        * IMPORTANT: in this implementation, you explicitly describe items to include (everything that 
        * is not described explicitly will be excluded). You may extend the class to behave in an opposite
        * way, i.e. explicitly describe items to exclude 
        */

        /* 
        
        if (CONDITION_TO_CHECK) {
            // These records will be excluded
            return false;
        } 
        
        */

        //by default - include a child product
        return true;
    }

    /**
     * This method decides if a given JSON record (line item) is orderable or non-orderable based on certain criteria.
     * The method assumes that the decision can be done for each line item WITHOUT any additonal context information.
     * The decision is done purely based on the information about the line item itself (e.g. name, code, price, etc.).
     * A record is assumed orderable by default
     *
     * @param {<vlocity_cmt.JSONRecord>} record - individual item in Vlocity CPQ API response
     * @return {Boolean} - decision
     *
     * @example
     *    isRecordOrderable(record);
    */
    public static Boolean isRecordOrderable(vlocity_cmt.JSONRecord record) {

        String productName = (String) record.fields.get(vlocity_cmt.JSONResult.JSON_KEY_NAME);
        String itemType = (String) record.fields.get('itemType'); // can be: productGroup, lineItem -or- childProduct

        if (itemType == 'lineItem') {
            // line items are already added products, we never want to drop these records. Be very careful before deciding to filter these, as they will be in the order line item.
            return true;
        }

        if (itemType == 'productGroup') {
            // leave product groups (virtual PCIs) alone for this POC
            return true;
        }

        //Condition #1
        if (productName.contains('EoS. Sample Child Offer 2')) {
            // Always exclude the lines corresponding to the offer with name "EoS. Sample Child Offer 2" 
            return false;
        }

        //Condition #2
        if (productName.contains('EoS. Sample Child Offer 3.2')) {
            // Always exclude the lines corresponding to the offer with name "EoS. Sample Child Offer 3.2" 
            return false;
        }

        /* 
        
        if (CONDITION_TO_CHECK) {
            // These records will be excluded
            return false;
        } 
        
        */

        //by default - include a child product (return true)
        return true;
    }


    /**
     * Removes non-orderable child records (line items) from Vlocity CPQ API output (recursively iterating through the levels of the cart). 
     * The modified Vlocity CPQ API output will be routed further to the API client (e.g. Vlocity CPQ App). This method also provides attribute-value pairs to the validation, so that the decision can be done based on attributes from the parent line
     *
     * @param {List<vlocity_cmt.JSONRecord>} records - Vlocity CPQ API response content structured as vlocity_cmt.JSONRecord-s
     * @return {void} - nothing
     *
     * @example
     *    removeNonOrderableChildRecordsWithAdvancedConditions(records);
    */

    public static List<vlocity_cmt.JSONRecord> removeNonOrderableChildRecordsWithAdvancedConditionsNew(List<vlocity_cmt.JSONRecord> records, vlocity_cmt.JSONRecord parentRecord) {
        
        //gather information on line item attributes
        Map<String, Object> attributesWithValues = JSONRecordHelper.getJSONRecordAttributesWithValues(parentRecord);

        List<vlocity_cmt.JSONRecord> updatedRecords = new List<vlocity_cmt.JSONRecord>();
        for (vlocity_cmt.JSONRecord rec : records) {
            
            String productName = (String) rec.fields.get(vlocity_cmt.JSONResult.JSON_KEY_NAME);
            if (isRecordOrderable(rec, attributesWithValues)) {
                        
                System.debug(LoggingLevel.DEBUG, 'OtterTools > OtterCPQResponseTransformation > removeNonOrderableRecordsWithSimpleConditions > message: ' + 'Orderable: ' + productName + ': this line item is orderable');
                //updatedRecords.add(rec);
            } else {
                System.debug(LoggingLevel.DEBUG, 'OtterTools > OtterCPQResponseTransformation > removeNonOrderableRecordsWithSimpleConditions > message: ' + 'Not-Orderable: ' + productName + ': this line item is not orderable and is excluded');
                continue;
            }

            updatedRecords.add(rec);

            // remove childs we don't want to see. recursively process child hierarchies
            for (String key : JSONRecordHelper.resultRecordKeys) {
                vlocity_cmt.JSONResult result = rec.nameResult.get(key);

                if (result != null) {
                    result.records = removeNonOrderableChildRecordsWithAdvancedConditionsNew(result.records, rec);
                }
            }
        }

        return updatedRecords;


    }

    public static void removeNonOrderableChildRecordsWithAdvancedConditions(List<vlocity_cmt.JSONRecord> records) {
        
        for (vlocity_cmt.JSONRecord rec : records) {

            //gather information on line item attributes
            Map<String, Object> attributesWithValues = JSONRecordHelper.getJSONRecordAttributesWithValues(rec);

            // remove childs we don't want to see
            for (String key : JSONRecordHelper.resultRecordKeys) {
                vlocity_cmt.JSONResult result = rec.nameResult.get(key);
                List<vlocity_cmt.JSONRecord> updatedRecords = new List<vlocity_cmt.JSONRecord>();

                //iterate through child items, attributes from the parent line are provided as the context
                for (vlocity_cmt.JSONRecord childRec : result.records) {
                    String productName = (String) childRec.fields.get(vlocity_cmt.JSONResult.JSON_KEY_NAME);

                    if (isRecordOrderable(childRec, attributesWithValues)) {
                        
                        System.debug(LoggingLevel.DEBUG, 'OtterTools > OtterCPQResponseTransformation > removeNonOrderableChildRecordsWithAdvancedConditions > message: ' + 'Orderable: ' + productName + ': this line item is orderable');
                        updatedRecords.add(childRec);
                    } else {
                        System.debug(LoggingLevel.DEBUG, 'OtterTools > OtterCPQResponseTransformation > removeNonOrderableChildRecordsWithAdvancedConditions > message: ' + 'Not-Orderable: ' + productName + ': this line item is not orderable and is excluded');
                        continue;
                    }

                }

                result.records = updatedRecords;

                //FOR FUTURE USE: process further hierarchy down - recursion. If there is anything left - go deeper. 
                /* 
                
                if (result.records.size() != 0) {
                    removeNonOrderableChildRecordsWithAdvancedConditions(result.records);
                } 
                
                */
            }
        }
    }

    /**
     * Removes non-orderable records (line items) from Vlocity CPQ API output. The modified Vlocity CPQ API output
     * will be routed further to the API client (e.g. Vlocity CPQ App).
     * This method uses simple filtering conditions from isRecordOrderable (without additional context)
     *
     * @param {List<vlocity_cmt.JSONRecord>} record - Vlocity CPQ API response content structured as vlocity_cmt.JSONRecord-s
     * @return {List<vlocity_cmt.JSONRecord>} - modified Vlocity CPQ API output
     *
     * @example
     *    //List<vlocity_cmt.JSONRecord> records = GET_FROM_VLOCITY_CPQ_API;
     *    removeNoneOrderableRecords(records);
    */

    public static List<vlocity_cmt.JSONRecord> removeNonOrderableRecordsWithSimpleConditions(List<vlocity_cmt.JSONRecord> records) {
        List<vlocity_cmt.JSONRecord> updatedRecords = new List<vlocity_cmt.JSONRecord>();
        for (vlocity_cmt.JSONRecord rec : records) {
            
            String productName = (String) rec.fields.get(vlocity_cmt.JSONResult.JSON_KEY_NAME);
            if (isRecordOrderable(rec)) {
                        
                System.debug(LoggingLevel.DEBUG, 'OtterTools > OtterCPQResponseTransformation > removeNonOrderableRecordsWithSimpleConditions > message: ' + 'Orderable: ' + productName + ': this line item is orderable');
                //updatedRecords.add(rec);
            } else {
                System.debug(LoggingLevel.DEBUG, 'OtterTools > OtterCPQResponseTransformation > removeNonOrderableRecordsWithSimpleConditions > message: ' + 'Not-Orderable: ' + productName + ': this line item is not orderable and is excluded');
                continue;
            }

            updatedRecords.add(rec);

            // remove childs we don't want to see. recursively process child hierarchies
            for (String key : JSONRecordHelper.resultRecordKeys) {
                vlocity_cmt.JSONResult result = rec.nameResult.get(key);

                if (result != null) {
                    result.records = removeNonOrderableRecordsWithSimpleConditions(result.records);
                }
            }
        }

        return updatedRecords;
    }
}