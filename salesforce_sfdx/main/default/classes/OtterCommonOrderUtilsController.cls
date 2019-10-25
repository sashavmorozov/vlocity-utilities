public class OtterCommonOrderUtilsController {
    public Id Id { get; set; }
    public Order inputOrder { get; set; }

    public OtterCommonOrderUtilsController(ApexPages.StandardController controller) {
        inputOrder =  (Order) controller.getRecord();
        Id = inputOrder.Id;
    }

    public PageReference cloneOrderWithLineItems() {
        String clonedOrderId = OtterCommonOrderUtils.cloneOrderWithLineItems(String.valueOf(inputOrder.Id));
        PageReference pageRef = new PageReference('/' + clonedOrderId);
        pageRef.setRedirect(true);

        return pageRef;
    }

}