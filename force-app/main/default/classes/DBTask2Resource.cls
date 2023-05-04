@RestResource(urlMapping='/Leads/*')
global with sharing class DBTask2Resource {
    @HttpGet
    global static List<Lead> getLeadBy() {
        RestRequest request = RestContext.request;
        String leadId = RestContext.request.params.get('id');
        String leadEmail = RestContext.request.params.get('email');
        
        if(leadId != null && leadEmail == null) {
            return [SELECT Id, Name, Email FROM LEAD WHERE Id =:leadId];
        }

        if(leadId == null && leadEmail != null) {
            return [SELECT Id, Name, Email FROM LEAD WHERE Email =:leadEmail];
        }
        
        if(leadId != null && leadEmail != null) {
            return [SELECT Id, Name, Email FROM LEAD WHERE Id = :leadId AND Email = :leadEmail];
        }

        return null;
    }
    @HttpPost
    global static List<Task> createLeadTask(String leadId, String leadEmail, String taskBody) {
        if(leadId != null && leadEmail != null) {
            List<Task> tasks = new List<Task>();
            List<Lead> leads = [SELECT Id, Name, Email, OwnerId FROM LEAD WHERE Id = :leadId AND Email = :leadEmail];
            
            if(leads.size() > 0) {
                    for(Lead lead: leads) {
                        Task tsk = new Task();
                        tsk.Subject = 'TestSubject';
                        tsk.Priority = 'Normal';
                        tsk.Status = 'Not Started';
                        tsk.Description = taskBody;
                        tsk.WhoId = lead.id;
                        tasks.add(tsk);
                    }
                }
            
            if(tasks.size() > 0) {
                insert tasks;
            }
            return tasks;
        }

        return null;
    }
}