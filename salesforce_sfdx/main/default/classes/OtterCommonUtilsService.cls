global with sharing class OtterCommonUtilsService implements %vlocity_namespace%.VlocityOpenInterface {

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap) {
        Boolean result = true;

        System.debug(LoggingLevel.ERROR, 'OtterTools > OtterCommonUtilsService > invokeMethod: methodName: ' + methodName);
        System.debug(LoggingLevel.ERROR, 'OtterTools > OtterCommonUtilsService > invokeMethod: inputMap: ' + inputMap);

        if (methodName.equals('isValidSalesforceId')) {
            OtterCommonUtilsService.isValidSalesforceId(inputMap, outputMap, optionsMap);
            return true;
        }

        if (methodName.equals('isExistingRecord')) {
            OtterCommonUtilsService.isExistingRecord(inputMap, outputMap, optionsMap);
            return result;
        } 
        
        return result;
    }

    public static void isValidSalesforceId (Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap) {
        
        final String RECORD_ID_KEY = 'recordId';
        final String OBJECT_NAME_KEY = 'objectName';
        
        String recordId = (String) inputMap.get(RECORD_ID_KEY);
        String objectName = (String) inputMap.get(OBJECT_NAME_KEY);
        
        if (String.isBlank(recordId)) {

            String message = 'Input value (' + RECORD_ID_KEY + ') is empty';
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterCommonUtilsService > isValidSalesforceId: ' + message);

            outputMap.put('status', OtterCommonConstants.CONST_FAILED);
            outputMap.put('message', message);
            return;
        }

        if (String.isBlank(objectName)) {

            String message = 'Input value (' + OBJECT_NAME_KEY + ') is empty';
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterCommonUtilsService > isValidSalesforceId: ' + message);

            outputMap.put('status', OtterCommonConstants.CONST_FAILED);
            outputMap.put('message', message);
            return;
        }

        System.debug(LoggingLevel.INFO, 'OtterTools > OtterCommonUtilsService > isValidSalesforceId: input value ' + '(' + RECORD_ID_KEY + '): ' + recordId);

        outputMap.put('result', OtterCommonUtils.isValidSalesforceId(recordId, Type.forName(objectName)));
        outputMap.put('status', OtterCommonConstants.CONST_SUCCESS);
        outputMap.put('message', null);
    }

    public static void isExistingRecord (Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap) {
        
        final String RECORD_ID_KEY = 'recordId';
        final String OBJECT_NAME_KEY = 'objectName';
        
        String recordId = (String) inputMap.get(RECORD_ID_KEY);
        String objectName = (String) inputMap.get(OBJECT_NAME_KEY);
        
        if (String.isBlank(recordId)) {

            String message = 'Input value (' + RECORD_ID_KEY + ') is empty';
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterCommonUtilsService > isValidSalesforceId: ' + message);

            outputMap.put('result', false);
            outputMap.put('status', OtterCommonConstants.CONST_FAILED);
            outputMap.put('message', message);
            return;
        }

        if (String.isBlank(objectName)) {

            String message = 'Input value (' + OBJECT_NAME_KEY + ') is empty';
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterCommonUtilsService > isValidSalesforceId: ' + message);


            outputMap.put('result', false);
            outputMap.put('status', OtterCommonConstants.CONST_FAILED);
            outputMap.put('message', message);
            return;
        }

        System.debug(LoggingLevel.INFO, 'OtterTools > OtterCommonUtilsService > isValidSalesforceId: input value ' + '(' + RECORD_ID_KEY + '): ' + recordId);
        System.debug(LoggingLevel.INFO, 'OtterTools > OtterCommonUtilsService > isValidSalesforceId: input value ' + '(' + OBJECT_NAME_KEY + '): ' + objectName);

        outputMap.put('result', OtterCommonUtils.isExistingRecord(recordId, Type.forName(objectName)));
        outputMap.put('status', OtterCommonConstants.CONST_SUCCESS);
        outputMap.put('message', null);
    }

    
}