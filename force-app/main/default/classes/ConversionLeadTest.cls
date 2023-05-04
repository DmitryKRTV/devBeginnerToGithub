@IsTest
public with sharing class ConversionLeadTest {
    @IsTest
    static void BrandNewLead() {
        Lead lead = new Lead(
            FirstName='First',
			LastName = 'Last',
			Status='Qualified',
            company='Lacosta', 
            street='1211 E I-40 Service Rd',
			city=' Oklahoma City',
			state='OK');
        insert lead;
        test.StartTest();

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.Id);
        LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        List <ConversionHistory__c> newCHRecords = [SELECT Id, LeadId__c, Matched__c FROM ConversionHistory__c WHERE LeadId__c = :lead.Id];
        System.assertEquals(1, newCHRecords.size());

        List<Account> accs = [SELECT Id FROM Account];
        System.assertEquals(1, accs.size());

        List<Contact> conts = [SELECT Id FROM Contact];
        System.assertEquals(1, conts.size());

        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        System.assertEquals(1, opps.size());
        
        System.assertEquals(false, newCHRecords[0].Matched__c);

        test.stopTest();
    }

    @IsTest
    static void BrandNewLeads() {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 10; i++) {
            Lead lead = new Lead(
            FirstName='First' + i,
			LastName = 'Last' + i,
			Status='Qualified' + i,
            company='Lacosta' + i, 
            street='1211 E I-40 Service Rd' + i,
			city=' Oklahoma City' + i,
			state='OK' + i);

            leads.add(lead);
        }
        insert leads;

        test.StartTest();

        for (Lead lead : leads) {
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(lead.Id);
            LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());

            List <ConversionHistory__c> newCHRecords = [SELECT Id, LeadId__c, Matched__c FROM ConversionHistory__c WHERE LeadId__c = :lead.Id];
            System.assertEquals(1, newCHRecords.size());
            
            System.assertEquals(false, newCHRecords[0].Matched__c);
            }
        test.stopTest();
    }
    
    @IsTest
    static void ExistAccLead() {
        Account acc = new Account(Name='First');
        insert acc;
        
        Lead lead = new Lead(
            FirstName='First',
			LastName = 'Last',
			Status='Qualified', 
			city=' Oklahoma City',
			state='OK');
        insert lead;
        test.StartTest();

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.Id);
        lc.setAccountId(acc.id);
        LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        List <ConversionHistory__c> newCHRecords = [SELECT Id, Matched__c, ConvertedAccountId__c FROM ConversionHistory__c WHERE LeadId__c = :lead.Id];

        System.assertEquals(1, newCHRecords.size());

        test.stopTest();
    }
  
}