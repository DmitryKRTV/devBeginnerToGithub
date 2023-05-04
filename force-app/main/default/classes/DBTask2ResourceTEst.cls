@isTEst
public with sharing class DBTask2ResourceTEst {
    @TestSetup
    static void makeData(){
        Lead lead = new Lead(LastName='test', Company='newCompany', MobilePhone='12345678', Email='1a_young@dickenson.com');
        insert lead;
    }
    @isTest
    public static void getByEmailAndId() {
        Lead lead = [SELECT id, Email FROM Lead LIMIT 1];
        RestRequest request = new RestRequest();
        request.requestUri = 'https://AP16.my.salesforce.com/services/apexrest/Leads/';
        request.httpMethod = 'GET';
        request.addParameter('id', lead.Id);
        request.addParameter('email', lead.Email);
        RestContext.request = request;
        List<Lead> resultLead = DBTask2Resource.getLeadBy();

        if(resultLead.size() > 0) {
            System.assertEquals(lead.id, resultLead[0].id);
            System.assertEquals(lead.email, resultLead[0].Email);
        }
    }

    @isTest
    public static void getByEmail() {
        Lead lead = [SELECT Email FROM Lead LIMIT 1];
        RestRequest request = new RestRequest();
        request.requestUri = 'https://AP16.my.salesforce.com/services/apexrest/Leads/';
        request.httpMethod = 'GET';
        request.addParameter('email', lead.Email);
        RestContext.request = request;
        List<Lead> resultLead = DBTask2Resource.getLeadBy();

        if(resultLead.size() > 0) {
            System.assertEquals(lead.email, resultLead[0].Email);
        }
    }

    @isTest
    public static void getById() {
        Lead lead = [SELECT id FROM Lead LIMIT 1];
        RestRequest request = new RestRequest();
        request.requestUri = 'https://AP16.my.salesforce.com/services/apexrest/Leads/';
        request.httpMethod = 'GET';
        request.addParameter('id', lead.Id);
        RestContext.request = request;
        List<Lead> resultLead = DBTask2Resource.getLeadBy();

        if(resultLead.size() > 0) {
            System.assertEquals(lead.id, resultLead[0].id);
        }
    }

    @isTest
    public static void getWithoutParams() {
        RestRequest request = new RestRequest();
        request.requestUri = 'https://AP16.my.salesforce.com/services/apexrest/Leads/';
        request.httpMethod = 'GET';
        RestContext.request = request;
        List<Lead> resultLead = DBTask2Resource.getLeadBy();

        System.assertEquals(null, resultLead);
    }

    @isTest
    public static void createTask() {
        Lead lead = [SELECT id, Email FROM Lead LIMIT 1];
        RestRequest request = new RestRequest();
        request.requestUri = 'https://AP16.my.salesforce.com/services/apexrest/Leads/';
        request.httpMethod = 'POST';
        
        List<Task> resultLead = DBTask2Resource.createLeadTask(lead.Id, lead.Email ,'test body');

        List<Task> tasks = [SELECT Description, WhoId FROM Task];

        System.assertEquals(1, tasks.size());
        System.assertEquals(tasks[0].Description, 'test body');
        System.assertEquals(tasks[0].WhoId, lead.Id);
    }   
    @isTest
    public static void createTaskWithoutQueries() {
        Lead lead = [SELECT id, Email FROM Lead LIMIT 1];
        RestRequest request = new RestRequest();
        request.requestUri = 'https://AP16.my.salesforce.com/services/apexrest/Leads/';
        request.httpMethod = 'POST';
        
        List<Task> resultLead = DBTask2Resource.createLeadTask('', '','test body');

        System.assertEquals(0, [SELECT count() FROM Task]);
    }  
}