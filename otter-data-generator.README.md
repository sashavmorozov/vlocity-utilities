## Salesforce Industries Sample Data Generator (Orders and Assets)

This tool simplifies the creation of sample data tailored to the Salesforce Industries product catalog. While not a one-click solution, it provides clear instructions to guide you through generating and submitting customer orders. You'll need to patiently execute anonymous Apex methods and set up a few custom classes, with all references provided. Currently, the tool supports customer orders only—quotes are not yet supported. To get started, you'll first need to create template customer orders, which will be cloned, submitted to COM, and assetized.

The tool is not tailored to clone ESM multi-site orders yet. Think about simpler single site orders.

## Required Classes

Take these classes and create them in your org (vlocity_cmt package is required, Comms IDO is a good org example)
* UUIDGenerator
* OtterXOMOrderUtils
* OtterDataGenerator

## Process

### Create a set of template customer orders
The data will be generated based on template customer orders: they will be cloned, submitted to COM and pushed to the assetization (see next steps). But you will need to create customer order templates yourself first. For that you will need a product catalog already set up (I assume this is already done).

1. Create a template customer account
2. Create a customer order
3. Open CPQ and add whatever products you need to represent what a customer typically orders
4. Do not submit this order, just leave it in draft, copy order Salesforce ID (e.g. `801d1000001owWbAAI`) into a notepad
5. Repeat steps 2-4 to create as many order templates as you need (e.g. separate templates for different flavors of internet, mobile, cloud, etc.)
6. 

### Update OtterDataGenerator with the created IDs
At this moment, the IDs are hardcoded into the class. Not fantastic but this is a quick and dirty approach to get started. Later on this may be taken out into a configuration. For now, you need to update the class:

1. Open the class
2. Look fot this piece of code and replace the IDs with the IDs from your template orders

```js
List<String> orderTemplateIds = new List<String> {
                '801d1000001owWbAAI',
                '801d1000001owWcAAI',
                '801d1000001p56mAAA'

            };
```
 3. Save the updated class to your org
 4. We are ready to generate some data now

### Clone the orders using your templates
Run this piece of code as an anonymous Apex. This will create a number of new customer orders (for randomly selected accounts) using the templates you created. Today the max number of clones you can create in a single transaction is `20`. Not much but a good start.
If you need to create 1000 orders - execute this piece 50 times, sequencially. Do not try to wrap it into a for-loop, this will likely fail.

Creating 20 clones will take about 20 seconds. 

```js
/* 
 * Clone orders using a set of template orders 
 * Can support up to 20 new orders at this moment
 * Need more orders? Execute this method sequencially as many times as needed
 */
 
OtterDataGenerator.cloneOrder(20);
```

