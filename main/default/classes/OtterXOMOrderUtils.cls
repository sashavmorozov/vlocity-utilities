global abstract with sharing class OtterXOMOrderUtils {
    
    /***************************************************************************************************************
    * @description brief description of method purpose
    * @param description of input parameters
    * @return description of output paramters
    * @example
    *
    * code snippet illustrating how to invoke the method
    */


    public void methodTemplate() {
        return;
    }

    /***************************************************************************************************************
    * @description submits order for fulfillment in asynchronous mode
    * @param order SFDC Id
    * @return Id of the scheduled job 
    * @example
    *
    *   Map<String, Object> outputMap = new Map<String, Object>();
    *   OtterXOMOrderUtils.submitOrderAsync('8011U000000HP5c', outputMap);
    */

    public static Id submitOrderAsync(Id orderId, Map<String, Object> outputMap) {
        AsyncOrderSubmissionJob submitOrderJob = new AsyncOrderSubmissionJob(orderId, outputMap);
        Id submitOrderJobId = System.enqueueJob(submitOrderJob);

        System.debug(LoggingLevel.ERROR, 'OtterTools > OtterXOMOrderUtils > submitOrderAsync: submission process for the order with Id ' + orderId + ' is scheduled. Follow the progress (and possible errors) in Salesforce Job with Id ' + submitOrderJobId);

        outputMap.put('submitOrderResult', OtterCommonConstants.CONST_SUCCESS);
        outputMap.put('submitOrderJobId', submitOrderJobId);
        outputMap.put('submitOrderMessage', 'Submission process for the order with Id ' + orderId + ' is scheduled. Follow the progress (and possible errors) in Salesforce Job with Id ' + submitOrderJobId);

        return submitOrderJobId;
    }


    /***************************************************************************************************************
    * @description submits order for fulfillment in synchronous mode
    * @param order SFDC Id
    * @return submission acknowledgement
    * @example
    *
    *   Map<String, Object> outputMap = new Map<String, Object>();
    *   OtterXOMOrderUtils.submitOrderSync('8011U000000HP5c', outputMap);
    */

    public static Boolean submitOrderSync(Id orderId, Map<String, Object> outputMap) {
        Boolean isOmniScript = true;
        String result = %vlocity_namespace%.SimpleDecompositionController.decomposeAndCreatePlanEx(orderId, isOmniScript);
        System.debug(LoggingLevel.INFO, 'OtterTools > OtterXOMOrderUtils > submitOrderAsync: order submission result = ' + result);

        outputMap.put('submitOrderResult', OtterCommonConstants.CONST_SUCCESS);
        outputMap.put('submitOrderJobId', null);
        outputMap.put('submitOrderMessage', 'Submission process for the order with Id ' + orderId + ' is completed');

        return true;
    }

    /***************************************************************************************************************
    * @description checks if an order can be submitted. By default only order status is verified. Add custom logic here if required
    * @param order SFDC Id
    * @return true if an order can be submitted, false otherwise
    * @example
    * 
    * Map<String, Object> outputMap = new Map<String, Object>();
    * OtterXOMOrderUtils.validateOrderForSubmission('8011U000000HP5c', outputMap);
    */

    public static Boolean validateOrderForSubmission(Id orderId, Map<String, Object> outputMap) {
        String validationMessage = 'The order with Id ' + orderId + ' can be submitted';

        if (!OtterCommonUtils.isValidSalesforceId(orderId, Order.class)) {
            validationMessage = 'Id ' + orderId + ' is not of the Order type';
            outputMap.put('validationMessage', validationMessage);
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterXOMOrderUtils > submitOrderAsync: ' + validationMessage);
            return false;
        }

        if (!OtterCommonUtils.isExistingRecord(orderId, Order.class)) {
            validationMessage = 'Order with Id ' + orderId + ' does not exist';
            outputMap.put('validationMessage', validationMessage);
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterXOMOrderUtils > submitOrderAsync: ' + validationMessage);
            return false;
        }

        List<String>  fieldsToRetrieve = new List<String>  {'Id', '%vlocity_namespace%__FulfilmentStatus__c'};
        Order order = (Order) OtterCommonUtils.retrieveSingleRecordById(orderId, Order.class, fieldsToRetrieve);

        //check order fulfillment status
        if (order.%vlocity_namespace%__FulfilmentStatus__c != OtterXOMConstants.CONST_ORDER_FULFILLMENT_STATUS_DRAFT) {
            validationMessage = 'The order with Id ' + orderId + ' cannot be submitted because it is not in the Draft state';
            outputMap.put('validationMessage', validationMessage);
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterXOMOrderUtils > validateOrderForSubmission: ' + validationMessage);
            return false;
        }

        //check that at least one order item is available in the order
        List<OrderItem> childOrderItemsList = [
            select
                Id
            from
                OrderItem
            where
                OrderId = :orderId
        ];

        if (childOrderItemsList.size() == 0) {
            validationMessage = 'The order with Id ' + orderId + ' cannot be submitted because it does not contain any order items';
            outputMap.put('validationMessage', validationMessage);
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterXOMOrderUtils > validateOrderForSubmission: ' + validationMessage);
            return false;
        }

        outputMap.put('validationMessage', validationMessage);
        return true;
    }


    /***************************************************************************************************************
    * @description a small nested class to initiate order submission in a queueable mode (asynchronously)
    * @param description of input parameters
    * @return description of output paramters
    * @example
    *
    *   code snippet illustrating how to invoke the method
    */

    public class AsyncOrderSubmissionJob implements Queueable {
        private Id orderId;
        private Map<String, Object> outputMap;

        /***************************************************************************************************************
        * @description simple constructor
        * @param order Id
        * @return instance of the class
        * @example
        *   AsyncOrderSubmissionJob submitOrderJob = new AsyncOrderSubmissionJob('8011U000000HPw3');
        */

        public AsyncOrderSubmissionJob(Id orderId, Map<String, Object> outputMap) {
            this.orderId = orderId;
            this.outputMap = outputMap;
        }

        /***************************************************************************************************************
        * @description job business logic
        * @param execution context
        * @return n/a
        * @example
        *   n/a, invoked by Salesforce job manager, not invoked directly from project code
        */

        public void execute(QueueableContext context) {
            submitOrderSync(this.orderId, this.outputMap);       
        }

    }
    
}