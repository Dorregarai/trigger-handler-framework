# trigger-handler-framework
To use the trigger handler framework you need to deploy _AbstractTriggerImpl.cls_, _AbstractTriggerImplTest.cls_ and the _triggersettings__c_ Custom Serttings into your org.

## How to use it
- Implement (`public YourClassName extends AbstractTriggerImpl`) the _AbstractTriggerImpl.cls_
- Create the new field in the `triggersettings__c` custom setting `Name = <Object>TriggerHandler Type = checkbox`
- Create the new fields in the `triggersettings__c` custom setting for each new method with `Name = <methodName> Type = checkbox`
- Add following structure to the triggerhandler class:
```
    private static <Object>TriggerHandler instance = null;
    public static Boolean deactivateTrigger = false;

	private <Object>TriggerHandler() {}

	//imporant method, with this instace you work in the doX() methods!
    public static <Object>TriggerHandler getInstance() {
        instance = new <Object>TriggerHandler();
        return instance;
    }
    
    public override Boolean getDisable() {
        return deactivateTrigger;
    }   
    
    /* Custom settings field name for disabling trigger */
    public override String getCustomSettingFieldName() {
        return '<Object>TriggerHandler';
    }
    
    public override AbstractTriggerImpl doInsert(List<Sobject> newList, Boolean isBefore, Boolean isAfter) {
		System.debug('### <Object>TriggerHandler.doInsert()');
        if(isBefore) {

		}

		if(isAfter) {
			System.debug('### <Object>TriggerHandler.doInsert() isAfter');
			instance = anyMethod_AI((List<<Object>>) newList)
					    .secondAnyMethod_AIU((List<<Object>>) newList, (Map<Id, <Object>>) oldMap);
		}

		return this;
	}

	public override AbstractTriggerImpl doUpdate(List<Sobject> oldList, List<Sobject> newList, Map<Id, Sobject> oldMap, Boolean isBefore, Boolean isAfter) {        
		if(isBefore) {

		}

		if(isAfter) {
			instance = anyMethod_AU((List<<Object>>) newList, (Map<Id, <Object>>) oldMap)
						.secondAnyMethod_AIU((List<<Object>>) newList, (Map<Id, <Object>>) oldMap);
		}

		return this;
	}
```
- Now you can activate / deactivate the whole trigger or just some methods from the custom setting by setting checkbox to `TRUE` for in needed field
- Also you can turn off the trigger from the code by setting the `deactivateTrigger` class-variable to `TRUE`
- ???
- Enjoy :)
