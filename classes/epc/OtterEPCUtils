global with sharing class OtterEPCUtils {
    
    static Integer MAX_HIERARCHY_DEPTH_CONST = 5;
    static Integer currentHierarchyLevel = 0;
    static String EMPTY_STRING_CONST = '';
    
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
    * @description returns a list of product child item records for a given product (identified with product code). Only direct children are returned. This particular method is partially writted by my lovely black kate Martin who provided all required assistance to complete this piece of code
    *                          | \
    *                          | |
    *                          | |
    *     |\                   | |
    *    /, ~\                / /
    *   X     `-.....-------./ /
    *    ~-. ~  ~              |
    *       \             /    |
    *        \  /_     ___\   /
    *        | /\ ~~~~~~~~ \ |
    *        | | \        || |
    *        | |\ \       || )
    *       (_/ (_/      ((_/    
    * @param product code (List<String>)
    * @return list of direct product child items (List<vlocity_cmt__ProductChildItem__c>)
    * @example
    *   OtterEPCUtils.getProductChildItems(new List<String> {'ACC_OFFERING_MOBILE_SUBSCRIPTION_BASIC'})
    */

    public static List<vlocity_cmt__ProductChildItem__c> getProductChildItems(List<String> parentProductCodesList) {

        List <vlocity_cmt__ProductChildItem__c> productChildItemsList = [
            Select 
            Id, 
            Name, 
            vlocity_cmt__ChildProductId__c, 
            vlocity_cmt__IsRootProductChildItem__c, 
            vlocity_cmt__ParentProductId__c, 
            vlocity_cmt__RelationshipType__c, 
            vlocity_cmt__IsVirtualItem__c,
            vlocity_cmt__ParentProductId__r.ProductCode,
            vlocity_cmt__ChildProductId__r.ProductCode 
            from 
                vlocity_cmt__ProductChildItem__c
            where
                vlocity_cmt__IsRootProductChildItem__c = false
                and vlocity_cmt__ParentProductId__r.ProductCode in :parentProductCodesList];

        return productChildItemsList;
    }

    
    /***************************************************************************************************************
    * @description returns a list of product child item records for a given product (identified with product code). The entier hierarchy is returned
    * @param product code (List<String>)
    * @return list of product child items (List<vlocity_cmt__ProductChildItem__c>)
    * @example
    *   OtterEPCUtils.getProductChildItemsWithHierarchy(new List<String> {'ACC_OFFERING_MOBILE_SUBSCRIPTION_BASIC'})
    */

    public static List<vlocity_cmt__ProductChildItem__c> getProductChildItemsWithHierarchy(List<String> parentProductCodesList) {
    
        currentHierarchyLevel++;
        System.debug('TOOLS>DEBUG>OtterEPCUtils>getProductChildItemsWithHierarchy: currentHierarchyLevel: ' + currentHierarchyLevel);
        List <vlocity_cmt__ProductChildItem__c> currentLevelList = getProductChildItems(parentProductCodesList);
        if (currentLevelList.size() == 0) {
            System.debug('TOOLS>DEBUG>OtterEPCUtils>getProductChildItemsWithHierarchy: reached the exit for recursion');
            return currentLevelList;
        } else {
            System.debug('TOOLS>DEBUG>OtterEPCUtils>getProductChildItemsWithHierarchy: call recursion path');
            if (currentHierarchyLevel > MAX_HIERARCHY_DEPTH_CONST) return new List<vlocity_cmt__ProductChildItem__c>();

            List <String> childProductCodesList = new List <String>();
            for (vlocity_cmt__ProductChildItem__c pci : currentLevelList) {
                childProductCodesList.add(pci.vlocity_cmt__ChildProductId__r.ProductCode);
            }

            currentLevelList.addAll(getProductChildItemsWithHierarchy(childProductCodesList));
            return currentLevelList;
        }   

    }

    /***************************************************************************************************************
    * @description returns product hierarchy path for a given pair of child and the root products
    * @param child product code (String), root product code (String)
    * @return product hierarchy path if the child product can be a part of the root product. Empty string otherwise, and in case of exceptions
    * @example
    *   OtterEPCUtils.getProductHierarchyPath('ACC_OFFERING_PASS_INTERNET_1GB','ACC_OFFERING_MOBILE_SUBSCRIPTION_BASIC')
    */
    public static String getProductHierarchyPath(String childProductCode, String parentProductCode) {
    
        String childProductId = getProductIdByProductCode(childProductCode);
        String parentProductId = getProductIdByProductCode(parentProductCode);

        if (String.isBlank(childProductId)) {
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterEPCUtils > getProductHierarchyPath: the product with code ' + childProductCode + ' is not found');
            return EMPTY_STRING_CONST;
        }

        if (String.isBlank(parentProductId)) {
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterEPCUtils > getProductHierarchyPath: the product with code ' + childProductCode + ' is not found');
            return EMPTY_STRING_CONST;
        }

        if (childProductCode == parentProductCode) return childProductCode;

        currentHierarchyLevel = 0;
        List <vlocity_cmt__ProductChildItem__c> childProductItemsWithHierarchy = getProductChildItemsWithHierarchy(new List <String> {parentProductCode});
        
        Map <String, String> productCodeToParentProductCodeMap = new Map <String, String>();
        Map <String, String> productIdToParentProductIdMap = new Map <String, String>();

        for (vlocity_cmt__ProductChildItem__c pci : childProductItemsWithHierarchy) {
            productCodeToParentProductCodeMap.put(pci.vlocity_cmt__ChildProductId__r.ProductCode, pci.vlocity_cmt__ParentProductId__r.ProductCode);
            productIdToParentProductIdMap.put(pci.vlocity_cmt__ChildProductId__c, pci.vlocity_cmt__ParentProductId__c);
        }

        String pathText = childProductCode;
        String pathId = childProductId;
        String currentProductCode = childProductCode;
        String currentProductId = childProductId;

        Boolean parentProductFound = true;
        while (parentProductFound && currentHierarchyLevel++ < MAX_HIERARCHY_DEPTH_CONST) {
            String currentParentProductCode = productCodeToParentProductCodeMap.get(currentProductCode);
            String currentParentProductId = productIdToParentProductIdMap.get(currentProductId);

            if (!String.isBlank(currentParentProductCode)) {
                pathText = currentParentProductCode + '<' + pathText;
                pathId = currentParentProductId + '<' + pathId;
                currentProductCode = currentParentProductCode;
                currentProductId = currentParentProductId;
                parentProductFound = true;
            } else {
                parentProductFound = false;
            }
        }
        
        System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtils > getProductHierarchyPath: product hierarchy path: ' + pathId);
        System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtils > getProductHierarchyPath: product hierarchy path (codes): ' + pathText);

        return pathId;

    }

    /***************************************************************************************************************
    * @description returns product hierarchy path for a parent node for a given pair of child and the root products. This value is often used in CPQ API when adding a child line item into a specific place in product hierarchy
    * @param child product code (String), root product code (String)
    * @return parent product hierarchy path if the child product can be a part of the root product. Empty string otherwise, and in case of exceptions
    * @example
    *   OtterEPCUtils.getProductHierarchyPath('ACC_OFFERING_PASS_INTERNET_1GB','ACC_OFFERING_MOBILE_SUBSCRIPTION_BASIC')
    */
    public static String getParentProductHierarchyPath(String childProductCode, String parentProductCode) {
        String productProductHierarchyPath = getProductHierarchyPath(childProductCode, parentProductCode);
        return productProductHierarchyPath.substringBeforeLast('<');
    }

    /***************************************************************************************************************
    * @description returns product Id based on product code
    * @param product code
    * @return product Id if a product if found. An empty string if no product found or more than one product found by code
    * @example
    *   OtterEPCtils.findProductIdByProductCode('ACC_OFFER_MANAGED_WAN_PREMIUM')
    */

    public static String getProductIdByProductCode(String productCode) {
        List<Product2> productRecordList = [
            select
                Id,
                Name,
                ProductCode
            from
                Product2
            where
                ProductCode = :productCode
                and ProductCode != null
        ];

        if (productRecordList.size() < 1) {
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterEPCUtils > findProductIdByProductCode: the product with code ' + productCode + ' not found');
            return EMPTY_STRING_CONST;

        } else if (productRecordList.size() > 1) {
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterEPCUtils > findProductIdByProductCode: more than one record found for the code ' + productCode);
            return EMPTY_STRING_CONST;

            } else {
                return productRecordList[0].Id;

            }
    }

    
    
}
