trigger AccountTrigger on Account (before insert, after insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        AccountTriggerHelper.setTypeProspect(Trigger.new);
        AccountTriggerHelper.copyShippingToBilling(Trigger.new);
        AccountTriggerHelper.setRating(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isInsert) {
        AccountTriggerHelper.createRelatedContact(Trigger.new);
    }
}