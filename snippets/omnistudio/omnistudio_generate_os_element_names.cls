
/** 
 * CONTEXT: You want to have logical names generated for your OmniScript elements instead of Text1, Text2, Radio9. Great when you want to polish your omniscript before releasing it
 * PURPOSE: The script assigns new names for OmniScript elements based on element name, type and parent element
 * CONFIGURATION: for safety reasons, this code is executed in the preview mode and WILL NOT apply the changes to the database. When you are satisfied with the expected results - uncomment the last line of the snippet
 * INPUT: 
 *  @param {String} omniScriptId - Salesforce Id of the omniscript record
 * HOW TO USE: Execute the script as anonymous apex using the preferred tool
 * ERRORS: not applicable
 */

 String omniScriptId = 'aBN8d000000XqOaGAK';

 list<vlocity_cmt__Element__c> omniscriptElementsList = 
 [
     select
         Id,
         Name,
         vlocity_cmt__Type__c,
         vlocity_cmt__OmniScriptId__c,
         vlocity_cmt__Order__c,
         vlocity_cmt__PropertySet__c,
         vlocity_cmt__ParentElementName__c,
         vlocity_cmt__ParentElementType__c,
         vlocity_cmt__ParentElementId__c,
         vlocity_cmt__ParentElementId__r.vlocity_cmt__PropertySet__c
         
 
     from
         vlocity_cmt__Element__c
     where
         vlocity_cmt__OmniScriptId__c = :omniScriptId
     limit 
         100
 ];
 
 for (vlocity_cmt__Element__c omniscriptElement : omniscriptElementsList) {
     //System.debug('Omniscript Element: ' + omniscriptElement);
 
     System.debug('Processing OmniScript Element ' + omniscriptElement.Id + ' (' + omniscriptElement.vlocity_cmt__Type__c + ')');
 
     String elementLabel;
     String parentElementLabel;
     String parentElementInsert = '';
 
     Map<String, Object> propertySetMap = (Map<String, Object>) JSON.deserializeUntyped(omniscriptElement.vlocity_cmt__PropertySet__c);
     elementLabel = (String) propertySetMap.get('label');
 
     if (omniscriptElement.vlocity_cmt__Type__c == 'Checkbox') {
         elementLabel = (String) propertySetMap.get('checkLabel');
     }
 
     if (elementLabel != null) {  
         //check the parent omniscript element. If the parent element exists it will be used to generate unique new names for the elements to be renamed
         if (omniscriptElement.vlocity_cmt__ParentElementId__c != null) {
             Map<String, Object> parentElementPropertySetMap = (Map<String, Object>) JSON.deserializeUntyped(omniscriptElement.vlocity_cmt__ParentElementId__r.vlocity_cmt__PropertySet__c);
             parentElementLabel = (String) parentElementPropertySetMap.get('label');
         }
 
         System.debug('Omniscript Element Label: ' + elementLabel);
         System.debug('Omniscript Element Parent Label: ' + parentElementLabel);
 
         if (parentElementLabel != null && omniscriptElement.vlocity_cmt__ParentElementType__c != 'Step') {
             parentElementInsert = parentElementLabel.replace(' ', '_') + '_';
         }
         
         String newName = omniscriptElement.vlocity_cmt__Type__c.replace(' ', '') + '_' + parentElementInsert + elementLabel.replace(' ', '_');
 
         
         if (omniscriptElement.vlocity_cmt__Type__c != 'Text Block') {
             //Text Blocks cannot be renamed automatically as they don't have labels
             System.debug('Omniscript Element Renaming: ' + omniscriptElement.Name + ' > ' + newName);
             omniscriptElement.Name = newName;
         }
     } else {
         System.debug('Omniscript Element Label: ' + 'label is empty, no basis for automatic element re-naming');
     }
 
 }
 
 //update omniscriptElementsList;