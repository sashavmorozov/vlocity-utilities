global abstract with sharing class OtterCopierUtils {
    
    /**
     * Clones an existing Salesforce record identified by Id. Inserts a new record into database and returns it.
     *
     * @param {String} sourceRecordId - unique record Id in Salesforce. This should be a long Salesforce Id (18 digits), not short (15 digits)
     * @param {String} idApiName - API name of the primary key in data model. Usually it is 'Id'
     * @param {String} objectApiName - object API name in data model, e.g. vlocity_cmt__ProductChildItem__c
     * @return cloned record as sObject
     *
     * @example
     *     String sourceRecordId = '01t4J000000pnkLQAQ';
     *     sObject clonedRecord = OtterCopierUtils.cloneRecord(sourceRecordId, 'Id', 'Product2');
     */

    public static sObject cloneRecord(String sourceRecordId, String idApiName, String objectApiName) {
        String sourceRecordSoql = vlocity_cmt.DBHelper.getBaseQuery(objectApiName);
        sourceRecordSoql += ' where ' + idApiName + ' = \'' + sourceRecordId + '\'';
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
     * @param {String} sourceRecordId - unique record Id in Salesforce. This should be a long Salesforce Id (18 digits), not short (15 digits)
     * @param {String} clonedRecordId - unique record Id in Salesforce. This should be a long Salesforce Id (18 digits), not short (15 digits)
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

    public static List<sObject> cloneRelatedItems(String sourceRecordId, String clonedRecordId, String relatedItemObjectApiName, String foreingKeyApiName, String filter) {
        
        List<sObject> sourceRecordItems;
        List<sObject> clonedRecordItems;

        String relatedItemSoql = vlocity_cmt.DBHelper.getBaseQuery(relatedItemObjectApiName);
        relatedItemSoql += ' where ' + foreingKeyApiName + ' = \'' + sourceRecordId + '\'';
        
        if (!String.isBlank(filter)) {
            relatedItemSoql += ' ' + filter;
        }
        sourceRecordItems = Database.query(relatedItemSoql);

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
     * Inserts new records into database and returns a collection of inserted records. Slim version without filter support
     *
     * @param {String} sourceRecordId - unique record Id in Salesforce. This should be a long Salesforce Id (18 digits), not short (15 digits)
     * @param {String} clonedRecordId - unique record Id in Salesforce. This should be a long Salesforce Id (18 digits), not short (15 digits)
     * @param {String} relatedItemObjectApiName - related object API name in data model, e.g. vlocity_cmt__ProductChildItem__c
     * @param {String} foreingKeyApiName - API name of the foreign key that "points" to the original record
     * @return cloned records as a collection of sObject
     *
     * @example
     *     //clone a product and product's orchestration scenarios
     *     String sourceRecordId = '01t4J000000pnkLQAQ';
     *     sObject clonedRecord = OtterCopierUtils.cloneRecord(sourceRecordId, 'Id', 'Product2');
     *     OtterCopierUtils.cloneRelatedItems(sourceRecordId, clonedRecord.Id, 'vlocity_cmt__OrchestrationScenario__c', 'vlocity_cmt__Product2Id__c');
     */

    public static List<sObject> cloneRelatedItems(String sourceRecordId, String clonedRecordId, String relatedItemObjectApiName, String foreingKeyApiName) {
        return cloneRelatedItems(sourceRecordId, clonedRecordId, relatedItemObjectApiName, foreingKeyApiName, null);
    }

    /**
     * Clones a product record with all "related" records (hierarchy, pricing, relationships, rules associations, etc.)
     * Attachments are not cloned at this moment
     * After cloning a product, catalog maintanance jobs may need to be rerun 
     *
     * @param {String} sourceRecordId - unique record Id in Salesforce. This should be a long Salesforce Id (18 digits), not short (15 digits)
     * @return cloned record
     *
     * @example
     *     //clone a product and all related records
     *     String sourceRecordId = '01t4J000000pnkLQAQ';
     *     sObject clonedRecord = OtterCopierUtils.deepCloneProduct(sourceRecordId);
     */

    public static sObject deepCloneProduct(String sourceRecordId) {
        String idApiName = 'Id';
        String objectApiName = 'Product2';
        
        sObject clonedRecord = cloneRecord(sourceRecordId, idApiName, objectApiName);

        System.debug('**** Original Record Id: ' + sourceRecordId);
        System.debug('**** Cloned Record Id: ' + clonedRecord.get('Id'));

        //todo: this may be further parametrized with using metadata

        /** Core elements */
        cloneRelatedItems(sourceRecordId, clonedRecord.Id, 'vlocity_cmt__ProductChildItem__c',             'vlocity_cmt__ParentProductId__c', ' and Name <> \'Root PCI\'');

        /** CPQ elements */
        cloneRelatedItems(sourceRecordId, clonedRecord.Id, 'vlocity_cmt__PriceListEntry__c',              'vlocity_cmt__ProductId__c');
        cloneRelatedItems(sourceRecordId, clonedRecord.Id, 'PricebookEntry',                              'Product2Id',                       ' and Pricebook2.Name <> \'Standard Price Book\'');
        cloneRelatedItems(sourceRecordId, clonedRecord.Id, 'vlocity_cmt__AttributeAssignment__c',         'vlocity_cmt__ObjectId__c',         ' and vlocity_cmt__AttributeAssignment__c.vlocity_cmt__ObjectType__c = \'Product2\''); //doesn't work well?
        cloneRelatedItems(sourceRecordId, clonedRecord.Id, 'vlocity_cmt__ProductRelationship__c',         'vlocity_cmt__Product2Id__c');
        cloneRelatedItems(sourceRecordId, clonedRecord.Id, 'vlocity_cmt__PromotionItem__c',               'vlocity_cmt__ProductId__c');
        cloneRelatedItems(sourceRecordId, clonedRecord.Id, 'vlocity_cmt__RuleAssignment__c',              'vlocity_cmt__ObjectId__c');
        cloneRelatedItems(sourceRecordId, clonedRecord.Id, 'vlocity_cmt__CompiledAttributeOverride__c',   'vlocity_cmt__ProductId__c');

        /** OM elements */
        cloneRelatedItems(sourceRecordId, clonedRecord.Id, 'vlocity_cmt__DecompositionRelationship__c',   'vlocity_cmt__SourceProductId__c');
        cloneRelatedItems(sourceRecordId, clonedRecord.Id, 'vlocity_cmt__OrchestrationScenario__c',       'vlocity_cmt__Product2Id__c');

        /** DC elements */
        cloneRelatedItems(sourceRecordId, clonedRecord.Id, 'vlocity_cmt__CatalogProductRelationship__c',  'vlocity_cmt__Product2Id__c');

        return clonedRecord;
    }

    /**
     * Clones an order record with all "related" records (line items, applied promotions, etc.)
     * Attachments are not cloned at this moment
     * 
     * @param {String} sourceRecordId - unique record Id in Salesforce. This should be a long Salesforce Id (18 digits), not short (15 digits)
     * @return cloned records
     *
     * @example
     *     //clone a product and all related records
     *     String sourceRecordId = '8014J000003HIDyQAO';
     *     sObject clonedRecord = OtterCopierUtils.deepCloneOrder(sourceRecordId);
     */

    public static sObject deepCloneOrder(String sourceRecordId) {
        String idApiName = 'Id';
        String objectApiName = 'Order';
        
        sObject clonedRecord = cloneRecord(sourceRecordId, idApiName, objectApiName);

        System.debug('**** Original Record Id: ' + sourceRecordId);
        System.debug('**** Cloned Record Id: ' + clonedRecord.get('Id'));

        //todo: this may be further parametrized with using metadata

        /* TO-DO: Add related records processing */

        return clonedRecord;
    }
    
}
