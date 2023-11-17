/** 
 * CONTEXT: You need to demonstrate price/cost/marging functionality but your catalog does not have cost details configured
 * PURPOSE: The script creates stub cost entries for a subset of products defined in Salesforce Industries product catalog. The cost entry is created only for products that have a configured price list entry in the specified price list
 * CONFIGURATION: See the "Script settings" section of the script where you can define certain properties of stub cost entries (adjust to fit your demo org)
 *  - fillerCurrencyCode: which currency to use for new stub cost entries to be created 
 *  - fillerPriceListName: in which price list new stub cost entries to be created
 *  - fillerPricingVariable: name of the pricing variable to use for new stub cost entries to be created
 *  - fillerAmount: charge amount for new stub cost entries to be created
 *  - maxNumberOfCostEntriesToCreate: in case you don't want to create a limited sample of data
 * 
 * HOW TO USE: Execute the script as anonymous apex using the preferred tool
 * ERRORS: If the script throws errors, ensure that the target price list and pricing variable exist in your org
 */

/* Script settings */
String fillerCurrencyCode = 'EUR';
String fillerPriceListName = 'Enterprise';
String fillerPricingVariableName = 'Recurring Monthly Std Cost';
Decimal fillerAmount = 345.67;
Datetime fillerDateTime = Datetime.newInstance(2023, 2, 21);
Integer maxNumberOfCostEntriesToCreate = 5; //in case you don't want to create a limited sample of data

Map<String, String> currencySymbolsByIsoCode = new Map<String, String>{
    'AUD' => 'A$',
    'AWG' => 'ƒ',
    'BDT' => '৳',
    'CAD' => 'CAD$',
    'CNY' => '¥',
    'CRC' => '₡',
    'DKK' => 'kr',
    'EGP' => '£',
    'EUR' => '€',
    'FKP' => '£',
    'GBP' => '£',
    'GIP' => '£',
    'ILS' => '₪',
    'INR' => '₹',
    'ISK' => 'kr',
    'JPY' => '¥',
    'JPY' => '¥',
    'KHR' => '៛',
    'KRW' => '₩',
    'KZT' => '₸',
    'LBP' => '£',
    'NGN' => '₦',
    'NOK' => 'kr',
    'PHP' => '₱',
    'PYG' => '₲',
    'RUB' => '₽',
    'SDG' => '£',
    'SEK' => 'kr',
    'SHP' => '£',
    'SYP' => '£',
    'TRY' => '₺',
    'USD' => '$',
    '' => '¤' // The currency sign ¤ is a character used to denote an unspecified currency.
};

Id fillerPricingVariableId = null;
List<vlocity_cmt__PricingVariable__c> fillerPricingVariable = [select Id from vlocity_cmt__PricingVariable__c where name = :fillerPricingVariableName limit 1];
if (fillerPricingVariable.size() > 0) {
    fillerPricingVariableId = fillerPricingVariable[0].Id;
} else {
    System.debug('ERROR: Specified target pricing variable does not exist (lookup by name): ' + fillerPricingVariableName);
}


Id fillerPriceListId = null;
List<vlocity_cmt__PriceList__c> fillerPriceList = [select Id from vlocity_cmt__PriceList__c where name = :fillerPriceListName limit 1];
if (fillerPriceList.size() > 0) {
    fillerPriceListId = fillerPriceList[0].Id;
} else {
    System.debug('ERROR: Specified target pricing variable does not exist (lookup by name): ' + fillerPriceListName);
}


Id fillerPricingElementId = null;
List<vlocity_cmt__PricingElement__c> fillerPricingElement = [select 
    Id 
  from 
    vlocity_cmt__PricingElement__c 
  where 
    vlocity_cmt__Amount__c = :fillerAmount 
    and vlocity_cmt__CurrencyCode__c = :fillerCurrencyCode
    and vlocity_cmt__PriceListId__c = :fillerPriceListId
  limit 
    1];

