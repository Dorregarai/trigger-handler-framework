public abstract class AbstractTriggerImpl {

    public static Set<ID> setAlreadyProcessedIds = new Set<ID>();

    private static Map<String, LoopCount> loopCountMap;

    // the current context of the trigger, overridable in tests
    @TestVisible
    private TriggerContext context;

    // the current context of the trigger, overridable in tests
    @TestVisible
    private Boolean isTriggerExecuting;

    public static boolean killSwitch= false;

    static {loopCountMap = new Map<String, LoopCount>();}

    public AbstractTriggerImpl () {
        this.setTriggerContext();
        run();
    }
    
    public void run() {

        /* Disabling trigger via Custom Setting or Static variable */
        if (isDisabled() || getDisable() || killSwitch) {
            return;
        }

        if (!addToLoopCount()) return;

        // dispatch to the correct handler method
        if (this.context == TriggerContext.BEFORE_INSERT) {
            this.beforeInsert();
            this.doInsert(Trigger.new, Trigger.isBefore, Trigger.isAfter);
        } else if (this.context == TriggerContext.BEFORE_UPDATE) {
            this.beforeUpdate();
            this.doUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.isBefore, Trigger.isAfter);
        } else if (this.context == TriggerContext.BEFORE_DELETE) {
            this.beforeDelete();
            this.doDelete(Trigger.old, Trigger.isBefore, Trigger.isAfter);
        } else if (this.context == TriggerContext.AFTER_INSERT) {
            this.afterInsert();
            this.doInsert(Trigger.new, Trigger.isBefore, Trigger.isAfter);
        } else if (this.context == TriggerContext.AFTER_UPDATE) {
            this.afterUpdate();
            this.doUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.isBefore, Trigger.isAfter);
        } else if (this.context == TriggerContext.AFTER_DELETE) {
            this.afterDelete();
            this.doDelete(Trigger.old, Trigger.isBefore, Trigger.isAfter);
        } else if (this.context == TriggerContext.AFTER_UNDELETE) {
            this.afterUndelete();
            this.doUndelete(Trigger.new, Trigger.isBefore, Trigger.isAfter);
        }
        this.andFinally();
    }

    public virtual AbstractTriggerImpl doInsert(List<Sobject> newList, Boolean isBefore, Boolean isAfter) {
        //override me, if you need concrete implementation!!!
        return this;
    }

    public virtual AbstractTriggerImpl doUpdate(List<Sobject> oldList, List<Sobject>  newList, Map<Id, Sobject> oldMap, Boolean isBefore, Boolean isAfter) {
        //override me, if you need concrete implementation!!!
        return this;
    }

    public virtual AbstractTriggerImpl doDelete(List<Sobject> oldList, Boolean isBefore, Boolean isAfter) {
        //override me, if you need concrete implementation!!!
        return this;
    }

    public virtual AbstractTriggerImpl doUndelete(List<Sobject> newList, Boolean isBefore, Boolean isAfter) {
        //override me, if you need concrete implementation!!!
        return this;
    }

    @TestVisible
    protected virtual void beforeInsert() {}
    @TestVisible
    protected virtual void beforeUpdate() {}
    @TestVisible
    protected virtual void beforeDelete() {}
    @TestVisible
    protected virtual void afterInsert() {}
    @TestVisible
    protected virtual void afterUpdate() {}
    @TestVisible
    protected virtual void afterDelete() {}
    @TestVisible
    protected virtual void afterUndelete() {}
    @TestVisible
    protected virtual void andFinally() {}    

    public void setMaxLoopCount(Integer max) {
        String handlerName = getHandlerName();
        if (!AbstractTriggerImpl.loopCountMap.containsKey(handlerName)) {
            AbstractTriggerImpl.loopCountMap.put(handlerName, new LoopCount(max));
        } else {
            AbstractTriggerImpl.loopCountMap.get(handlerName).setMax(max);
        }
    }   

    private Boolean isDisabled() {

        //Provides mechanism for turning triggers off via the Trigger Enablement custom setting,
        //a hierarchical custom setting that may be set per User (e.g. for Integration purposes)
        String csOverrideField = getCustomSettingFieldName();
        if (!csOverrideField.contains('__c')) {
            csOverrideField += '__c';
        }

        if (csOverrideField != null) {
            triggersettings__c customSetting = triggersettings__c.getInstance();
            try {
                if (customSetting != null && customSetting.get(csOverrideField) != null && (Boolean)customSetting.get(csOverrideField)) {
                    return true;
                }
            } catch (Exception e) {}
        }
        return false;
    }

    private Boolean addToLoopCount() {
        String handlerName = getHandlerName();
        if (AbstractTriggerImpl.loopCountMap.containsKey(handlerName)) {
            Boolean exceeded = AbstractTriggerImpl.loopCountMap.get(handlerName).increment();
            if (exceeded) {
                Integer max = AbstractTriggerImpl.loopCountMap.get(handlerName).max ;
                throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
            }
        }
        return true;
    }

    private String getHandlerName() {

        if (Test.isRunningTest()) {
            return 'test';
        }
        return String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
    }

    // inner class for managing the loop count per handler
    private class LoopCount {
        private Integer max;
        private Integer count;

        public LoopCount() {
            this.max = 10;
            this.count = 0;
        }

        public LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }

        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }

        public Boolean exceeded() {
            if (this.max < 0) return false;
            if (this.count > this.max) {
                return true;
            }
            return false;
        }

        public void setMax(Integer max) {
            this.max = max;
        }
    }

    @TestVisible
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    } 

    @TestVisible
    private void setTriggerContext(String ctx, Boolean testMode) {
        if (!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        } else {
            this.isTriggerExecuting = true;
        }

        if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
                (ctx != null && ctx == 'before insert')) {
            this.context = TriggerContext.BEFORE_INSERT;
        } else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
                   (ctx != null && ctx == 'before update')) {
            this.context = TriggerContext.BEFORE_UPDATE;
        } else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
                   (ctx != null && ctx == 'before delete')) {
            this.context = TriggerContext.BEFORE_DELETE;
        } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
                   (ctx != null && ctx == 'after insert')) {
            this.context = TriggerContext.AFTER_INSERT;
        } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
                   (ctx != null && ctx == 'after update')) {
            this.context = TriggerContext.AFTER_UPDATE;
        } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
                   (ctx != null && ctx == 'after delete')) {
            this.context = TriggerContext.AFTER_DELETE;
        } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
                   (ctx != null && ctx == 'after undelete')) {
            this.context = TriggerContext.AFTER_UNDELETE;
        }
    }

    // possible trigger contexts
    @TestVisible
    private enum TriggerContext {
        BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
        AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
        AFTER_UNDELETE
    }

    // exception class
    public class TriggerHandlerException extends Exception {}

    /* Custom Setting field name - has to be overidden - with or without __c */
    protected abstract String getCustomSettingFieldName();

    /* Overwrite it if disabling via static resource is needed */
    protected virtual Boolean getDisable() { return false; }

}