global abstract with sharing class OtterCommonOrderUtils {
    
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
    * @description clones a customer order record with order line items (order products). Returns Id of a cloned order record
    * @param orderId (String) to clone
    * @return Id of a created order record
    * @example
    *   OtterCommonOrderUtils.cloneOrderWithLineItems('8014J000000HOjxQAG')
    */

    public static Id cloneOrderWithLineItems(String orderId) {
        try {

            String ORDER_RECORD_TYPE            = 'Order';
            String ORDER_LINE_ITEM_RECORD_TYPE  = 'OrderItem';

            String orderSoql = vlocity_cmt.DBHelper.getBaseQuery(ORDER_RECORD_TYPE);
            orderSoql += ' where Id = \'' + orderId + '\'';
            Order originalOrder = Database.query(orderSoql);

            //clone order record (header)
            Order clonedOrder = originalOrder.clone();
            insert clonedOrder;

            String orderItemsSoql = vlocity_cmt.DBHelper.getBaseQuery(ORDER_LINE_ITEM_RECORD_TYPE);
            orderItemsSoql += ' where OrderId = \'' + orderId + '\'';
            List<OrderItem> originalOrderItems = Database.query(orderItemsSoql);
        
            //clone order items
            List<OrderItem> clonedOrderItems = new List<OrderItem>();
            for(OrderItem orderItem : originalOrderItems) {
                OrderItem tempOrderItem = orderItem.clone();
                tempOrderItem.orderId = clonedOrder.Id;
                clonedOrderItems.add(tempOrderItem);
            }
            
            if (clonedOrderItems.size() > 0) {
                insert clonedOrderItems;
            }

            return clonedOrder.Id;

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'OtterTools > OtterCommonOrderUtils > cloneOrderWithLineItems: something went wrong');
            return null;
        }

        
    }

}