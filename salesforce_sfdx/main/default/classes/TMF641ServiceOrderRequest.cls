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

    public String id;
    public String href;
    public String externalId;
    public String priority;
    public String description;
    public String category;
    public String state;
    public String orderDate;
    public String completionDate;
    public String requestedStartDate;
    public String requestedCompletionDate;
    public String expectedCompletionDate;
    public String startDate;
    public String type;
    public List<Note> note;
    public List<RelatedParty> relatedParty;
    public List<OrderItem> orderItem;

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
        public String date_timestamp;
        public String author;
        public String text;
    }

    /***************************************************************************************************************
     * @description relatedParty-element of a TMF641 message
     * 
     */

    public class RelatedParty {
        public String id;
        public String href;
        public String role;
        public String name;
        public String referredType;
    }

    /***************************************************************************************************************
     * @description orderItem-element of a TMF641 message
     * 
     */

    public class OrderItem {
        public String id;
        public String action;
        public String state;
        public Service service;
    }

    /***************************************************************************************************************
     * @description service-element of a TMF641 message
     * 
     */

    public class Service {
        public String type;
        public String schemaLocation;
        public String state;
        public String serviceType;
        public List<ServiceCharacteristic> serviceCharacteristic;
        public List<ServiceRelationship> serviceRelationship;
        public List<SupportingResource> supportingResource;
        public ServiceSpecification serviceSpecification;
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
     * @description complex value for a complex (object) characteristic
     * 
     */

    public class Value {
        public String type;
        public Map<String, String> atomicKeyValues;
    }

    /***************************************************************************************************************
     * @description serviceRelationship-element of a TMF641 message for atomic value
     * 
     */

    public class ServiceRelationship {
        public String relationshipType;
        public ServiceReference service;
    }

    /***************************************************************************************************************
     * @description serviceReference-element of a TMF641 message for atomic value
     * 
     */

    public class ServiceReference {
        public String id;
        public String href;
    }

    /***************************************************************************************************************
     * @description supportingResource-element of a TMF641 message for atomic value
     * 
     */

    public class SupportingResource {
        public String id;
        public String href;
        public String referredType;
    }

    /***************************************************************************************************************
     * @description serviceSpecification-element of a TMF641 message for atomic value
     * 
     */

    public class ServiceSpecification {
        public String type;
        public String schemaLocation;
        public String id;
        public String href;
        public String name;
        public String version;
        public String invariantUUID;
        public String toscaModelURL;
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