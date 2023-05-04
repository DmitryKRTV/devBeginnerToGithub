trigger ConversionLead on Lead (after update) {
    List<Id> accIds= new List<ID>();
    List<Id> contIds= new List<ID>();
    List<Id> oppIds= new List<ID>();

    for (Lead lead : Trigger.new) {
        accIds.add(lead.ConvertedAccountId);
        contIds.add(lead.ConvertedContactId);
        oppIds.add(lead.ConvertedOpportunityId);
    }

    Map <Id, Account> accs = new Map<Id, Account>([SELECT Id, CreatedDate FROM Account WHERE Id IN :accIds]);
    Map <Id, Contact> conts = new Map<Id, Contact>([SELECT Id, CreatedDate FROM Contact WHERE id IN :contIds]);
    Map <Id, Opportunity> opps = new Map<Id, Opportunity>([SELECT Id, CreatedDate FROM Opportunity WHERE id IN :oppIds]);
    List<ConversionHistory__c> newCHRecords = new List<ConversionHistory__c>();

    for (Lead lead : Trigger.new) {
        if (lead.IsConverted) {
            ConversionHistory__c newCHRecord = new ConversionHistory__c();
            newCHRecord.LeadId__c = lead.Id;
            newCHRecord.Timestamp__c = System.now();
            newCHRecord.RecordOwnerId__c = lead.OwnerId;
            newCHRecord.RecordConverterId__c = UserInfo.getUserId();
            newCHRecord.ConvertedAccountId__c = lead.ConvertedAccountId;
            newCHRecord.ConvertedContact__c = lead.ConvertedContactId;
            newCHRecord.ConvertedOpportunity__c = lead.ConvertedOpportunityId;
            newCHRecord.Matched__c = false;

            //lead.ConvertedDate provides only date, without time. 
            //lead.LastModifiedDate filed equals the moment, when lead.convertedDate are assigning.
            //It means lead.LastModifiedDate == lead.convertedDate, if lead.convertedDate were showing date/time.
            if(lead.LastModifiedDate >= accs.get(lead.ConvertedAccountId).CreatedDate.addSeconds(10)) {
                newCHRecord.Matched__c = true;

                }else if(lead.LastModifiedDate >= conts.get(lead.ConvertedContactId).CreatedDate.addSeconds(10)) {
                newCHRecord.Matched__c = true;
                
                }else if (lead.LastModifiedDate >= opps.get(lead.ConvertedOpportunityId).CreatedDate.addSeconds(10)) {
                newCHRecord.Matched__c = true;
                }
                
            newCHRecords.add(newCHRecord);
        }
    }
    if(newCHRecords.size() > 0) {
         insert newCHRecords;
    }
}