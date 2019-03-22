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
    * @param order SFDC ID
    * @return ID of the created SFDC job
    * @example
    *
    *   OtterXOMOrderUtils.submitOrderAsync('8011U000000HP5c')
    */

    public static Id submitOrderAsync(Id orderId) {
        AsyncOrderSubmissionJob submitOrderJob = new AsyncOrderSubmissionJob(orderId);
        Id jobId = System.enqueueJob(submitOrderJob);

        System.debug(LoggingLevel.ERROR, 'OtterTools > OtterXOMOrderUtils > submitOrderAsync: submission process for the order with Id ' + orderId + ' is scheduled. Follow the progress (and possible errors in Salesforce Job with Id ' + jobId);
        return jobId;
    }


    /***************************************************************************************************************
    * @description submits order for fulfillment in asynchronous mode
    * @param order SFDC ID
    * @return submission acknowledgement
    * @example
    *
    *   OtterXOMOrderUtils.submitOrderSync('8011U000000HP5c')
    */

    public static void submitOrderSync(Id orderId) {
        Boolean isOmniScript = true;

        if (!OtterXOMOrderUtils.validateOrderForSubmission(orderId)) {
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterXOMOrderUtils > submitOrderSync: the order with Id ' + orderId + ' cannot be submitted');
            return;
        }

        String result = vlocity_cmt.SimpleDecompositionController.decomposeAndCreatePlanEx(orderId, isOmniScript);
        System.debug(LoggingLevel.INFO, 'OtterTools > OtterXOMOrderUtils > submitOrderAsync: order submission result = ' + result);
    }

    /***************************************************************************************************************
    * @description checks if an order can be submitted. By default only order status is verified. Add custom logic here if required
    * @param order SFDC ID
    * @return true if an order can be submitted, false otherwise
    * @example
    *
    * OtterXOMOrderUtils.validateOrderForSubmission('8011U000000HP5c')
    */

    public static Boolean validateOrderForSubmission(Id orderId) {
        
        if (!OtterCommonUtils.isValidSalesforceId(orderId, Order.class)) {
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterXOMOrderUtils > submitOrderAsync: orderId ' + orderId + ' is not of the Order type');
            return false;
        }

        if (!OtterCommonUtils.isExistingRecord(orderId, Order.class)) {
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterXOMOrderUtils > submitOrderAsync: order with Id ' + orderId + ' does not exist');
            return false;
        }

        List<String >  fieldsToRetrieve = new List<String >  {'Id', 'vlocity_cmt__FulfilmentStatus__c'};
        Order order = (Order) OtterCommonUtils.retrieveSingleRecordById(orderId, Order.class, fieldsToRetrieve);

        if (order.vlocity_cmt__FulfilmentStatus__c != OtterXOMConstants.CONST_ORDER_FULFILLMENT_STATUS_DRAFT) {
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterXOMOrderUtils > validateOrderForSubmission: the order with Id ' + orderId + ' cannot be submitted because it is not in the Draft state');
            return false;
        }

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

        /***************************************************************************************************************
        * @description simple constructor
        * @param order Id
        * @return instance of the class
        * @example
        *   AsyncOrderSubmissionJob submitOrderJob = new AsyncOrderSubmissionJob('8011U000000HPw3');
        */

        public AsyncOrderSubmissionJob(Id orderId) {
            this.orderId = orderId;
        }

        /***************************************************************************************************************
        * @description job business logic
        * @param execution context
        * @return n/a
        * @example
        *   n/a, invoked by Salesforce job manager, not invoked directly from project code
        */

        public void execute(QueueableContext context) {
            submitOrderSync(this.orderId);       
        }

    }
    
}
