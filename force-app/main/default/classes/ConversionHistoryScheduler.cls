public with sharing class ConversionHistoryScheduler implements Schedulable {
    public void execute(SchedulableContext ctx) {
        ConversionHistoryProcessor chp = new ConversionHistoryProcessor();
        Id batchId = Database.executeBatch(chp);

        //In oreder to launch:
        //ConversionHistoryScheduler chs = new ConversionHistoryScheduler();
        //System.schedule('Test', '0 0 12 ? * 1 ?', chs);
    }
}