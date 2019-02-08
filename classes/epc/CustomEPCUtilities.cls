/**
 * @Author: amorozov@vlocity.com
 * @Date:   2019-02-08T15:05:28+01:00
 * @Filename: CustomEPCUtilities.cls
 * @Description: This is a utilities class aimed to facilitate EPC configuration process. This is a dev toolkit class, not a part of Vlocity product
 */

global with sharing class CustomEPCUtilities {

    public CustomEPCUtilities() {
        System.debug(LoggingLevel.INFO, 'Tools>EPC>CustomEPCUtilities>constructor: nothing to do here');
    }

    /***************************************************************************************************************
    * @description generate default pricelist entries for product records created in EPC. Please look into productsWithoutPrices variable to accurately define set of offerings to process (all offers by default)
    * @param defaultPriceListName, defaultCurrencyCode, defaultPricingVariableName (One Time Std Price OR Recurring Monthly Std Price)
    * @return nothing
    * @example
    *
    * generateDefaultPriclistEntries('Inwi 2018 Price List', 'MAD', 'One Time Std Price', 'Offer');
    * generateDefaultPriclistEntries('Inwi 2018 Price List', 'MAD', 'Recurring Monthly Std Price', 'Offer');
    */
    public static void generateDefaultPriclistEntries(
        String defaultPriceListName,
        String defaultCurrencyCode,
        String defaultPricingVariableName,
        String defaultSpecificationType) {
        
        Datetime defaultEffectiveFromDate = Datetime.newInstance(2019, 1, 1, 12, 30, 0); //year, month, day, hours, minutes, seconds

        vlocity_cmt__PriceList__c defaultPriceList;
        vlocity_cmt__PricingVariable__c defaultPricingVariable;
        vlocity_cmt__PricingElement__c defaultPricingElement;

        List<vlocity_cmt__PriceList__c> defaultPriceListList = [
            select
                Id, 
                Name 
            from 
                vlocity_cmt__PriceList__c
            where
                Name = :defaultPriceListName
            limit 1
        ];

        if (defaultPriceListList.size() > 0) {
            defaultPriceList = defaultPriceListList[0];
        } else {
            System.debug(LoggingLevel.ERROR, 'Tools>EPC>generateDefaultPriclistEntries: default pricelist is not found');
            return;
        }

        List<vlocity_cmt__PricingVariable__c> defaultPricingVariableList = [
            select
                Id, 
                Name 
            from 
                vlocity_cmt__PricingVariable__c
            where
                name = :defaultPricingVariableName
            limit 1
        ];

        if (defaultPricingVariableList.size() > 0) {
            defaultPricingVariable = defaultPricingVariableList[0];
        } else {
            System.debug(LoggingLevel.ERROR, 'Tools>EPC>generateDefaultPriclistEntries: default default pricing variable is not found');
            return;
        }

        List<vlocity_cmt__PricingElement__c> defaultPricingElementList = [
            select
                Id, 
                Name,
                vlocity_cmt__Amount__c,
                vlocity_cmt__DisplayText__c
            from 
                vlocity_cmt__PricingElement__c
            where
                vlocity_cmt__CurrencyCode__c = :defaultCurrencyCode
                and vlocity_cmt__PriceListId__c = :defaultPriceList.Id
                and vlocity_cmt__PricingVariableId__c = :defaultPricingVariable.Id
                and vlocity_cmt__Amount__c = 0
                and vlocity_cmt__IsActive__c = true
            limit 1
        ];

        if (defaultPricingElementList.size() > 0) {
            defaultPricingElement = defaultPricingElementList[0];
        } else {
            System.debug(LoggingLevel.ERROR, 'Tools>EPC>generateDefaultPriclistEntries: default default pricing element is not found');
            return;
        }

        System.debug(LoggingLevel.INFO, 'Tools>EPC>generateDefaultPriclistEntries: defaultPriceList: ' + defaultPriceList);
        System.debug(LoggingLevel.INFO, 'Tools>EPC>generateDefaultPriclistEntries: defaultPricingVariable: ' + defaultPricingVariable);
        System.debug(LoggingLevel.INFO, 'Tools>EPC>generateDefaultPriclistEntries: defaultPricingElement: ' + defaultPricingElement);

        /*
            The query selects all offers which do not have associated pricelist entries yet.
            Add filters to adjust the query as you need
        */ 
        List <Product2> productsWithoutPrices = [
            select
                Id, 
                Name 
            from 
                Product2
            where
                Id not in (select vlocity_cmt__ProductId__c from vlocity_cmt__PriceListEntry__c) 
                and vlocity_cmt__SpecificationType__c = :defaultSpecificationType
                and ProductCode like 'TEST%'
        ];

        List <vlocity_cmt__PriceListEntry__c> priceListEntries = new List <vlocity_cmt__PriceListEntry__c>();

        for (Product2 p: productsWithoutPrices) {
            vlocity_cmt__PriceListEntry__c ple = new vlocity_cmt__PriceListEntry__c();

            ple.vlocity_cmt__ProductId__c = p.Id;
            ple.vlocity_cmt__IsActive__c = true;
            ple.vlocity_cmt__IsBasePrice__c = true;
            ple.vlocity_cmt__IsVirtualPrice__c = false;
            ple.vlocity_cmt__EffectiveFromDate__c = defaultEffectiveFromDate;
            ple.vlocity_cmt__PriceListId__c = defaultPriceList.Id;
            ple.vlocity_cmt__PricingElementId__c = defaultPricingElement.Id;
            ple.vlocity_cmt__DisplayText__c = defaultPricingElement.vlocity_cmt__DisplayText__c;
            ple.Name = 'Auto-generated: ' + ple.vlocity_cmt__ProductId__c + '_' + ple.vlocity_cmt__PricingElementId__c;
            
            priceListEntries.add(ple);
        }

        System.debug(LoggingLevel.INFO, 'Tools>EPC>generateDefaultPriclistEntries: pricelist entries to be inserted: ' + priceListEntries.size());
        System.debug(LoggingLevel.INFO, 'Tools>EPC>generateDefaultPriclistEntries: pricelist entries to be inserted for products: ' + productsWithoutPrices);
        System.debug(LoggingLevel.INFO, 'Tools>EPC>generateDefaultPriclistEntries: priceListEntries: ' + priceListEntries);
        
        try {
            insert priceListEntries;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Tools>EPC>generateDefaultPriclistEntries: something went really wrong');
        }
    }
}
