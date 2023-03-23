/* CODE TO RUN IN ANONYMOUS APEX OR INTEGRATION:

//Insert Field Value as Correct DataType
Map<String, Object> fieldMap = new Map<String, Object>{
    'Company' => 'Updated Test Company',
    'LastCalledDate' => Date.valueOf('2021-05-13'),
    'NumberOfEmployees' => 100
};

BatchFieldUpdater batchUpdate = new BatchFieldUpdater(
    fieldMap,
    'SELECT Id, Field__c FROM Object__c WHERE Field__c = \'Some Text Field\''
    ,new String[] {'user@email.com'} //Remove Line If Email Not Required
);

ID batchProcessId = Database.executeBatch(batchUpdate);

 */

public class BatchFieldUpdater implements Database.Batchable<SObject> {
    public final String query;
    public final String[] toAddresses;
    public final Map<String, Object> dataMap;

    public BatchFieldUpdater(Map<String, Object> dataMap, String query, String[] toAddresses) {
        if (dataMap == null) {throw new IllegalArgumentException('DataMap cannot be null');}
            else this.dataMap = dataMap;
        if (query == null) {throw new IllegalArgumentException('Query cannot be null');}
            else this.query = query;
        this.toAddresses = toAddresses;
    }

    public BatchFieldUpdater(Map<String, Object> dataMap, String query) {
        if (dataMap == null) {throw new IllegalArgumentException('DataMap cannot be null');}
            else this.dataMap = dataMap;
        if (query == null) {throw new IllegalArgumentException('Query cannot be null');}
            else this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext batchContext, List<SObject> recordsFromQuery) {
        for (SObject objectToUpdate : recordsFromQuery) {
            if (dataMap != null) {
                for (String field : dataMap.keySet()) {
                    Object value = dataMap.get(field);
                    if (value != null) {
                        objectToUpdate.put(field, value);
                    }
                }
            }
        }
        update recordsFromQuery;
    }

    public void finish(Database.BatchableContext batchContext){
        if (this.toAddresses != null) {

            AsyncApexJob apexJob = [
                SELECT Id, Status, NumberOfErrors, TotalJobItems
                FROM AsyncApexJob
                WHERE Id = :batchContext.getJobId()
            ];
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                mail.setToAddresses(ToAddresses);
                mail.setSubject('Batch Apex Job ' + batchContext.getJobId() + ' Results ' + apexJob.Status);
                mail.setPlainTextBody('The batch Apex job processed ' + apexJob.TotalJobItems + ' batches with '+ apexJob.NumberOfErrors + ' failures.');
                
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}
