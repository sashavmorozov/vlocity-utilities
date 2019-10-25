/*******************************************************************
* Class Name        :   XOMAutoTask_AutoTaskTemplate
* Usage             :   Serves as a template for an Apex class implementing an automated process
* Author            :   Alexander Morozov
* Last Modified By  :   Alexander Morozov 01-march-2019
* Version           :   1.0
* Methods           :   executeBatch()
* 
*******************************************************************/

global class XOMAutoTask_AutoTaskTemplate implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {

    /***************************************************************************************************************
    * @description Implements business logic. This is a template that does not implement any logic 
    * @param List of orchestration items (auto-tasks)
    * @return Nothing, business logic is executed
    * @example
    *
    * Not invoked directly but rather called by Vlocity XOM orchestration engine
    */

    global void executeBatch(List <vlocity_cmt__OrchestrationItem__c> items) {

        System.debug(LoggingLevel.INFO, 'Custom>DEBUG>XOMAutoTask_AutoTaskTemplate: Method Entry');

        //retrieve additional information for orchestration items: order Id, account Id
        List <vlocity_cmt__OrchestrationItem__c> itemsExt = [
            select 
                Id,
                vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c,
                vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.AccountId
            from 
                vlocity_cmt__OrchestrationItem__c where Id in :items];

        for (vlocity_cmt__OrchestrationItem__c item : itemsExt) {

            /* your custom logic here */

        }    

        System.debug(LoggingLevel.INFO, 'Custom>DEBUG>XOMAutoTask_AutoTaskTemplate: Method Exit');
    }
}