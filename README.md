# Trigger handler framework
This is a lightweight trigger framework for Salesforce designed to keep your triggers clean and maintainable.

## Quick Start
1. Deploy the provided package.xml (includes core framework classes).
2. Create a trigger:
````apex
    trigger ObjectTrigger on Object (before insert, before delete, after insert, after update) {
        ObjectHandler handler = ObjectHandler.getInstance();
    }
````
3. Create handler:
````apex
    public with sharing class ObjectTriggerHandler extends AbstractTriggerImpl {
        private static ObjectTriggerHandler instance = null;
        public static Boolean deactivateTrigger = false;

        private ObjectTriggerHandler() {
            this.setMaxLoopCount(1);    // recursion control
        }

        // Important: use this instance inside doX() methods
        public static ObjectTriggerHandler getInstance() {
            instance = new ObjectTriggerHandler();
            return instance;
        }
        
        public override Boolean getDisable() {
            return deactivateTrigger;
        }   
        
        /* Custom settings field name for disabling trigger */
        public override String getCustomSettingFieldName() {
            return 'ObjectTriggerHandler';
        }
        
        // Each doX method handles both before and after contexts using isBefore / isAfter flags.
        public override AbstractTriggerImpl doInsert(List<Sobject> newList, Boolean isBefore, Boolean isAfter) {
            System.debug('### ObjectTriggerHandler.doInsert()');
            if(isBefore) {

            }

            if(isAfter) {
                System.debug('### ObjectTriggerHandler.doInsert() isAfter');
                instance = firstMethod_AI((List<Object>) newList)
                            .secondMethod_AIU((List<Object>) newList);
            }

            return this;
        }

        public override AbstractTriggerImpl doUpdate(List<Sobject> oldList, List<Sobject> newList, Map<Id, Sobject> oldMap, Boolean isBefore, Boolean isAfter) {        
            if(isBefore) {

            }

            if(isAfter) {
                instance = firstMethod_AU((List<Object>) newList, (Map<Id, Object>) oldMap)
                            .secondMethod_AIU((List<Object>) newList);
            }

            return this;
        }

        private ObjectTriggerHandler secondMethod_AIU((List<Object>) newList) {
            try {
                if (triggersettings__c.getInstance() != null && triggersettings__c.getinstance().secondMethod_AIU__c) {
                    System.debug('### secondMethod_AIU is disabled.');
                    return this;
                }
            } catch (exception e) {
                //ignore Exceptions related to TriggerSettings
            }

            // your logic here
        }
    }
````
4. Go to Setup → Custom settings → Find `triggersettings__c` custom setting (included in the package). Create corresponding fields for the Object itself and for each method that you call from the doX() methods. These fields are used to control trigger execution. If set to **TRUE** — the method (or entire trigger) will be skipped.
````apex
    private ObjectTriggerHandler secondMethod_AIU((List<Object>) newList) {
        try {
            if (triggersettings__c.getInstance() != null && triggersettings__c.getinstance().secondMethod_AIU__c) {
                System.debug('### secondMethod_AIU is disabled.');
                return this;
            }
        } catch (exception e) {
            //ignore Exceptions related to TriggerSettings
        }
    }
````
> [!Note]
> Handlers support method chaining to execute multiple operations in sequence. Each method returns the handler instance.
> 
>````apex
> instance = firstMethod_AU((List<Object>) newList, (Map<Id, Object>) oldMap)
>            .secondMethod_AIU((List<Object>) newList);
>````

## Why use this?

- Keeps triggers clean and logic-free
- Supports bulk operations
- Handling recursion issues
- Improves testability
- Encourages separation of concerns

## Recursion Control

This framework uses a loop counter to prevent infinite trigger recursion.
You can configure max execution count per transaction.

> [!Note]
> This allows controlled recursion rather than blocking it completely. By default, it is set to 10.

### Example

````apex
    private ObjectTriggerHandler(){
        this.setMaxLoopCount(40);
    }
````

## Execution Flow

Trigger → Handler → doX() → custom methods