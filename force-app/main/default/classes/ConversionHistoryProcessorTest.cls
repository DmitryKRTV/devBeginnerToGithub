@IsTest
public with sharing class ConversionHistoryProcessorTest {
    @TestSetup
    static void makeData(){
        Lead lead = new Lead(
            FirstName='First',
			LastName = 'Last',
			Status='Qualified',
            company='Lacosta', 
            street='1211 E I-40 Service Rd',
			city=' Oklahoma City',
			state='OK');
        insert lead;

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.Id);
        LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
    }

    @IsTest
    static void testBatchDeleting(){
        Integer initialCount = [SELECT count() FROM ConversionHistory__c];
        System.assert([SELECT count() FROM ConversionHistory__c] > 0);

        Test.startTest();
        ConversionHistoryProcessor chp = new ConversionHistoryProcessor();
        Id batchId = Database.executeBatch(chp);
        Test.stopTest();
        
        System.assertEquals(0, [SELECT count() FROM ConversionHistory__c]);
    }
}