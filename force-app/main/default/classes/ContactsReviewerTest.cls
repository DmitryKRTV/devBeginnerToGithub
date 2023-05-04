@IsTest
public with sharing class ContactsReviewerTest {
    @TestSetup
    static void makeData(){
        Account acc = new Account(Name='testAcc');
        insert acc;
        List<Contact> contacts = new List<Contact>();
        for (Integer i=0;i<10;i++) {
            contacts.add(new Contact(LastName='TestContact' + i, AccountId = acc.Id));
        } 
        insert contacts;
    }

    @IsTest
    static void makeDataForEmail(){
        Test.startTest();
        ContactsReviewer cr = new ContactsReviewer();
        Id batchId = Database.executeBatch(cr);
        Test.stopTest();
        
        System.assertEquals(6, [SELECT count() FROM Contact WHERE Possible_outdated__c = true]);
    }
}