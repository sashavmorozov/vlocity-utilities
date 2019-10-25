/*******************************************************************
* Class Name        :   XOMAutoTask_InvokeIntegrationProcedure
* Usage             :   Invokes an integration procedure from an orchestration item (auto-task)
* Author            :   Alexander Morozov
* Last Modified By  :   Alexander Morozov 01-february-2019
* Version           :   1.0
* Methods           :   executeBatch()
* 
*******************************************************************/

global class XOMAutoTask_InvokeIntegrationProcedure implements %vlocity_namespace%.XOMOrchestrationInterfaces.IAutoTask {

    /***************************************************************************************************************
    * @description Executes auto-task business logic 
    * @param List of orchestration items (auto-tasks)
    * @return Nothing, business logic is executed
    * @example
    *
    * Not invoked directly but rather called by Vlocity XOM orchestration engine
    */

    global void executeBatch(List <%vlocity_namespace%__OrchestrationItem__c> items) {

        /* test data for troubleshooting */
        //List <%vlocity_namespace%__OrchestrationItem__c> items = [select Id from %vlocity_namespace%__OrchestrationItem__c where Id = 'a2O9E000000PRb6'];
        
        //retrieve additional information for orchestration items: order Id, account Id
        List <%vlocity_namespace%__OrchestrationItem__c> itemsExt = [
            select 
                Id,
                %vlocity_namespace%__OrchestrationPlanId__r.%vlocity_namespace%__OrderId__c,
                %vlocity_namespace%__OrchestrationPlanId__r.%vlocity_namespace%__OrderId__r.AccountId,
                %vlocity_namespace%__AutoTaskParameters__c
            from 
                %vlocity_namespace%__OrchestrationItem__c where Id in :items];

        for (%vlocity_namespace%__OrchestrationItem__c item : itemsExt) {        
            
            /* Initialize variables */
            String autotaskParametersString = item.%vlocity_namespace%__AutoTaskParameters__c;
            Map <String, Object> autotaskParametersMap = (Map <String, Object>) JSON.deserializeUntyped(autotaskParametersString);
            String procedureName = (String) autotaskParametersMap.get('procedureName');
            Map <String, Object> ipInput = new Map <String, Object> ();
            Map <String, Object> ipOutput = new Map <String, Object> ();
            Map <String, Object> ipOptions = new Map <String, Object> ();

            if (String.isBlank(procedureName)) {
                SObjectException e = new SObjectException();
                e.setMessage('Procedure name (procedureName) is not defined for the auto-task. Verify that the Auto Task Parameters field is properly populated');
                throw e;
            }

            /* Populating input map for an Integration Procedure. Follow whatever structure your VIP expects */
            /* If you need more input information for VIP, you can extend the code here. Alternatively, you can use dataraptors within your VIP to collect such information */
            ipInput.put('accountId',            item.%vlocity_namespace%__OrchestrationPlanId__r.%vlocity_namespace%__OrderId__r.AccountId);
            ipInput.put('orderId',              item.%vlocity_namespace%__OrchestrationPlanId__r.%vlocity_namespace%__OrderId__c);
            ipInput.put('orchestrationItemId',  item.Id);
            ipInput.put('orchestrationPlanId',  item.%vlocity_namespace%__OrchestrationPlanId__c);

            /* Call the IP via runIntegrationService, and save the output to ipOutput */
            ipOutput = (Map <String, Object>) %vlocity_namespace%.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);

            System.debug('Custom > DEBUG > XOMAutoTask_InvokeIntegrationProcedure: ipOutput = ' + ipOutput);
        }
    }
}