The output will look like this
```
09:59:49.577 (7930513744)|USER_DEBUG|[48]|DEBUG|******** Added a new order for Smith - San Francisco Residence using 801d1000001owWbAAI
09:59:50.742 (8759399462)|USER_DEBUG|[48]|DEBUG|******** Added a new order for Smith - San Francisco Residence using 801d1000001owWbAAI
09:59:50.742 (9400485460)|USER_DEBUG|[48]|DEBUG|******** Added a new order for Allied Technologies using 801d1000001p56mAAA
09:59:51.803 (10012153453)|USER_DEBUG|[48]|DEBUG|******** Added a new order for AB Partners, Inc. using 801d1000001p56mAAA
09:59:52.818 (10835390957)|USER_DEBUG|[48]|DEBUG|******** Added a new order for AB Partners, Inc. using 801d1000001owWbAAI
09:59:52.818 (11445632968)|USER_DEBUG|[48]|DEBUG|******** Added a new order for Advanced Interconnections Corp using 801d1000001p56mAAA
09:59:53.850 (12046860795)|USER_DEBUG|[48]|DEBUG|******** Added a new order for Benjamin Young using 801d1000001owWcAAI
09:59:53.850 (12658315477)|USER_DEBUG|[48]|DEBUG|******** Added a new order for CPQ Temp Account using 801d1000001p56mAAA
09:59:55.18 (13209367732)|USER_DEBUG|[48]|DEBUG|******** Added a new order for Allied Technologies using 801d1000001owWcAAI
09:59:55.18 (14016500607)|USER_DEBUG|[48]|DEBUG|******** Added a new order for Allied Technologies using 801d1000001owWbAAI
09:59:56.29 (14814847159)|USER_DEBUG|[48]|DEBUG|******** Added a new order for Sustainable Audio* using 801d1000001owWbAAI
09:59:57.195 (15399674653)|USER_DEBUG|[48]|DEBUG|******** Added a new order for Employnet using 801d1000001p56mAAA
09:59:57.195 (15934956752)|USER_DEBUG|[48]|DEBUG|******** Added a new order for Benjamin Young using 801d1000001owWcAAI
09:59:58.343 (16532415814)|USER_DEBUG|[48]|DEBUG|******** Added a new order for Bob Warkentine using 801d1000001owWcAAI
09:59:59.367 (17383744876)|USER_DEBUG|[48]|DEBUG|******** Added a new order for CTW Resellers using 801d1000001owWbAAI
09:59:59.367 (18241605771)|USER_DEBUG|[48]|DEBUG|******** Added a new order for Data Mart using 801d1000001owWbAAI
10:00:00.383 (18891600187)|USER_DEBUG|[48]|DEBUG|******** Added a new order for Employnet using 801d1000001p56mAAA
10:00:01.460 (19477151532)|USER_DEBUG|[48]|DEBUG|******** Added a new order for Allied Technologies using 801d1000001owWcAAI
10:00:01.460 (20089992352)|USER_DEBUG|[48]|DEBUG|******** Added a new order for Aims Social using 801d1000001owWcAAI
10:00:02.673 (20991335197)|USER_DEBUG|[48]|DEBUG|******** Added a new order for Bronze Partners using 801d1000001owWbAAI
```

You can now open the list of orders in your org, sort them by Order Number and check the results
![image](https://github.com/user-attachments/assets/9cc30e43-2e3a-4df5-937f-ce14c835acbc)

Make sure that `Fulfilment Status` of the new orders appear as `Draft`. This should work but if you see empty status - run the following piece of code. This can update 1000+ orders in one go.
```js
/* Run this after creating all clones, just in case
 * Sometimes cloning leaves very important fields empty 🤷
 */
OtterDataGenerator.fixFulfillmentStatus(); //just in case
```


/*
 *
 * Submit cloned orders to COM
 * Async method
 * Can accept up to 50 orders in one go but works quite quickly
 * Creates async apex jobs for each order to submit (up to 50 jobs at a time)
 * If you see the jobs failing - try to reexecute
 * Can execute as many times as you want
 */
List<Order> customerOrdersList = [select id, ordernumber from order where vlocity_cmt__OrderStatus__c = 'Ready To Submit' and PoNumber like 'Cloned Order%' limit 50];

System.debug('**** To be submitted: ' + customerOrdersList.size() + ' orders');
for (order o: customerOrdersList) {
    System.debug('****     Order: ' + o.OrderNumber + ' / ' + o.Id);
}

OtterDataGenerator.forceSubmitOrdersAsync(customerOrdersList);




/*
 *
 * Force creation of customer assets
 * Sync method, just updates the tasks and let the assetization to take care of asset creation
 * Can accept a lot of orders
 * Assetization tasks themselves can fail in COM due to a lot of such requests happening in parallel
 * If you still see failed tasks - try reducing the limit in the query below
 */
List<Order> customerOrdersList = [select id, ordernumber from order where vlocity_cmt__FulfilmentStatus__c = 'In Progress' and PoNumber like 'Cloned Order%' limit 50];
system.debug(customerOrdersList);

OtterDataGenerator.forceAssetizeOrders(customerOrdersList);



////////////
list<asset> at = [select id, name, vlocity_cmt__AssetReferenceId__c from asset where vlocity_cmt__AssetReferenceId__c = '309fa779-5122-46c0-847b-c63b157d6215'];
System.debug(at);
