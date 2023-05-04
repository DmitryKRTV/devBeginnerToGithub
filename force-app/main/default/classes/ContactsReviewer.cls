public with sharing class ContactsReviewer implements Database.Batchable<SObject>, Database.Stateful  {
    Map<String, List<String>> emailsToSend = new Map<String, List<String>>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, Owner.Email FROM Contact WHERE Possible_outdated__c = true');
    }

    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        for(Contact contact : scope) {
            if (emailsToSend.containsKey(contact.Owner.Email)) {
                emailsToSend.get(contact.Owner.Email).add('Contact <a href=https://curious-moose-g11anl-dev-ed.trailblaze.lightning.force.com/lightning/r/Contact/'+ contact.Id +'/view>'+ contact.name +'</a><br>');
            } else {
                List<String> newLink = new List<String>();
                newLink.add('Contact <a href=https://curious-moose-g11anl-dev-ed.trailblaze.lightning.force.com/lightning/r/Contact/'+ contact.Id +'/view>'+ contact.name +'</a><br>');
                emailsToSend.put(contact.Owner.Email, newLink);
            }
        }
    }

    public void finish(Database.BatchableContext bc)    {
        List<Messaging.SingleEmailMessage> lstEmail = new List<Messaging.SingleEmailMessage>();

        for (String emailKey : emailsToSend.keySet()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            String htmlBody = 'Contacts that need review:<br>';
            mail.setSubject('The list of possible outdated Contacts that needs review!');
            mail.setToAddresses(new String[] {emailKey});

            for (String link: emailsToSend.get(emailKey)) {
                htmlBody += link;
            }

            mail.setHtmlBody(htmlBody);
            lstEmail.add(mail);
        }

        Messaging.SendEmail(lstEmail);
    }
}