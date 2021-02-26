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
        currentHierarchyLevel = 0;
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

    /***************************************************************************************************************
    * @description removes currently configured layout for the given object type
    * @param object type (String)
    * @return nothing
    * @example
    *   String objectTypeName = 'PoP Physical Resource Object Type';
    *   OtterEPCUtils.replicateLayout(objectTypeName);
    */

    public static void removeConfiguredLayout(String objectTypeName) {
        try {
            vlocity_cmt__ObjectClass__c objectType = [
                select 
                    Id, 
                    Name
                from
                    vlocity_cmt__ObjectClass__c 
                where
                    Name = :objectTypeName];

            System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtils > removeConfiguredLayout: objectType = ' + objectType);

            List<vlocity_cmt__ObjectLayout__c> objectLayoutList = [
            select 
                Id,
                Name,
                vlocity_cmt__IsActive__c,
                vlocity_cmt__IsDefault__c,
                vlocity_cmt__ObjectClassId__c,
                vlocity_cmt__ObjectClassId__r.Name,
                vlocity_cmt__SubclassId__c
            from 
                vlocity_cmt__ObjectLayout__c 
            where 
                (vlocity_cmt__ObjectClassId__c = :objectType.Id 
                and vlocity_cmt__SubclassId__c = NULL) 
                or (vlocity_cmt__ObjectClassId__r.Name = 'Product2 Object' 
                and vlocity_cmt__SubclassId__c = :objectType.Id)
            ];

            System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtils > removeConfiguredLayout: objectLayoutList = ' + objectLayoutList);

            delete objectLayoutList;

            System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtils > removeConfiguredLayout: ' + 'Layout is successfully removed');
        }
        catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterEPCUtils > removeConfiguredLayout: exception = ' + e);
            return;
        }
    }

    /***************************************************************************************************************
    * @description replicates layout from a source object type to a target object type. The method removes currently configured layout for the terget object type and then copies over configuration from the source object type
    * @param source object type (String), target object type (String)
    * @return nothing
    * @example
    *   String sourceObjectTypeName = 'Product2 Object';
    *   String targetObjectTypeName = 'PoP Physical Resource Object Type';
    *   OtterEPCUtils.replicateLayout(sourceObjectTypeName, targetObjectTypeName);
    */

    public static void replicateLayout(String sourceObjectTypeName, String targetObjectTypeName) {
        Boolean preserveId = false;
        Boolean isDeepClone = true;
        Boolean preserveReadonlyTimestamps = false;
        Boolean preserveAutonumber = false;

        /* String sourceObjectTypeName = 'Product2 Object';
        String targetObjectTypeName = 'H3G MSISDN Object Type'; */

        List<vlocity_cmt__ObjectLayout__c> objectLayoutsForInsert   = new List<vlocity_cmt__ObjectLayout__c>();
        List<vlocity_cmt__ObjectFacet__c> objectFacetsForInsert     = new List<vlocity_cmt__ObjectFacet__c>();
        List<vlocity_cmt__ObjectSection__c> objectSectionsForInsert = new List<vlocity_cmt__ObjectSection__c>();
        List<vlocity_cmt__ObjectElement__c> objectElementsForInsert = new List<vlocity_cmt__ObjectElement__c>();

        Map<Id, vlocity_cmt__ObjectFacet__c> sourceObjectFacetIdToClonedObjectFacet         = new Map<Id, vlocity_cmt__ObjectFacet__c>();
        Map<Id, vlocity_cmt__ObjectSection__c> sourceObjectSectionIdToClonedObjectSection   = new Map<Id, vlocity_cmt__ObjectSection__c>();
        Map<Id, vlocity_cmt__ObjectElement__c> sourceObjectElementIdToClonedObjectElement   = new Map<Id, vlocity_cmt__ObjectElement__c>();


        try {
            vlocity_cmt__ObjectClass__c sourceObjectType = [
                select 
                    Id, 
                    Name
                from
                    vlocity_cmt__ObjectClass__c 
                where
                    Name = :sourceObjectTypeName];

            vlocity_cmt__ObjectClass__c targetObjectType = [
                select 
                    Id, 
                    Name
                from
                    vlocity_cmt__ObjectClass__c 
                where
                    Name = :targetObjectTypeName];

            System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtils > replicateLayout: sourceObjectType = ' + sourceObjectType);
            System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtils > replicateLayout: targetObjectType = ' + targetObjectType);

            //remove currently configured layouts for the target object type
            removeConfiguredLayout(targetObjectTypeName);

            //collect references to layouts, facets, sections and elements to clone
            List<vlocity_cmt__ObjectLayout__c> sourceObjectLayoutList = [
                select 
                    Id,
                    Name,
                    vlocity_cmt__IsActive__c,
                    vlocity_cmt__IsDefault__c,
                    vlocity_cmt__ObjectClassId__c,
                    vlocity_cmt__ObjectClassId__r.Name,
                    vlocity_cmt__SubclassId__c
                from 
                    vlocity_cmt__ObjectLayout__c 
                where 
                    (vlocity_cmt__ObjectClassId__c = :sourceObjectType.Id 
                    and vlocity_cmt__SubclassId__c = NULL) 
                    or (vlocity_cmt__ObjectClassId__r.Name = 'Product2 Object'
                    and vlocity_cmt__SubclassId__c = :sourceObjectType.Id)
                limit 1];

            List<vlocity_cmt__ObjectFacet__c> sourceObjectFacetList = [
                select 
                    Id,
                    Name,
                    vlocity_cmt__Sequence__c,
                    vlocity_cmt__ObjectLayoutId__c,
                    vlocity_cmt__FacetId__c,
                    vlocity_cmt__FacetId__r.Name
                from
                    vlocity_cmt__ObjectFacet__c
                where
                    vlocity_cmt__ObjectLayoutId__c in :sourceObjectLayoutList
            ];

            List <vlocity_cmt__ObjectSection__c> sourceObjectSectionList = [
                    select
                        Id,
                        Name,
                        vlocity_cmt__ObjectFacetId__c,
                        vlocity_cmt__Sequence__c,
                        vlocity_cmt__SectionId__c,
                        vlocity_cmt__SectionId__r.Name,
                        vlocity_cmt__ViewType__c,
                        vlocity_cmt__ViewUri__c
                    from
                        vlocity_cmt__ObjectSection__c
                    where 
                        vlocity_cmt__ObjectFacetId__c in :sourceObjectFacetList
                ];

            List <vlocity_cmt__ObjectElement__c> sourceObjectElementList = [
                        select
                            id,
                            name,
                            vlocity_cmt__ObjectSectionId__c,
                            vlocity_cmt__Sequence__c,
                            vlocity_cmt__FieldApiName__c,
                            vlocity_cmt__AttributeId__c,
                            vlocity_cmt__IsRequired__c
                        from
                            vlocity_cmt__ObjectElement__c
                        where 
                            vlocity_cmt__ObjectSectionId__c in :sourceObjectSectionList
                    ];

            System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtils > replicateLayout: sourceObjectLayoutList = ' + sourceObjectLayoutList);
            System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtils > replicateLayout: sourceObjectFacetList = ' + sourceObjectFacetList);
            System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtils > replicateLayout: sourceObjectSectionList = ' + sourceObjectSectionList);
            System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtils > replicateLayout: sourceObjectElementList = ' + sourceObjectElementList);

            //source data valiation
            if (sourceObjectLayoutList.size() == 0) {
                System.debug(LoggingLevel.ERROR, 'OtterTools > OtterEPCUtils > replicateLayout: ' + 'The source object type does not have any layouts configured. Please configure or import source layouts before executing the operation');
            }

            if (sourceObjectLayoutList.size() > 1) {
                System.debug(LoggingLevel.ERROR, 'OtterTools > OtterEPCUtils > replicateLayout: ' + 'The source object type has more than one layouts configured. Please clean the configuration before executing the operation');
            }

            //cloning business logic (bulk)
            //cloning object layouts
            vlocity_cmt__ObjectLayout__c sourceObjectLayout = sourceObjectLayoutList[0];
            vlocity_cmt__ObjectLayout__c clonedSourceLayout = sourceObjectLayout.clone(preserveId, isDeepClone, preserveReadonlyTimestamps, preserveAutonumber);
            clonedSourceLayout.name = '(Reinherited) ' + targetObjectTypeName + ' Layout from ' + sourceObjectTypeName;
            clonedSourceLayout.name = clonedSourceLayout.name.left(80); //trim layout name due to managed package limitations
            clonedSourceLayout.vlocity_cmt__SubclassId__c = targetObjectType.Id;
            objectLayoutsForInsert.add(clonedSourceLayout);

            insert objectLayoutsForInsert;

            //cloning object facets
            for (vlocity_cmt__ObjectFacet__c ofc : sourceObjectFacetList) {
                System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtils > replicateLayout: currently clone ObjectFacet = ' + ofc);
                vlocity_cmt__ObjectFacet__c clonedOfc = ofc.clone(preserveId, isDeepClone, preserveReadonlyTimestamps, preserveAutonumber);
                clonedOfc.name = '(Reinherited) ' + ofc.vlocity_cmt__FacetId__r.Name + ' Facet from ' + sourceObjectTypeName;
                clonedOfc.name = clonedOfc.name.left(80); //trim layout name due to managed package limitations
                clonedOfc.vlocity_cmt__ObjectLayoutId__c = clonedSourceLayout.Id; 
                objectFacetsForInsert.add(clonedOfc);

                sourceObjectFacetIdToClonedObjectFacet.put(ofc.Id, clonedOfc);
            }

            insert objectFacetsForInsert;

            //cloning object sections
            for (vlocity_cmt__ObjectSection__c os : sourceObjectSectionList) {
                System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtils > replicateLayout: currently clone ObjectSection = ' + os);
                vlocity_cmt__ObjectSection__c clonedOs = os.clone(preserveId, isDeepClone, preserveReadonlyTimestamps, preserveAutonumber);
                clonedOs.name = '(Reinherited) ' + os.vlocity_cmt__SectionId__r.Name + ' Section from ' + sourceObjectTypeName;
                clonedOs.name = clonedOs.name.left(80); //trim layout name due to managed package limitations
                clonedOs.vlocity_cmt__ObjectFacetId__c = ((vlocity_cmt__ObjectFacet__c) sourceObjectFacetIdToClonedObjectFacet.get(os.vlocity_cmt__ObjectFacetId__c)).Id;
                objectSectionsForInsert.add(clonedOs);

                sourceObjectSectionIdToClonedObjectSection.put(os.Id, clonedOs);
            }

            insert objectSectionsForInsert;

            //cloning object elements
            for (vlocity_cmt__ObjectElement__c oe : sourceObjectElementList) {
                System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtils > replicateLayout: currently clone ObjectElement = ' + oe);
                vlocity_cmt__ObjectElement__c clonedOe = oe.clone(preserveId, isDeepClone, preserveReadonlyTimestamps, preserveAutonumber);
                clonedOe.vlocity_cmt__ObjectSectionId__c = ((vlocity_cmt__ObjectSection__c) sourceObjectSectionIdToClonedObjectSection.get(oe.vlocity_cmt__ObjectSectionId__c)).Id;
                objectElementsForInsert.add(clonedOe);
            }

            insert objectElementsForInsert;

            System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtils > replicateLayout: ' + 'Layout is successfully cloned');
        }
        catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterEPCUtils > replicateLayout: exception = ' + e);
            return;
        }
    }

    /***************************************************************************************************************
    * @description removes currently configured layout for the given object type
    * @param object type (String)
    * @return nothing
    * @example
    *   String objectTypeName = 'PoP Physical Resource Object Type';
    *   OtterEPCUtils.replicateLayout(objectTypeName);
    */

    public static void enrichAttributesSection(String objectTypeName) {
        try {

            //String objectTypeName = 'Steroids Child Object Type';

            vlocity_cmt__ObjectClass__c objectType = [
                select 
                    Id, 
                    Name
                from
                    vlocity_cmt__ObjectClass__c 
                where
                    Name = :objectTypeName];

            System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtils > enrichAttributesSection: objectType = ' + objectType);

            vlocity_cmt__ObjectFacet__c generalPropertiesFacet = [
                select 
                    Id,
                    Name,
                    vlocity_cmt__Sequence__c,
                    vlocity_cmt__ObjectLayoutId__c,
                    vlocity_cmt__FacetId__c,
                    vlocity_cmt__FacetId__r.Name,
                    vlocity_cmt__ObjectLayoutId__r.vlocity_cmt__ObjectClassId__r.Name,
                    vlocity_cmt__ObjectLayoutId__r.vlocity_cmt__SubclassId__c 
                from
                    vlocity_cmt__ObjectFacet__c
                where
                    vlocity_cmt__FacetId__r.Name = 'General Properties'
                    and (vlocity_cmt__ObjectLayoutId__r.vlocity_cmt__ObjectClassId__r.Name = 'Product2 Object'
                    and vlocity_cmt__ObjectLayoutId__r.vlocity_cmt__SubclassId__c = :objectType.Id)
                ];

            System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtils > enrichAttributesSection: obgeneralPropertiesFacetjectType = ' + generalPropertiesFacet);

            vlocity_cmt__ObjectSection__c additionalPropertiesObjectSection = new vlocity_cmt__ObjectSection__c();
            additionalPropertiesObjectSection.Name = '(Enriched) Additional Properties Section';
            additionalPropertiesObjectSection.vlocity_cmt__Sequence__c = 1000;
            additionalPropertiesObjectSection.vlocity_cmt__SectionId__c = [select Id from vlocity_cmt__UISection__c where Name = 'Additional Properties' limit 1].Id;
            additionalPropertiesObjectSection.vlocity_cmt__ObjectFacetId__c = generalPropertiesFacet.Id;
            additionalPropertiesObjectSection.vlocity_cmt__ViewType__c = 'Field Layout';
            additionalPropertiesObjectSection.vlocity_cmt__ViewUri__c = '';

            insert additionalPropertiesObjectSection;

            System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtils > enrichAttributesSection: additionalPropertiesObjectSection = ' + additionalPropertiesObjectSection);

            List<vlocity_cmt__ObjectFieldAttribute__c> directlyAssignedAttributesList = [
                select 
                    Id,
                    Name,
                    vlocity_cmt__AttributeId__c,
                    vlocity_cmt__AttributeId__r.Name,
                    vlocity_cmt__AttributeId__r.vlocity_cmt__DisplaySequence__c,
                    vlocity_cmt__FieldApiName__c,
                    vlocity_cmt__ObjectClassId__c,
                    vlocity_cmt__ObjectType__c,
                    vlocity_cmt__SubClassId__c,
                    vlocity_cmt__ObjectClassId__r.Name
                from 
                    vlocity_cmt__ObjectFieldAttribute__c
                where 
                    vlocity_cmt__ObjectClassId__c = :objectType.Id
                    and vlocity_cmt__ObjectType__c = 'vlocity_cmt__ObjectClass__c'
                    and vlocity_cmt__AttributeId__c != null
                ];
            
            List <vlocity_cmt__ObjectElement__c> objectElementsForInsert = new List <vlocity_cmt__ObjectElement__c>();

            for (vlocity_cmt__ObjectFieldAttribute__c ofa : directlyAssignedAttributesList) {

                vlocity_cmt__ObjectElement__c oe = new vlocity_cmt__ObjectElement__c();
                oe.Name = ofa.vlocity_cmt__AttributeId__r.Name;
                oe.vlocity_cmt__ObjectSectionId__c = additionalPropertiesObjectSection.Id;
                oe.vlocity_cmt__Sequence__c = ofa.vlocity_cmt__AttributeId__r.vlocity_cmt__DisplaySequence__c;
                oe.vlocity_cmt__FieldApiName__c = '';
                oe.vlocity_cmt__AttributeId__c = ofa.vlocity_cmt__AttributeId__c;
                oe.vlocity_cmt__IsRequired__c = false;

                objectElementsForInsert.add(oe);
            }

            insert objectElementsForInsert;

            System.debug(LoggingLevel.INFO, 'OtterTools > OtterEPCUtils > enrichAttributesSection: ' + 'Additional Properties Section is added');
        }
        catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterEPCUtils > enrichAttributesSection: exception = ' + e);
            return;
        }
    }

    /***************************************************************************************************************
    * @description initiates a job to regenerate JSONAttribute__c for a set of products
    * @param product codes (list of strings)
    * @return nothing
    * @example
    *   List<String> productCodes = new List<String> {
    *    'ACC_OFFER_MANAGED_WAN_PREMIUM',
    *    'ACC_OFFER_MANAGED_WAN_STANDARD',
    *    'ACC_OFFER_MANAGED_WAN_BASE'
    *   };
    *   OtterEPCtils.regenerateJsonAttributes(productCodes);
    */

    public static String regenerateJsonAttributes (List<String> productCodes) {
        List<Product2> productRecordList = [
            select
                Id,
                Name,
                ProductCode,
                vlocity_cmt__JSONAttribute__c
            from
                Product2
            where
                ProductCode in :productCodes
                and ProductCode != null
            LIMIT 10000
        ];

        List<Id> productIds = new List<Id>();

        for (Product2 prod : productRecordList) {
            prod.vlocity_cmt__JSONAttribute__c = 'JSONAttribute refresh job successfully started. Please allow some processing time to see the results in user interface';
            productIds.add(prod.Id);
        }

        update productRecordList;

        Database.executeBatch(new vlocity_cmt.EPCProductAttribJSONBatchJob(productIds), 1);

        System.debug(LoggingLevel.INFO, 'JSONAttribute refresh job successfully started. Please allow some processing time to see the results in user interface');
        System.debug(LoggingLevel.INFO, 'JSONAttribute will be refreshed for ' + productRecordList.size() + ' product records');

        return 'JSONAttribute will be refreshed for ' + productRecordList.size() + ' product records';
    }

    /***************************************************************************************************************
    * @description resets platform cache to ensure CPQ consumes the most recent catalog configuration
    * @param nothing
    * @return confirmation message
    * @example
    *   
    *   OtterEPCtils.clearPlatformCache();
    */

    public static String clearPlatformCache () {

        vlocity_cmt.TelcoAdminConsoleController adminCntrlr = new vlocity_cmt.TelcoAdminConsoleController();
        adminCntrlr.setParameters('{"methodName":"clearPlatformCache"}');
        adminCntrlr.invokeMethod();

        String result = 'Clear platform cache job successfully started. Please allow some processing time to see the results in user interface';

        System.debug(LoggingLevel.INFO, result);
        return result;
    }
    
}