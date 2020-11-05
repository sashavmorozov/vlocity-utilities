global with sharing class OtterCopierUtils implements vlocity_cmt.VlocityOpenInterface2 {
    
    private String errorMessage = '';

    global OtterCopierUtils() {

    }

    /**
     * Invoke-method, entry point for a class implementing Vlocity Open Interface.
     * This method can be invoked by an omniscript or an integration procedure via a remote action
     *
     * @param {String} methodName - 
     * @param Map<String, Object> input - map of input parameters
     * @param Map<String, Object> output - map of to be generated as output
     * @param Map<String, Object> options - map of misc options
     * @return nothing
     *
     * @example
     *      //generally invoked via a remote action from an omniscript or an integration procedure
     *      String sourceRecordId = '01t3L000000LiNPQA0';
     *      Map<String, Object> input = new Map<String, Object>();
     *      input.put('productId', sourceRecordId);
     *      input.put('cloneDecompositionRelationships', false);
     *      input.put('cloneOrchestrationScenarios', false);
     *      Map<String, Object> output = new Map<String, Object>();
     *      Map<String, Object> options = new Map<String, Object>();
     * 
     *      OtterCopierUtils ocu = new OtterCopierUtils();
     *      ocu.invokeMethod('deepCloneProduct', input, output, options);
     *      System.System.debug(output);
     * 
     */

    public Object invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        if (methodName.equals('deepCloneProduct')) {
            try {
                deepCloneProduct(input, output, options);
            } catch (Exception e) {
                errorMessage = 'Failed cloning specification: ' + e.getMessage();
                System.debug(e.getStackTraceString());
            }
        } else {
            errorMessage = 'OtterCopierUtils - invalid method name: ' + methodName;
        }
        if (errorMessage.length() > 0) {
            System.debug(LoggingLevel.ERROR, errorMessage);
            output.put('error', errorMessage);
        }
        return null;
    }

    /**
     * Clones an existing Salesforce record identified by Id and object name. Inserts a new record into database and returns it.
     *
     * @param {String} sourceRecordId - unique record Id in Salesforce. This should be a long Salesforce Id (18 symbols), not short (15 symbols). Using short (15 symbols) identifiers may result in incomplete record closning
     * @param {String} objectApiName - object API name in data model, e.g. 'vlocity_cmt__ProductChildItem__c'
     * @param {String} idApiName - API name of the primary key in data model. Usually it is 'Id'
     * @return cloned record as sObject
     *
     * @example
     *     String sourceRecordId = '01t4J000000pnkLQAQ';
     *     sObject clonedRecord = OtterCopierUtils.cloneRecord(sourceRecordId, 'Product2', 'Id');
     */

    private static sObject cloneRecord(String sourceRecordId, String objectApiName, String idApiName) {
        String sourceRecordSoql = vlocity_cmt.DBHelper.getBaseQuery(objectApiName);
        //sourceRecordSoql += ' where ' + idApiName + ' = \'' + sourceRecordId + '\'';
        sourceRecordSoql += ' where ' + idApiName + ' = :sourceRecordId';

        //todo: add error-handling when record is not found
        sObject sourceRecord = Database.query(sourceRecordSoql);
        sObject clonedRecord = sourceRecord.clone();

        String clonedRecordName = sourceRecord.get('Name') + ' - Copy';

        String counterQuery = 'select count() from ' + objectApiName + ' where name like \'' + clonedRecordName + '%\'';
        Integer countValue = Database.countQuery(counterQuery);

        if (countValue != 0) {
            clonedRecord.put('Name', clonedRecordName + ' ('+ (countValue + 1) +')');
        } else {
            clonedRecord.put('Name', clonedRecordName);
        }

        insert clonedRecord;
        return clonedRecord;
    }

    /**
     * Clones "related" records of a given Salesforce record (an origin) and link them to another Salesforce record (clone of the origin). 
     * Inserts new records into database and returns a collection of inserted records.
     *
     * @param {String} sourceRecordId - unique record Id in Salesforce. This should be a long Salesforce Id (18 symbols), not short (15 symbols)
     * @param {String} clonedRecordId - unique record Id in Salesforce. This should be a long Salesforce Id (18 symbols), not short (15 symbols)
     * @param {String} relatedItemObjectApiName - related object API name in data model, e.g. vlocity_cmt__ProductChildItem__c
     * @param {String} foreingKeyApiName - API name of the foreign key that "points" to the original record
     * @param {String} filter - additional filters to restrict the scope of cloning
     * @return cloned records as a collection of sObject
     *
     * @example
     *     //clone a product and product's price book entries except standard entries which are cloned automatically
     *     String sourceRecordId = '01t4J000000pnkLQAQ';
     *     sObject clonedRecord = OtterCopierUtils.cloneRecord(sourceRecordId, 'Id', 'Product2');
     *     OtterCopierUtils.cloneRelatedItems(sourceRecordId, clonedRecord.Id, 'PricebookEntry', 'Product2Id', ' and Pricebook2.Name <> \'Standard Price Book\'');
     */

    private static List<sObject> cloneRelatedItems(String sourceRecordId, String clonedRecordId, String relatedItemObjectApiName, String foreingKeyApiName, String filter) {
        
        List<sObject> sourceRecordItems;
        List<sObject> clonedRecordItems;

        String relatedItemSoql = vlocity_cmt.DBHelper.getBaseQuery(relatedItemObjectApiName);
        relatedItemSoql += ' where ' + foreingKeyApiName + ' = \'' + sourceRecordId + '\'';
        
        if (!String.isBlank(filter)) {
            relatedItemSoql += ' ' + filter;
        }

        System.debug(LoggingLevel.INFO, 'relatedItemSoql: ' + relatedItemSoql);
        sourceRecordItems = Database.query(relatedItemSoql);
        System.debug(LoggingLevel.INFO, 'relatedItemSoql.size(): ' + sourceRecordItems.size());

        clonedRecordItems = new List<sObject>();
        for (sObject recordItem : sourceRecordItems) {
            sObject tempRecordItem = recordItem.clone();
            tempRecordItem.put(foreingKeyApiName, clonedRecordId);
            clonedRecordItems.add(tempRecordItem);
        }

        if (clonedRecordItems.size() > 0) {
            insert clonedRecordItems;
        }

        return clonedRecordItems;
    }

    /**
     * Clones "related" records of a given Salesforce record (an origin) and link them to another Salesforce record (clone of the origin). 
     * Inserts new records into database and returns a collection of inserted records. Slim version without filter support. Does not apply any filtering to the related records to clone
     *
     * @param {String} sourceRecordId - unique record Id in Salesforce. This should be a long Salesforce Id (18 symbols), not short (15 symbols)
     * @param {String} clonedRecordId - unique record Id in Salesforce. This should be a long Salesforce Id (18 symbols), not short (15 symbols)
     * @param {String} relatedItemObjectApiName - related object API name in data model, e.g. 'vlocity_cmt__ProductChildItem__c'
     * @param {String} foreingKeyApiName - API name of the foreign key that "points" to the original record
     * @return cloned records as a collection of sObject
     *
     * @example
     *     //clone a product and product's orchestration scenarios
     *     String sourceRecordId = '01t4J000000pnkLQAQ';
     *     sObject clonedRecord = OtterCopierUtils.cloneRecord(sourceRecordId, 'Id', 'Product2');
     *     OtterCopierUtils.cloneRelatedItems(sourceRecordId, clonedRecord.Id, 'vlocity_cmt__OrchestrationScenario__c', 'vlocity_cmt__Product2Id__c');
     */

    private static List<sObject> cloneRelatedItems(String sourceRecordId, String clonedRecordId, String relatedItemObjectApiName, String foreingKeyApiName) {
        return cloneRelatedItems(sourceRecordId, clonedRecordId, relatedItemObjectApiName, foreingKeyApiName, null);
    }

    /**
     * Common method to clone a record with all "related" records (varies for different objects and driven out of metadata)
     * After cloning a product, catalog maintanance jobs may need to be rerun 
     *
     * @param {String} sourceRecordId - unique record Id in Salesforce. This should be a long Salesforce Id (18 symbols), not short (15 symbols)
     * @return cloned record
     *
     * @example
     *     //clone a product and all related records
     *     String sourceRecordId = '01t4J000000pnkLQAQ';
     *     String objectApiName = 'Product2';
     *     String idApiName = 'Id';
     *     Map<String, Object> cloningScope = new Map<String, Object> {
     *         'cloneAttributeAssignments' => true,
     *         'clonePriceAndCostConfiguration' => true,
     *         'cloneProductStructure' => true,
     *         'cloneRuleAssignments' => true,
     *         'clonePromotionAssignments' => true,
     *         'cloneDecompositionRelationships' => true,
     *         'cloneCatalogAssignments' => true
     *     };
     *           
     *     sObject clonedRecord = deepCloneRecord(sourceRecordId, objectApiName, idApiName, cloningScope);
     */

    private static sObject deepCloneRecord(String sourceRecordId, String objectApiName, String idApiName, Map<String, Object> cloningScope) {
        sObject clonedRecord = cloneRecord(sourceRecordId, objectApiName, idApiName);

        System.debug('**** Original Record Id: ' + sourceRecordId);
        System.debug('**** Cloned Record Id: ' + clonedRecord.get('Id'));

        List<Otter_Copier_Configuration__mdt> copierMappingList = [SELECT 
            objectApiName__c, 
            relatedItemObjectApiName__c, 
            foreingKeyApiName__c, 
            filter__c,
            cloningScopeProperty__c 
          FROM 
            Otter_Copier_Configuration__mdt 
          where 
            objectApiName__c = :objectApiName];

        for (Otter_Copier_Configuration__mdt copierMapping : copierMappingList) {

            if (copierMapping.cloningScopeProperty__c == null ||
                cloningScope.get(copierMapping.cloningScopeProperty__c) == true ||
                cloningScope.get(copierMapping.cloningScopeProperty__c) == null) {
                System.debug(LoggingLevel.INFO, '*** Cloning related ' + copierMapping.relatedItemObjectApiName__c);
                cloneRelatedItems(sourceRecordId, clonedRecord.Id, copierMapping.relatedItemObjectApiName__c, copierMapping.foreingKeyApiName__c, copierMapping.filter__c);
            } else {
                System.debug(LoggingLevel.INFO, '*** Skipping cloning related ' + copierMapping.relatedItemObjectApiName__c);
            }
        }

        return clonedRecord;
    }

    //TODO: add apexdoc
    public static sObject deepCloneRecord(String sourceRecordId, String objectApiName, String idApiName) {
        return deepCloneRecord(sourceRecordId, objectApiName, idApiName, null);
    }

    /**
     * Clones a record with all "related" records (hierarchy, pricing, relationships, rules associations, etc.)
     * Attachments are not cloned at this moment
     * After cloning a product, catalog maintanance jobs may need to be rerun 
     *
     * @param {String} sourceRecordId - unique record Id in Salesforce. This should be a long Salesforce Id (18 symbols), not short (15 symbols)
     * @return cloned record
     *
     * @example
     *     //clone a product and all related records, except orchestration scenarios and decomposition rules
     *     String sourceRecordId = '01t4J000000pnkLQAQ';
     *     Map<String, Object> input = new Map<String, Object>();
     *     input.put('productId', sourceRecordId);
     *     input.put('cloneDecompositionRelationships', false);
     *     input.put('cloneOrchestrationScenarios', false);
     *     Map<String, Object> output = new Map<String, Object>();
     *     Map<String, Object> options = new Map<String, Object>();
     *     sObject clonedRecord = OtterCopierUtils.deepCloneProduct(input, output, options);
     */

    private static sObject deepCloneProduct(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        String idApiName = 'Id';
        String objectApiName = 'Product2';
        String errorMessage = '';

        String sourceRecordId = (String) input.get('productId');

        if (String.isBlank(sourceRecordId)) {
            errorMessage = 'Source record Id is not provided in the input parameters (productId)';
            output.put('errorMessage', errorMessage);
            return null;
        }

        Map<String, Object> cloningScope = new Map<String, Object> {
            'cloneAttributeAssignments'         => getMapValueBooleanSafe(input, 'cloneAttributeAssignments', true),
            'clonePriceAndCostConfiguration'    => getMapValueBooleanSafe(input, 'clonePriceAndCostConfiguration', true),
            'cloneProductStructure'             => getMapValueBooleanSafe(input, 'cloneProductStructure', true),
            'cloneRuleAssignments'              => getMapValueBooleanSafe(input, 'cloneRuleAssignments', true),
            'clonePromotionAssignments'         => getMapValueBooleanSafe(input, 'clonePromotionAssignments', true),
            'cloneDecompositionRelationships'   => getMapValueBooleanSafe(input, 'cloneDecompositionRelationships', true),
            'cloneOrchestrationScenarios'       => getMapValueBooleanSafe(input, 'cloneOrchestrationScenarios', true),
            'cloneCatalogAssignments'           => getMapValueBooleanSafe(input, 'cloneCatalogAssignments', true)
        };
                
        sObject clonedRecord = deepCloneRecord(sourceRecordId, objectApiName, idApiName, cloningScope);

        output.put('clonedProductId', clonedRecord.Id);

        return clonedRecord;
    }

    /**
     * Safely get map value by key. If the map does not contain the value for the key or an exception occurs, a default value will be returned 
     *
     * @param {Map<String, Object>} input - input map
     * @param {String} key - input key
     * @param {Boolean} defaultValue - default value
     * @return retrieved value
     *
     * @example
     *     Map<String, Object> input = new Map<String, Object> {
     *          'key1' => true,
     *          'key2' => false,
     *          'key3' => 'text_value'
     *     }
     *     Boolean v = getMapValueBooleanSafe(input, 'key1', true);
     */

    private static Boolean getMapValueBooleanSafe(Map <String, Object> input, String key, Boolean defaultValue) {
        String errorMessage = '';
        Boolean value = defaultValue;
        try {
            value = (Boolean) input.get(key);
            if (value == null) {
                value = defaultValue;
            }
        } catch (Exception e) {
            errorMessage = 'Failed getting property: ' + e.getMessage();
            System.debug(e.getStackTraceString());
            value = defaultValue;
        }
        return value;
    }

}