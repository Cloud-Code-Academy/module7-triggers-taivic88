trigger OpportunityTrigger on Opportunity (before update, before delete) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        OpportunityTriggerHelper.validateAmount(Trigger.new);
        OpportunityTriggerHelper.setPrimaryContact(Trigger.new);

    }

    if (Trigger.isBefore && Trigger.isDelete) {
        OpportunityTriggerHelper.deleteCloseWonOpps(Trigger.old);
    }
}