if (fillerPricingElement.size() > 0) {
    fillerPricingElementId = fillerPricingElement[0].Id;
} else {
    System.debug('INFO: Filler pricing element does not exist (lookup by currency code, amount and price list) and will be created');
}


/* Find or create the pricing element */
if (fillerPricingElementId == null) {    
    vlocity_cmt__PricingElement__c fillerPricingElement = new vlocity_cmt__PricingElement__c();
    fillerPricingElement.Name = 'Filler Element: ' + fillerPricingVariableName + ' ' + fillerAmount + ' ' + fillerCurrencyCode;
    fillerPricingElement.vlocity_cmt__Code__c = 'VEPC_PRICELIST_ENTRY_' + fillerPricingElement.Name.toUpperCase().replace(' ', '_').replace(':', '');
    fillerPricingElement.vlocity_cmt__PricingVariableId__c = fillerPricingVariableId;
    fillerPricingElement.vlocity_cmt__IsActive__c = true;
    fillerPricingElement.vlocity_cmt__Amount__c = fillerAmount;
    fillerPricingElement.vlocity_cmt__CurrencyCode__c = fillerCurrencyCode;
    fillerPricingElement.vlocity_cmt__PriceListId__c = fillerPriceListId;    

    System.debug('INFO: Added the filler pricing element: ' + fillerPricingElement);
    insert fillerPricingElement;
    fillerPricingElementId = fillerPricingElement.Id;
}

System.debug('INFO: Filler pricing element ID: ' + fillerPricingElementId);

/* Find all products with prices but without costs (only in the Enterprise pricelist) */
List <Product2> productsWithoutCost = [select 
  Id, 
  Name, 
  ProductCode
from
  Product2
where
  vlocity_cmt__SpecificationType__c = 'Offer'
  and id in (
    select 
      vlocity_cmt__ProductId__c 
    from 
      vlocity_cmt__PriceListEntry__c
    where
      vlocity_cmt__PriceListName__c = :fillerPriceListName
    )
  and id not in (
    select 
      vlocity_cmt__ProductId__c 
    from 
      vlocity_cmt__PriceListEntry__c
    where
      vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableType__c = 'Cost'
      and vlocity_cmt__PriceListName__c = :fillerPriceListName
    )
limit 
  :maxNumberOfCostEntriesToCreate];

System.debug('*** INFO: Products with price records in Enterprise pricelist but without cost (total): ' + productsWithoutCost.size());
System.debug('*** INFO: Products with price records in Enterprise pricelist but without cost: ' + productsWithoutCost);

List <vlocity_cmt__PriceListEntry__c> costPriceListEntries = new List <vlocity_cmt__PriceListEntry__c>();
for (Product2 p : productsWithoutCost) {
  
  vlocity_cmt__PriceListEntry__c costPriceListEntry = new vlocity_cmt__PriceListEntry__c();
  
  costPriceListEntry.vlocity_cmt__IsActive__c = true;
  costPriceListEntry.vlocity_cmt__IsBasePrice__c = true;
  costPriceListEntry.vlocity_cmt__IsOverride__c = false;
  costPriceListEntry.vlocity_cmt__IsVirtualPrice__c = false;
  costPriceListEntry.vlocity_cmt__PricingElementId__c = fillerPricingElementId;
  costPriceListEntry.vlocity_cmt__PriceListId__c = fillerPriceListId;
  costPriceListEntry.vlocity_cmt__BasePriceListId__c = fillerPriceListId;
  costPriceListEntry.vlocity_cmt__EffectiveFromDate__c = fillerDateTime;
  costPriceListEntry.vlocity_cmt__ProductId__c = p.Id;
  costPriceListEntry.vlocity_cmt__DisplayText__c = currencySymbolsByIsoCode.get(fillerCurrencyCode) + fillerAmount;

  costPriceListEntries.add(costPriceListEntry);

  System.debug('INFO: Cost entry added for ' + p.name + ' (' + p.ProductCode + ')');
}

insert costPriceListEntries;
