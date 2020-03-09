global with sharing class JSONRecordHelper {
    
    public static Set<String> resultRecordKeys = new Set<String> {

        // Line items are items that are already added -- these are the order products
        vlocity_cmt.JSONResult.JSON_KEY_LINEITEMS_RESULT,

        // these are the line items COULD be added (e.g. with “Add to cart” button - note these CAN already be in line items as well
        vlocity_cmt.JSONResult.JSON_KEY_CHILDPRODUCTS_RESULT,
        vlocity_cmt.JSONResult.JSON_KEY_PRODUCTGROUPS_RESULT
    };

    /**
     * Prints vlocity_cmt.JSONRecord records (from Vlocity API response) in a human-readable format
     *
     * @param {List<vlocity_cmt.JSONRecord>} records - Vlocity CPQ API response content structured as vlocity_cmt.JSONRecord-s
     * @param {Boolean} printFields - additional option to include/exclude Salesforce fields into/from the output
     * @return {void} - nothing
     *
     * @example
     *     Map<String, Object> input = new Map<String, Object> {
     *         'cartId' => '8014J000002m7o7QAA',
     *         'price' => false,
     *         'validate' => false,
     *         'methodName' => 'getCartsItems'
     *     };
     *     
     *     Map<String, Object> output = new Map<String, Object> {};
     *     Map<String, Object> options = new Map<String, Object> {};
     *     
     *     // call API
     *     new vlocity_cmt.CpqAppHandler().invokeMethod((String) input.get('methodName'), input, output, options);
     *     vlocity_cmt.JSONResult result = (vlocity_cmt.JSONResult) output.get('result');
    */

    public static void printRecords(List<vlocity_cmt.JSONRecord> records, Boolean printFields) {
        for(vlocity_cmt.JSONRecord rec : records) {
            String path = (String)rec.fields.get('productHierarchyPath');
            String itemType = (String)rec.fields.get('itemType');
            String productName = (String)rec.fields.get(vlocity_cmt.JSONResult.JSON_KEY_NAME);
            Integer productLevel = path.countMatches('<');

            System.debug( ('L' + productLevel + ' >> [' +itemType.toUpperCase() + '] ').rightPad(21) + productName);// + ': ' + rec.nameResult.keySet());

            if (printFields) {
                System.debug(' - fields: ' + JSON.serialize(rec.fields.keySet()));
            }

            for(String key : resultRecordKeys) {
                vlocity_cmt.JSONResult result = rec.nameResult.get(key);

                if (result != null) {
                    printRecords(result.records, printFields);
                }
            }
        }    
    }


    public static Map<String, Object> getJSONRecordAttributesWithValues(vlocity_cmt.JSONRecord record) {
        
        Map<String, Object> attributesMap = new Map<String, Object>();

        if (record == null) {
            System.debug(LoggingLevel.DEBUG, 'OtterTools > JSONRecordHelper > getJSONRecordAttributesWithValues > message: ' + 'no record provided');
            return attributesMap;
        }

        String itemType = (String) record.fields.get('itemType'); // can be: productGroup, lineItem -or- childProduct

        if (itemType == 'productGroup') {
            System.debug(LoggingLevel.DEBUG, 'OtterTools > JSONRecordHelper > getJSONRecordAttributesWithValues > message: ' + 'attributes are not supported for product groups');
            return attributesMap;
        }

        List<vlocity_cmt.JSONRecord> attributesCategoriesList = record.nameResult.get('attributeCategories').records;
        
        for (vlocity_cmt.JSONRecord attributesCategory : attributesCategoriesList) {    
            List<vlocity_cmt.JSONRecord> attributesList = attributesCategory.nameResult.get('productAttributes').records;

            for (vlocity_cmt.JSONRecord attribute : attributesList) {
                vlocity_cmt.JSONAttribute a = (vlocity_cmt.JSONAttribute) attribute;
                System.debug('******: attribute = ' + attribute);

                String attrId = a.attributeId;
                String attrCode = a.code;
                Object attrValues = ((vlocity_cmt.JSONAttribute.JSONSingleUserValue) a.userValues).value; //only single-value for now
                attributesMap.put(attrCode, attrValues);
            }
        }

        System.debug('******: attributesMap = ' + attributesMap);
        return attributesMap;
    }

    /**
     * Little playground
     *
     * @param {List<vlocity_cmt.JSONRecord>} record - Vlocity CPQ API response content structured as vlocity_cmt.JSONRecord-s
     * @return {nothing} - nothing
     *
     * @example
     *    String cartId = '801f40000033ygX';
     *    String methodName = 'getCartsItems';
     *    JSONRecordHelper.testSnippet(cartId, methodName);
    */

    public static void testSnippet(String cartId, String methodName) {
        
        // form API input
        Map<String, Object> input = new Map<String, Object> {
            'cartId' => cartId,
            'price' => false,
            'validate' => false,
            'methodName' => methodName
        };

        Map<String, Object> output = new Map<String, Object> {};
        Map<String, Object> options = new Map<String, Object> {};

        // call API
        new vlocity_cmt.CpqAppHandler().invokeMethod((String) input.get('methodName'), input, output, options);
        vlocity_cmt.JSONResult result = (vlocity_cmt.JSONResult) output.get('result');

        // Print results
        System.debug('>> Orginal Response:');
        printRecords(result.records, false);

        //System.debug('>> Modified Response:');
        //printRecords(removeNoneOrderableRecords(result.records), false);
    }
}