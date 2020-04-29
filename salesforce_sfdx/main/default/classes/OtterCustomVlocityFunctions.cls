global with sharing class OtterCustomVlocityFunctions implements vlocity_cmt.VlocityOpenInterface {
    public OtterCustomVlocityFunctions() {

    }

    /**
     * Implementation of invokeMethod from VlocityOpenInterface
     * <p>
     * Documentation for specific functions is given in their methods
     *
     * @param    methodName Name of method to invoke
     * @param    inputs Arguments - List<Object> of passed in arguments
     * @param    output The result of the Function being called. Supports single Object values, List<Object> or Map<String, Object>
     * @param    options Options, not used in this class
     * @returns  Boolean, indicating success or failure    
    */
    global Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options)
    {
        //  This is useful debugging code in case somebody returns without setting a result by mistake
        output.put('result', 'Error: result not set');

        // Retrieve the argument lists
        List<Object> arguments = (List<Object>)inputs.get('arguments');
        
        if (arguments == null) {
            String errorMessage;

            errorMessage = 'Error: In method ' + methodName + ', no arguments passed';
            output.put('result', errorMessage);
            return false;
        }

        if (methodName == 'convertFlatToStructuredCharachteristics') {
            Object arg0 = arguments[0];
            try {
                output.put('result', convertFlatToStructuredCharachteristics(arg0));
            } catch (Exception e) {
                String errorMessage = 'Error: In method ' + methodName + ', check input arguments';
                output.put('result', errorMessage);
                return false;
            }
            return true;
        }

        if (methodName == 'convertStructuredToFlatCharachteristics') {
            Object arg0 = arguments;
            try {
                output.put('result', convertStructuredToFlatCharachteristics(arg0));
            } catch (Exception e) {
                String errorMessage = 'Error: In method ' + methodName + ', check input arguments';
                output.put('result', errorMessage);
                return false;
            }
            return true;
        }

        if (methodName == 'currentUserInfo') {
            
            try {
                output.put('result', currentUserInfo());
            } catch (Exception e) {
                String errorMessage = 'Error: In method ' + methodName + ', check input arguments';
                output.put('result', errorMessage);
                return false;
            }
            return true;
        }

        output.put('result', 'Error: No Matching Function Found');
        return false;
    }

    /**
     * Converts a flat representation of characteristic values to a structured way
     *
     * @param {Object} inputJsonObj - array of "flat" key-value pairs (as Object)
     * @return {Object} - a map of "structured" key-valye pairs (as Object)
     *
     * @example
     *     String inputString = '{"first_name": "Sasha", "last_name": "Morozov"}';
     *     Object inputJsonObj = JSON.deserializeUntyped(inputString);
     *     List<Object> result = (List<Object>) convertFlatToStructuredCharachteristics(inputJsonObj);
     *     System.debug(result);
     */

    public Object convertFlatToStructuredCharachteristics(Object inputJsonObj) {
        String keyNodeName = 'key';
        String valueNodeName = 'value';
        return convertFlatToStructuredCharachteristics(inputJsonObj, keyNodeName, valueNodeName);
    }

    /**
     * Converts a flat representation of characteristic values to a structured way
     *
     * @param {Object} inputJsonObj - array of "flat" key-value pairs (as Object)
     * @return {Object} - a map of "structured" key-valye pairs (as Object)
     *
     * @example
     *     String inputString = '{"first_name": "Sasha", "last_name": "Morozov"}';
     *     Object inputJsonObj = JSON.deserializeUntyped(inputString);
     *     List<Object> result = (List<Object>) convertFlatToStructuredCharachteristics(inputJsonObj, 'key', 'value');
     *     System.debug(result);
     */

    public Object convertFlatToStructuredCharachteristics(Object inputJsonObj, String keyNodeName, String valueNodeName) {
        
        Map <String, Object> flatCharacteristicValuesAsJsonObj = (Map <String, Object>) inputJsonObj;
        System.debug(flatCharacteristicValuesAsJsonObj);

        Object[] structuredCharacteristicValuesAsJsonObj = new Object[] {};

        for (String key: flatCharacteristicValuesAsJsonObj.keySet()) {
            Object value = (Object) flatCharacteristicValuesAsJsonObj.get(key);
            Map < String, Object > keyValuePair = new Map < String, Object > ();
            keyValuePair.put(keyNodeName, key);
            keyValuePair.put(valueNodeName, value);
            structuredCharacteristicValuesAsJsonObj.add(keyValuePair);
        }

        System.debug('structuredCharacteristicValuesAsJsonObj: ' + JSON.serialize(structuredCharacteristicValuesAsJsonObj));
        
        return structuredCharacteristicValuesAsJsonObj;
    }

    /**
     * Converts a structured representation of characteristic values to a flat way
     *
     * @param {Object} inputJsonObj - array of "structured" key-value pairs (as Object)
     * @return {Object} - a map of "flat" key-valye pairs (as Object)
     *
     * @example
     *     String inputString = '[{"key": "first_name", "value": "Sasha"}, {"key": "last_name", "value": "Morozov"}]';
     *     Object inputJsonObj = JSON.deserializeUntyped(inputString);
     *     Map<String, Object> result = (Map<String, Object>) convertStructuredToFlatCharachteristics(inputJsonObj);
     *     System.debug(result);
     */

    public Object convertStructuredToFlatCharachteristics(Object inputJsonObj) {
        String keyNodeName = 'key';
        String valueNodeName = 'value';
        return convertStructuredToFlatCharachteristics(inputJsonObj, keyNodeName, valueNodeName);
    }

    /**
     * Converts a structured representation of characteristic values to a flat way
     *
     * @param {Object} inputJsonObj - array of "structured" key-value pairs (as Object)
     * @param {String} keyNodeName - name of the key node
     * @param {String} valueNodeName - value of the key node
     * @return {Object} - a map of "flat" key-valye pairs (as Object)
     *
     * @example
     *     String inputString = '[{"key": "first_name", "value": "Sasha"}, {"key": "last_name", "value": "Morozov"}]';
     *     Object inputJsonObj = JSON.deserializeUntyped(inputString);
     *     Map<String, Object> result = (Map<String, Object>) convertStructuredToFlatCharachteristics(inputJsonObj, 'key', 'value');
     *     System.debug(result);
     */

    public Object convertStructuredToFlatCharachteristics(Object inputJsonObj, String keyNodeName, String valueNodeName) {
        
        Object[] structuredCharacteristicValuesAsJsonObj = (Object[]) inputJsonObj;
        Map <String, Object> flatCharacteristicValuesAsJsonObj = new Map <String, Object>();

        for (Integer i = 0; i < structuredCharacteristicValuesAsJsonObj.size(); i++) {
            Map <String, Object> keyValuePair = (Map <String, Object>) structuredCharacteristicValuesAsJsonObj[i];
            String key = (String) keyValuePair.get(keyNodeName);
            Object value = keyValuePair.get(valueNodeName);           
            flatCharacteristicValuesAsJsonObj.put(key, value);
        }
        
        System.debug('flatCharacteristicValuesAsJsonObj: ' + JSON.serialize(flatCharacteristicValuesAsJsonObj));
        
        return flatCharacteristicValuesAsJsonObj;
    }

    /**
     * Returns information about the context user
     *
     * @example
     *     currentUserInfo();
     */

    public Object currentUserInfo() {
        
        Map<String, Object> contextUserInfo = new Map <String, Object>();
        contextUserInfo.put('DefaultCurrency', UserInfo.getDefaultCurrency());
        contextUserInfo.put('FirstName', UserInfo.getFirstName());
        contextUserInfo.put('Language', UserInfo.getLanguage());
        contextUserInfo.put('LastName', UserInfo.getLastName());
        contextUserInfo.put('Locale', UserInfo.getLocale());
        contextUserInfo.put('Name', UserInfo.getName());
        contextUserInfo.put('OrganizationId', UserInfo.getOrganizationId());
        contextUserInfo.put('OrganizationName', UserInfo.getOrganizationName());
        contextUserInfo.put('ProfileId', UserInfo.getProfileId());
        contextUserInfo.put('SessionId', UserInfo.getSessionId());
        contextUserInfo.put('TimeZone', UserInfo.getTimeZone().toString());
        contextUserInfo.put('UiTheme', UserInfo.getUiTheme());
        contextUserInfo.put('UiThemeDisplayed', UserInfo.getUiThemeDisplayed());
        contextUserInfo.put('UserEmail', UserInfo.getUserEmail());
        contextUserInfo.put('UserId', UserInfo.getUserId());
        contextUserInfo.put('UserName', UserInfo.getUserName());
        contextUserInfo.put('UserRoleId', UserInfo.getUserRoleId());
        contextUserInfo.put('UserType', UserInfo.getUserType()); 
        
        System.debug('userInfo: ' + JSON.serialize(contextUserInfo));
        
        return contextUserInfo;
    }
}