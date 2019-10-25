global with sharing class OtterEPCUtilsService implements %vlocity_namespace%.VlocityOpenInterface {

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap) {
        Boolean result = true;

        System.debug(LoggingLevel.ERROR, 'OtterTools > OtterEPCUtilsService > invokeMethod: methodName: ' + methodName);
        System.debug(LoggingLevel.ERROR, 'OtterTools > OtterEPCUtilsService > invokeMethod: inputMap: ' + inputMap);

        if (methodName.equals('getProductHierarchyPath')) {

           OtterEPCUtilsService.getProductHierarchyPathOpenInterface(inputMap, outputMap, optionsMap);

        } if (methodName.equals('getParentProductHierarchyPath')) {

           OtterEPCUtilsService.getParentProductHierarchyPathOpenInterface(inputMap, outputMap, optionsMap);

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
}