global abstract with sharing class OtterCommonUtils {
    
    /***************************************************************************************************************
    * @description brief description of method purpose
    * @param description of input parameters
    * @return description of output paramters
    * @example
    *   code snippet illustrating how to invoke the method
    */


    public void methodTemplate() {
        return;
    }

    /***************************************************************************************************************
    * @description returns true if an input string is a valid Id for a given SFDC object type
    * @param String to test, SFDC object type to support validation process
    * @return true if a tested string is a valid Id for a given type, false otherwise
    * @example
    *   OtterCommonUtils.isValidSalesforceId('0011U00000LVuCZ', Account.class)
    */

    public static Boolean isValidSalesforceId(String sfdcId, System.Type t) {
        try {

            if (Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}').matcher(sfdcId).matches()) {
                Id id = sfdcId;
                sObject sObj = (sObject) t.newInstance();
                sObj.Id = id;

                // If no exceptions thrown - consider as valid Id
                return true;
            }
        } catch (Exception e) {
            // If exceptions thrown - consider as invalid Id
        }

        return false;
    }

    /***************************************************************************************************************
    * @description returns true if an input record of a given SFDC object type and a given SFDC If exists
    * @param String to test, SFDC object type to support validation process
    * @return true if a record exists, false otherwise
    * @example
    *   OtterCommonUtils.isExistingRecord('0011U00000LVuCZ', Account.class)
    */
    public static Boolean isExistingRecord(String sfdcId, System.Type t) {
        try {

            String validationQuery = 'select Id from ' + t.getName() + ' where Id = \'' + String.escapeSingleQuotes(sfdcId) + '\'';
            System.debug(LoggingLevel.INFO, 'OtterTools>OtterCommonUtils>isExistingRecord: validationQuery = ' + validationQuery);
            List<SObject> objectList = Database.query(validationQuery);

            if (objectList.size() > 0) {
                return true;
            } else {
                return false;
            }

        } catch (Exception e) {
            // If exceptions thrown - consider as invalid Id
        }

        return false;
    }

    /***************************************************************************************************************
    * @description retrieves a record and a set of fields using SOQL
    * @param record SFDC ID, list of fields (as API names)
    * @return retrieved record
    * @example
    *   List<String> fieldsToRetrieve = new List<String> {'Id', 'Name', 'vlocity_cmt__FulfilmentStatus__c'};
    *   System.debug(OtterCommonUtils.retrieveRecordsById('8011U000000HP5c', Order.class, fieldsToRetrieve));
    */

    public static SObject retrieveSingleRecordById(String sfdcId, System.Type t, List<String> fieldsToRetrieve) {
        try {
            
            String selectQuery = 'select ' + String.join(fieldsToRetrieve, ', ') + ' from ' + t.getName() + ' where Id = \'' + String.escapeSingleQuotes(sfdcId) + '\' limit 1';
            System.debug(LoggingLevel.INFO, 'OtterTools>OtterCommonUtils>retrieveSingleRecordById: selectQuery = ' + selectQuery);
            List<SObject> objectList = Database.query(selectQuery);

            if (objectList.size() != 1) {
                System.debug(LoggingLevel.ERROR, 'OtterTools>OtterCommonUtils>retrieveSingleRecordById: no records found with Id = ' + sfdcId + ' in ' + t.getName());
                return null;
            } else { 
                return objectList[0];
            }

        } catch (Exception e) {
            // If exceptions thrown - consider as invalid Id
        }

        return null;
    }
    
}
