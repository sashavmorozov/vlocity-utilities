public with sharing class OtterDataGenerator implements Queueable {



    public void execute(QueueableContext context) {

    }

    public static void cloneOrder(Integer numberOfClones) {
        String vpnOrderTemplate = '801090000028d3uAAA';
        String batchId = String.valueOf(DateTime.now().getTime());

        for (Integer i = 0; i < numberOfClones; i++){
            List<String> orderTemplateIds = new List<String> {
                '801d1000001owWbAAI',
                '801d1000001owWcAAI',
                '801d1000001p56mAAA'

            };
    
            String orderTemplateId = orderTemplateIds[Integer.valueOf(Math.random() * orderTemplateIds.size())];
    
            Id clonedOrderId = OtterCommonOrderUtils.cloneOrderWithLineItems(orderTemplateId);
            Order clonedOrder = [select Id, Name, AccountId from Order where Id = :clonedOrderId];
            List<Account> accountsList = [select Id, Name from Account limit 25];
            Account a = accountsList[Integer.valueof((Math.random() * accountsList.size()))];
            clonedOrder.AccountId = a.Id;
    
            clonedOrder.Name = 'Customer order';
            clonedOrder.PoNumber = 'Cloned Order batch ' + batchId;
    
            Integer dateOffset = Integer.valueof((Math.random() * 2 * 31)); //plus-minus 3 months
            clonedOrder.EffectiveDate = date.today() - 100 + dateOffset;
    
    
            /* update cloned order items to link to the new account */
            List<OrderItem> clonedOrderItems = [select Id, vlocity_cmt__BillingAccountId__c, vlocity_cmt__ServiceAccountId__c
            from OrderItem where OrderId = :clonedOrderId];
    
            for (OrderItem clonedOrderItem : clonedOrderItems) {
                clonedOrderItem.vlocity_cmt__BillingAccountId__c = a.Id;
                clonedOrderItem.vlocity_cmt__ServiceAccountId__c = a.Id;
                clonedOrderItem.vlocity_cmt__AssetReferenceId__c = UUIDGenerator.generateUUIDv4();
            }
    
            update clonedOrderItems;
    
            System.debug('******** ' + 'Added a new order for ' + a.Name + ' using ' + orderTemplateId);
    
            update clonedOrder;
        }
        
    }


    public static void forceSubmitOrdersSync(List<Order> customerOrdersList) {
        for (Order o: customerOrdersList) {
            Map<String, Object> outputMap = new Map<String, Object>();
            OtterXOMOrderUtils.submitOrderSync(o.Id, outputMap);
        }
    }

    public static void forceSubmitOrdersAsync(List<Order> customerOrdersList) {
        for (Order o: customerOrdersList) {
            Map<String, Object> outputMap = new Map<String, Object>();
            OtterXOMOrderUtils.submitOrderAsync(o.Id, outputMap);
        }
    }

    /**
     * This method forces the completion of orchestration items related to a list of customer orders, 
     * except the assetizations tasks. The remaining assetization tasks will be executed by the orchestration 
     * engine and create assets.
     * It retrieves the orchestration plans associated with the provided orders, identifies orchestration 
     * items that are not completed and not related to specific implementations, and marks them as 'Skipped'.
     * 
     * @param customerOrdersList A list of (submitted) Order objects for which the related orchestration items need to be forced to skip.
     * 
     * The method performs the following operations:
     * 1. Queries the provided list of orders to retrieve their associated Orchestration Plan IDs.
     * 2. Uses these Orchestration Plan IDs to find associated orchestration items that are not yet completed 
     *    and are not related to the 'AssetizeOrderItem' or 'Assetize' implementations.
     * 3. Marks the identified orchestration items as 'Skipped' and updates them in the database.
     */
    public static void forceAssetizeOrders(List<Order> customerOrdersList) {
        List<Order> customerOrdersListExt = [select Id, vlocity_cmt__OrchestrationPlanId__r.Id from Order where Id in :customerOrdersList];
        List<Id> orchestrationPlansIds = new List<Id>();

        for (Order o : customerOrdersListExt) {
            orchestrationPlansIds.add(o.vlocity_cmt__OrchestrationPlanId__r.Id);
        }

        List<vlocity_cmt__OrchestrationItem__c> orchestrationItemsToComplete = [
            SELECT 
                Id, 
                Name, 
                vlocity_cmt__State__c,
                vlocity_cmt__ItemImplementationId__r.Name
            FROM 
                vlocity_cmt__OrchestrationItem__c 
            WHERE
                vlocity_cmt__OrchestrationPlanId__c in :orchestrationPlansIds
                AND vlocity_cmt__State__c != 'Completed'
                AND vlocity_cmt__State__c != 'Skipped'
                AND (
                    vlocity_cmt__ItemImplementationId__r.Name != 'AssetizeOrderItem'
                    AND vlocity_cmt__ItemImplementationId__r.Name != 'Assetize'
                )
        ];


        for (vlocity_cmt__OrchestrationItem__c orchestrationItem : orchestrationItemsToComplete) {
            System.debug('*** OtterDataGenerator: force skipping ' + orchestrationItem.Name + ' (' + orchestrationItem.Id + ')');
            orchestrationItem.vlocity_cmt__State__c = 'Skipped';
        }

        update orchestrationItemsToComplete;

        List<vlocity_cmt__OrchestrationItem__c> failedAssetizeOrchestrationItemsToRetry = [
            SELECT 
                Id, 
                Name, 
                vlocity_cmt__State__c,
                vlocity_cmt__ItemImplementationId__r.Name
            FROM 
                vlocity_cmt__OrchestrationItem__c 
            WHERE
                vlocity_cmt__OrchestrationPlanId__c in :orchestrationPlansIds
                AND vlocity_cmt__State__c like '%Failed%'
                AND (
                    vlocity_cmt__ItemImplementationId__r.Name = 'AssetizeOrderItem'
                    OR vlocity_cmt__ItemImplementationId__r.Name = 'Assetize'
                )
        ];

        for (vlocity_cmt__OrchestrationItem__c orchestrationItem : failedAssetizeOrchestrationItemsToRetry) {
            System.debug('*** OtterDataGenerator: force ready ' + orchestrationItem.Name + ' (' + orchestrationItem.Id + ')');
            orchestrationItem.vlocity_cmt__State__c = 'Ready';
        }

        update failedAssetizeOrchestrationItemsToRetry;
    }

    public void execute2(QueueableContext context) {
        /* Clone an order template and submit to Vlocity XOM */

        String vpnOrderTemplate = '801090000028d3uAAA';

        List<String> orderTemplateIds = new List<String> {
            '801d1000001hqCVAAY'
        };

        String orderTemplateId = orderTemplateIds[Integer.valueOf(Math.random() * orderTemplateIds.size())];

        Id clonedOrderId = OtterCommonOrderUtils.cloneOrderWithLineItems(orderTemplateId);
        Order clonedOrder = [select Id, Name, AccountId from Order where Id = :clonedOrderId];
        List<Account> accountsList = [select Id, Name from Account limit 25];
        Account a = accountsList[Integer.valueof((Math.random() * accountsList.size()))];
        clonedOrder.AccountId = a.Id;

        clonedOrder.Name = 'Customer order';

        Integer dateOffset = Integer.valueof((Math.random() * 2 * 31)); //plus-minus 3 months
        clonedOrder.EffectiveDate = date.today() - 100 + dateOffset;


        /* update cloned order items to link to the new account */
        List<OrderItem> clonedOrderItems = [select Id, vlocity_cmt__BillingAccountId__c, vlocity_cmt__ServiceAccountId__c
        from OrderItem where OrderId = :clonedOrderId];

        for (OrderItem clonedOrderItem : clonedOrderItems) {
            clonedOrderItem.vlocity_cmt__BillingAccountId__c = a.Id;
            clonedOrderItem.vlocity_cmt__ServiceAccountId__c = a.Id;
        }

        update clonedOrderItems;

        System.debug('******** ' + 'Added a new order for ' + a.Name + ' using ' + orderTemplateId);

        update clonedOrder;

        Boolean isOmniScript = true;

        String result = vlocity_cmt.SimpleDecompositionController.decomposeAndCreatePlanEx(clonedOrderId, isOmniScript);


        /* Id clonedOrderId = '801d1000001hyefAAA';
        String result = vlocity_cmt.SimpleDecompositionController.decomposeAndCreatePlanEx(clonedOrderId, true);
        System.debug('*******' + result); */


        //Id clonedOrderId = '801d1000001hzinAAA';
        //String result = vlocity_cmt.SimpleDecompositionController.decomposeAndCreatePlanEx(clonedOrderId, true);
        Order o = [select Id, vlocity_cmt__OrchestrationPlanId__r.Id from Order where Id = :clonedOrderId];
        System.debug(o);

        List<vlocity_cmt__OrchestrationItem__c> orchestrationItemsToComplete = [
            SELECT 
                Id, Name, vlocity_cmt__State__c ,
                vlocity_cmt__ItemImplementationId__r.Name
            FROM 
                vlocity_cmt__OrchestrationItem__c 
            WHERE
                vlocity_cmt__OrchestrationPlanId__c = :o.vlocity_cmt__OrchestrationPlanId__c
                AND vlocity_cmt__State__c != 'Completed'
                AND vlocity_cmt__State__c != 'Skipped'
                AND (
                    vlocity_cmt__ItemImplementationId__r.Name != 'AssetizeOrderItem'
                    AND vlocity_cmt__ItemImplementationId__r.Name != 'Assetize'
                )
            LIMIT 100
        ];

        for (vlocity_cmt__OrchestrationItem__c orchestrationItem : orchestrationItemsToComplete) {
            System.debug(orchestrationItem.Name + ' ' + orchestrationItem.Id);
            orchestrationItem.vlocity_cmt__State__c = 'Skipped';
        }

        update orchestrationItemsToComplete;
    }

    public static void fixFulfillmentStatus() {
        List<Order> customerOrdersList = [select id, ordernumber from order where vlocity_cmt__FulfilmentStatus__c = ''];
        for (Order o: customerOrdersList) {
            o.vlocity_cmt__FulfilmentStatus__c = 'Draft';
        }

        update customerOrdersList;
    }
}