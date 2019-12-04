/**
* @author amorozov@vlocity.com
* @date 2019
*
* @group Order Management
* @group-content n/a
*
* @description Class to model payload according to TMF641 Service Ordering API REST Specification R18.5.1 
* (refer to https://www.tmforum.org/resources/specification/tmf641-service-ordering-api-rest-specification-r18-5-0/
* for more details).
* The class supports both simple (text, integer, etc.) and complex (object) characteristics
*/

/* POST request should be used without specifying following attributes
 * These attributes will be defined by server side
 * - id
 * - href
 * - state
 * - orderDate
 * - completionDate (once service order completed)
 * - expectedCompletionDate
 * - startDate
 * - orderItem.state
*/


public class TMF641ServiceOrderRequest {

    public String category;
    public String completionDate;
    public String description;
    public String expectedCompletionDate;
    public String externalId;
    public String href;
    public String id;
    public List<Note> note;
    //public List<Object> notificationContact;
    public String orderDate;
    public List<OrderItem> orderItem;
    //public List<Object> orderRelationship;
    public String priority;
    public List<RelatedParty> relatedParty;
    public String requestedCompletionDate;
    public String requestedStartDate;
    public String startDate;
    public String state;
    public String type;

    /***************************************************************************************************************
     * @description instantiates a TMF641-compliant payload object based on a JSON representation
     * @param String json
     * @return TMF641ServiceOrderRequest object
     * @example
     *  TMF641ServiceOrderRequest tmf641Request = TMF641ServiceOrderRequest.parse("json-formatted-message");
     */

    public static TMF641ServiceOrderRequest parse(String json) {
        return (TMF641ServiceOrderRequest) System.JSON.deserialize(json, TMF641ServiceOrderRequest.class);
    }

    /* Inner classes section */
    
    /***************************************************************************************************************
     * @description note-element of a TMF641 message
     * 
     */

    public class Note {
        public String author;
        public String date_timestamp;
        public String text;
    }

    /***************************************************************************************************************
     * @description relatedParty-element of a TMF641 message
     * 
     */

    public class RelatedParty {
        public String href;
        public String id;
        public String name;
        public String role;
    }

    /***************************************************************************************************************
     * @description orderItem-element of a TMF641 message
     * 
     */

    public class OrderItem {
        public String action;
        //public Object appointment;
        public String id;
        //public List<Object> orderItemRelationship;
        public Service service;
        public String state;
    }

    /***************************************************************************************************************
     * @description service-element of a TMF641 message
     * 
     */

    public class Service {
        public String category;
        public String href;
        public String id;
        public String name;
        //public List<Object> place;
        //public List<RelatedParty> relatedParty;
        public List<ServiceCharacteristic> serviceCharacteristic;
        //public List<Object> serviceRelationship;
        public ServiceSpecification serviceSpecification;
        public String serviceType;
        public String state;
        //public List<Object> supportingResource;
        //public List<Object> supportingService;
    }

    /***************************************************************************************************************
     * @description serviceCharacteristic-element of a TMF641 message
     * 
     */

    public virtual class ServiceCharacteristic {
        public String name;
        public String valueType;
    }

    /***************************************************************************************************************
     * @description serviceCharacteristic-element of a TMF641 message for atomic value
     * 
     */

    public class AtomicServiceCharacteristic extends serviceCharacteristic {
        public String value;

        public AtomicServiceCharacteristic(String name, String valueType, String value) {
            this.name = name;
            this.valueType = valueType;
            this.value = value;
        }
    }

    /***************************************************************************************************************
     * @description serviceCharacteristic-element of a TMF641 message for complex (object) values
     * 
     */

    public class ObjectServiceCharacteristic  extends serviceCharacteristic {
        public Map <String, String> value;

        public ObjectServiceCharacteristic(String name, String valueType, Map <String, String> value) {
            this.name = name;
            this.valueType = valueType;
            this.value = value;
        }   
    }

    /***************************************************************************************************************
     * @description serviceSpecification-element of a TMF641 message for atomic value
     * 
     */

    public class ServiceSpecification {
        public String href;
        public String id;
        public String name;
        public String version;
        public TargetServiceSchema targetServiceSchema;
    }

    /***************************************************************************************************************
     * @description targetServiceSchema-element of a TMF641 message for atomic value
     * 
     */

    public class TargetServiceSchema {
        public String type;
        public String schemaLocation;
    }

}