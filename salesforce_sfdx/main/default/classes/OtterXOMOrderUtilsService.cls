global with sharing class OtterXOMOrderUtilsService implements %vlocity_namespace%.VlocityOpenInterface {

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap) {
        Boolean result = true;

        System.debug(LoggingLevel.ERROR, 'OtterTools > OtterXOMOrderUtilsService > invokeMethod: methodName: ' + methodName);
        System.debug(LoggingLevel.ERROR, 'OtterTools > OtterXOMOrderUtilsService > invokeMethod: inputMap: ' + inputMap);

        if (methodName.equals('validateOrderForSubmission')) {
            OtterXOMOrderUtilsService.validateOrderForSubmission(inputMap, outputMap, optionsMap);
            return true;
        }

        if (methodName.equals('submitOrderSync')) {
            OtterXOMOrderUtilsService.submitOrderSync(inputMap, outputMap, optionsMap);
            return result;
        } 
        
        if (methodName.equals('submitOrderAsync')) {
            OtterXOMOrderUtilsService.submitOrderAsync(inputMap, outputMap, optionsMap);
            return result;
        }

        return result;
    }

    public static void validateOrderForSubmission (Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap) {
        
        final String ORDER_ID_KEY = 'orderId';
        
        String orderId = (String) inputMap.get(ORDER_ID_KEY);
        
        if (String.isBlank(orderId)) {

            String message = 'Input value (' + ORDER_ID_KEY + ') is empty';
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterXOMOrderUtilsService > validateOrderForSubmission: ' + message);

            outputMap.put('status', OtterCommonConstants.CONST_FAILED);
            outputMap.put('message', message);
            return;
        }

        System.debug(LoggingLevel.INFO, 'OtterTools > OtterXOMOrderUtilsService > validateOrderForSubmission: input value ' + '(' + ORDER_ID_KEY + '): ' + orderId);

        outputMap.put('result', OtterXOMOrderUtils.validateOrderForSubmission(orderId, outputMap));
        outputMap.put('status', OtterCommonConstants.CONST_SUCCESS);
        outputMap.put('message', null);
    }

    public static void submitOrderSync (Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap) {
        
        final String ORDER_ID_KEY = 'orderId';
        
        String orderId = (String) inputMap.get(ORDER_ID_KEY);
        
        if (String.isBlank(orderId)) {

            String message = 'Input value (' + ORDER_ID_KEY + ') is empty';
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterXOMOrderUtilsService > submitOrderSync: ' + message);

            outputMap.put('status', OtterCommonConstants.CONST_FAILED);
            outputMap.put('message', message);
            return;
        }

        System.debug(LoggingLevel.INFO, 'OtterTools > OtterXOMOrderUtilsService > submitOrderSync: input value ' + '(' + ORDER_ID_KEY + '): ' + orderId);

        outputMap.put('result', OtterXOMOrderUtils.submitOrderSync(orderId, outputMap));
        outputMap.put('status', OtterCommonConstants.CONST_SUCCESS);
        outputMap.put('message', null);
    }

    public static void submitOrderAsync (Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap) {
        
        final String ORDER_ID_KEY = 'orderId';
        
        String orderId = (String) inputMap.get(ORDER_ID_KEY);
        
        if (String.isBlank(orderId)) {

            String message = 'Input value (' + ORDER_ID_KEY + ') is empty';
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterXOMOrderUtilsService > submitOrderAsync: ' + message);

            outputMap.put('status', OtterCommonConstants.CONST_FAILED);
            outputMap.put('message', message);
            return;
        }

        System.debug(LoggingLevel.INFO, 'OtterTools > OtterXOMOrderUtilsService > submitOrderAsync: input value ' + '(' + ORDER_ID_KEY + '): ' + orderId);

        outputMap.put('result', OtterXOMOrderUtils.submitOrderAsync(orderId, outputMap));
        outputMap.put('status', OtterCommonConstants.CONST_SUCCESS);
        outputMap.put('message', null);
    }
}