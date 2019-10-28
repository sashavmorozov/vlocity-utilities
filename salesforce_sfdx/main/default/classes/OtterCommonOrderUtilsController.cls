public class OtterCommonOrderUtilsController {
    public Id Id { get; set; }
    public Order inputOrder { get; set; }

    public OtterCommonOrderUtilsController(ApexPages.StandardController controller) {
        inputOrder =  (Order) controller.getRecord();
        Id = inputOrder.Id;
    }

    public PageReference cloneOrderWithLineItems() {
        String clonedOrderId = OtterCommonOrderUtils.cloneOrderWithLineItems(String.valueOf(inputOrder.Id));
        PageReference pageRef;
        if (!String.isBlank(clonedOrderId)) {
                pageRef = new PageReference('/' + clonedOrderId);
            }
        else {
            pageRef = new PageReference('/' + inputOrder.Id);
        }
        pageRef.setRedirect(true);

        return pageRef;
    }

}