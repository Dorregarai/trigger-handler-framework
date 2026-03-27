@isTest
private class AbstractTriggerImplTest {


    private static final String TRIGGER_CONTEXT_ERROR = 'Trigger handler called outside of Trigger execution';
    private static AbstractTriggerImplTest.TestHandler handler;
    private static String lastMethodCalled;

    static {
        handler = new AbstractTriggerImplTest.TestHandler();
        // override its internal trigger detection
        handler.isTriggerExecuting = true;
    }

    @isTest
    static void maximumLoopCount() {
        beforeInsertMode();
        
        // set the max loops to 2
        handler.setMaxLoopCount(2);

        // run the handler twice
        handler.run();
        handler.run();

        String errorMessage;

        try {
            handler.run();
        } catch (AbstractTriggerImpl.TriggerHandlerException te) {
            // we're expecting to get here
            errorMessage = te.getMessage();
        } catch (Exception e) {
            System.assert(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
        }

        System.assert(errorMessage.contains('Maximum loop count of'), 'Error should be thrown for another loop');

    }


    @isTest
    static void testBeforeInsert() {
        beforeInsertMode();
        handler.run();
        System.assertEquals('beforeInsert', lastMethodCalled, 'last method should be beforeInsert');
    }

    @isTest
    static void testBeforeUpdate() {
        beforeUpdateMode();
        handler.run();
        System.assertEquals('beforeUpdate', lastMethodCalled, 'last method should be beforeUpdate');
    }

    @isTest
    static void testBeforeDelete() {
        beforeDeleteMode();
        handler.run();
        System.assertEquals('beforeDelete', lastMethodCalled, 'last method should be beforeDelete');
    }

    @isTest
    static void testAfterInsert() {
        afterInsertMode();
        handler.run();
        System.assertEquals('afterInsert', lastMethodCalled, 'last method should be afterInsert');
    }

    @isTest
    static void testAfterUpdate() {
        afterUpdateMode();
        handler.run();
        System.assertEquals('afterUpdate', lastMethodCalled, 'last method should be afterUpdate');
    }

    @isTest
    static void testAfterDelete() {
        afterDeleteMode();
        handler.run();
        System.assertEquals('afterDelete', lastMethodCalled, 'last method should be afterDelete');
    }

    @isTest
    static void testAfterUndelete() {
        afterUndeleteMode();
        handler.run();
        System.assertEquals('afterUndelete', lastMethodCalled, 'last method should be afterUndelete');
    }

    // test implementation of the AbstractTriggerImpl

    private class TestHandler extends AbstractTriggerImpl {

        public override String getCustomSettingFieldName() {
            return 'AbstractTriggerImplTest';
        }

        public override void beforeInsert() {
            AbstractTriggerImplTest.lastMethodCalled = 'beforeInsert';
        }

        public override void  beforeUpdate() {
            AbstractTriggerImplTest.lastMethodCalled = 'beforeUpdate';
        }

        public override void beforeDelete() {
            AbstractTriggerImplTest.lastMethodCalled = 'beforeDelete';
        }

        public override void afterInsert() {
            AbstractTriggerImplTest.lastMethodCalled = 'afterInsert';
        }

        public override void afterUpdate() {
            AbstractTriggerImplTest.lastMethodCalled = 'afterUpdate';
        }

        public override void afterDelete() {
            AbstractTriggerImplTest.lastMethodCalled = 'afterDelete';
        }

        public override void afterUndelete() {
            AbstractTriggerImplTest.lastMethodCalled = 'afterUndelete';
        }
    }

    private static void beforeInsertMode() {
        handler.setTriggerContext('before insert', true);
    }

    private static void beforeUpdateMode() {
        handler.setTriggerContext('before update', true);
    }

    private static void beforeDeleteMode() {
        handler.setTriggerContext('before delete', true);
    }

    private static void afterInsertMode() {
        handler.setTriggerContext('after insert', true);
    }

    private static void afterUpdateMode() {
        handler.setTriggerContext('after update', true);
    }

    private static void afterDeleteMode() {
        handler.setTriggerContext('after delete', true);
    }

    private static void afterUndeleteMode() {
        handler.setTriggerContext('after undelete', true);
    }

    // modes for testing
}