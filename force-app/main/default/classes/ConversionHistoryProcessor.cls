public with sharing class ConversionHistoryProcessor implements Database.Batchable<SObject>, Database.Stateful  {
    //Messaging.SingleEmailMessage is not serializable and can't be saved in class scope.
    Map<String, List<String>> emailsToSend = new Map<String, List<String>>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, LeadId__r.Name, RecordConverterId__r.Email, ConvertedOpportunity__r.StageName, ConvertedAccountId__r.LastModifiedDate, CreatedDate FROM ConversionHistory__c');
    }

    public void execute(Database.BatchableContext bc, List<ConversionHistory__c> scope) {
        Map <Id, ConversionHistory__c> batchMapScope = new Map <Id, ConversionHistory__c> (scope);

        Database.DeleteResult[] drList = Database.delete(scope, false);

        for(Database.DeleteResult dr : drList) {
            if (dr.isSuccess()) {
                ConversionHistory__c currRecord = batchMapScope.get(dr.getId());

                if (emailsToSend.containsKey(currRecord.RecordConverterId__r.Email)) {
                    String htmlBodyTemp = 'Convertion history of ' + 'Lead: ' + currRecord.LeadId__r.Name + '.\n';

                    if (currRecord.CreatedDate < currRecord.ConvertedAccountId__r.LastModifiedDate) {
                        htmlBodyTemp += 'Account record has been modified after the conversion the Lead record.' + '\n';
                    } else {
                        htmlBodyTemp += 'Account record hasn\'t been modified after the conversion the Lead record.' + '\n';
                    }

                    htmlBodyTemp += 'Opportunity record current status is ' + currRecord.ConvertedOpportunity__r.StageName +'.\n\n';

                    emailsToSend.get(currRecord.RecordConverterId__r.Email).add(htmlBodyTemp);
                } else {
                    List<String> newBody = new List<String>();
                    String htmlBodyTemp = 'Convertion history of ' + 'Lead: ' + currRecord.LeadId__r.Name + '.\n';

                    if (currRecord.CreatedDate < currRecord.ConvertedAccountId__r.LastModifiedDate) {
                        htmlBodyTemp += 'Account record has been modified after the conversion the Lead record.' + '\n';
                    } else {
                        htmlBodyTemp += 'Account record hasn\'t been modified after the conversion the Lead record.' + '\n';
                    }

                    htmlBodyTemp += 'Opportunity record current status is ' + currRecord.ConvertedOpportunity__r.StageName +'.\n\n';

                    newBody.add(htmlBodyTemp);
                    emailsToSend.put(currRecord.RecordConverterId__r.Email, newBody);
                }
            }
            else {            
                for(Database.Error err : dr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc)    {
        List<Messaging.SingleEmailMessage> lstEmail = new List<Messaging.SingleEmailMessage>();

        for (String emailKey : emailsToSend.keySet()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            String body = '';
            mail.setSubject('The list of Leads convertion histories that need to be reviewed.');
            mail.setToAddresses(new String[] {emailKey});

            for (String text: emailsToSend.get(emailKey)) {
                body += text;
            }

            mail.setPlainTextBody(body);
            lstEmail.add(mail);
        }

        Messaging.SendEmail(lstEmail);
    }
}