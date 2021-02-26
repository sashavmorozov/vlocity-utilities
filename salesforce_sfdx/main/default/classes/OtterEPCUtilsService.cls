global with sharing class OtterEPCUtilsService implements vlocity_cmt.VlocityOpenInterface {

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap) {
        Boolean result = true;

        System.debug(LoggingLevel.ERROR, 'OtterTools > OtterEPCUtilsService > invokeMethod: methodName: ' + methodName);
        System.debug(LoggingLevel.ERROR, 'OtterTools > OtterEPCUtilsService > invokeMethod: inputMap: ' + inputMap);

        if (methodName.equals('getProductHierarchyPath')) {

           OtterEPCUtilsService.getProductHierarchyPathOpenInterface(inputMap, outputMap, optionsMap);

        } if (methodName.equals('getParentProductHierarchyPath')) {

           OtterEPCUtilsService.getParentProductHierarchyPathOpenInterface(inputMap, outputMap, optionsMap);

        } if (methodName.equals('regenerateJsonAttributes')) {

           OtterEPCUtilsService.regenerateJsonAttributesOpenInterface(inputMap, outputMap, optionsMap);

        } if (methodName.equals('clearPlatformCache')) {

           OtterEPCUtilsService.clearPlatformCacheOpenInterface(inputMap, outputMap, optionsMap);

        } if (methodName.equals('RegenerateLayoutsForObjectType')) {

           OtterEPCUtilsService.replicateLayoutOpenInterface(inputMap, outputMap, optionsMap);

        } else {
          result = false;
        }

        return result;
    }


    public static void getProductHierarchyPathOpenInterface (Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap) {
        
        final String CHILD_PRODUCT_CODE_KEY = 'childProductCode';
        final String PARENT_PRODUCT_CODE_KEY = 'parentProductCode';
        
        String childProductCode = (String) inputMap.get(CHILD_PRODUCT_CODE_KEY);
        String parentProductCode = (String) inputMap.get(PARENT_PRODUCT_CODE_KEY);
        
        if (String.isBlank(childProductCode) || String.isBlank(parentProductCode)) {
            System.debug(
              LoggingLevel.ERROR,
              'OtterTools > OtterEPCUtilsService > getProductHierarchyPathOpenInterface: input value ' +
              '(' + CHILD_PRODUCT_CODE_KEY + ') ' +
              'or (' + PARENT_PRODUCT_CODE_KEY + ') is empty')
            ;

            outputMap.put('Status', 'Failed');
            outputMap.put('Message', 'input value ' +
              '(' + CHILD_PRODUCT_CODE_KEY + ') ' +
              'or (' + PARENT_PRODUCT_CODE_KEY + ') is empty');
            return;
        }

        System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtilsService > getProductHierarchyPathOpenInterface: input value ' + 
            '(' + CHILD_PRODUCT_CODE_KEY + 
            '): ' + childProductCode);

        System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtilsService > getProductHierarchyPathOpenInterface: input value ' + 
            '(' + PARENT_PRODUCT_CODE_KEY + 
            '): ' + parentProductCode);

        outputMap.put('Result', OtterEPCUtils.getProductHierarchyPath(childProductCode, parentProductCode));
        outputMap.put('Status', 'Success');
        outputMap.put('Message', 'Product hierarchy path is calculated successfully. If the returned value is empty - see logs for further instructions');
    }

    public static void getParentProductHierarchyPathOpenInterface (Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap) {
        
        final String CHILD_PRODUCT_CODE_KEY = 'childProductCode';
        final String PARENT_PRODUCT_CODE_KEY = 'parentProductCode';
        
        String childProductCode = (String) inputMap.get(CHILD_PRODUCT_CODE_KEY);
        String parentProductCode = (String) inputMap.get(PARENT_PRODUCT_CODE_KEY);
        
        if (String.isBlank(childProductCode) || String.isBlank(parentProductCode)) {
            System.debug(
              LoggingLevel.ERROR,
              'OtterTools > OtterEPCUtilsService > getProductHierarchyPathOpenInterface: input value ' +
              '(' + CHILD_PRODUCT_CODE_KEY + ') ' +
              'or (' + PARENT_PRODUCT_CODE_KEY + ') is empty')
            ;

            outputMap.put('Status', 'Failed');
            outputMap.put('Message', 'input value ' +
              '(' + CHILD_PRODUCT_CODE_KEY + ') ' +
              'or (' + PARENT_PRODUCT_CODE_KEY + ') is empty');
            return;
        }

        System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtilsService > getProductHierarchyPathOpenInterface: input value ' + 
            '(' + CHILD_PRODUCT_CODE_KEY + 
            '): ' + childProductCode);

        System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtilsService > getProductHierarchyPathOpenInterface: input value ' + 
            '(' + PARENT_PRODUCT_CODE_KEY + 
            '): ' + parentProductCode);

        outputMap.put('Result', OtterEPCUtils.getParentProductHierarchyPath(childProductCode, parentProductCode));
        outputMap.put('Status', 'Success');
        outputMap.put('Message', 'Product hierarchy path is calculated successfully. If the returned value is empty - see logs for further instructions');
    }

    public static void regenerateJsonAttributesOpenInterface (Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap) {
        
        final String PRODUCT_CODES_KEY = 'productCodes';
        
        List<Object> productCodes = (List<Object>) inputMap.get(PRODUCT_CODES_KEY);
        List<String> productCodesString = new List<String> ();
        for (Object o : productCodes) {
            productCodesString.add((String) o);
        }
        
        if (productCodes.size() < 1) {
            System.debug(
              LoggingLevel.ERROR,
              'OtterTools > OtterEPCUtilsService > getProductHierarchyPathOpenInterface: input value ' +
              '(' + PRODUCT_CODES_KEY + ') is empty')
            ;

            outputMap.put('Status', 'Failed');
            outputMap.put('Message', 'input value ' +
              '(' + PRODUCT_CODES_KEY + ') is empty');
            return;
        }

        System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtilsService > regenerateJsonAttributes: input value ' + 
            '(' + PRODUCT_CODES_KEY + 
            '): ' + productCodes);

        outputMap.put('Result', OtterEPCUtils.regenerateJsonAttributes(productCodesString));
        outputMap.put('Status', 'Success');
        outputMap.put('Message', 'JSONAttribute refresh job successfully started. Please allow some processing time to see the results in user interface');
    }

    public static void clearPlatformCacheOpenInterface (Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap) {

        String result = OtterEPCUtils.clearPlatformCache();
        outputMap.put('Result', result);
        outputMap.put('Status', 'Success');
        outputMap.put('Message', result);
    }

    public static void replicateLayoutOpenInterface (Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap) {
        
        final String SOURCE_OBJECT_TYPE_CODE_KEY = 'sourceObjectTypeName';
        final String TARGET_OBJECT_TYPE_CODE_KEY = 'targetObjectTypeName';
        
        String sourceObjectTypeName = (String) inputMap.get(SOURCE_OBJECT_TYPE_CODE_KEY);
        String targetObjectTypeName = (String) inputMap.get(TARGET_OBJECT_TYPE_CODE_KEY);
        
        if (String.isBlank(sourceObjectTypeName) || String.isBlank(targetObjectTypeName)) {
            System.debug(
              LoggingLevel.ERROR,
              'OtterTools > OtterEPCUtilsService > replicateLayoutOpenInterface: input value ' +
              '(' + SOURCE_OBJECT_TYPE_CODE_KEY + ') ' +
              'or (' + TARGET_OBJECT_TYPE_CODE_KEY + ') is empty')
            ;

            outputMap.put('Status', 'Failed');
            outputMap.put('Message', 'input value ' +
              '(' + SOURCE_OBJECT_TYPE_CODE_KEY + ') ' +
              'or (' + TARGET_OBJECT_TYPE_CODE_KEY + ') is empty');
            return;
        }

        System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtilsService > replicateLayoutOpenInterface: input value ' + 
            '(' + SOURCE_OBJECT_TYPE_CODE_KEY + 
            '): ' + sourceObjectTypeName);

        System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtilsService > replicateLayoutOpenInterface: input value ' + 
            '(' + TARGET_OBJECT_TYPE_CODE_KEY + 
            '): ' + targetObjectTypeName);

        OtterEPCUtils.replicateLayout(sourceObjectTypeName, targetObjectTypeName);

        outputMap.put('Result', '');
        outputMap.put('Status', 'Success');
        outputMap.put('Message', 'result - need to get output from OtterEPCUtils');
    }
}