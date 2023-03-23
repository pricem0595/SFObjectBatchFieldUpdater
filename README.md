# SFObjectBatchFieldUpdater
A simple batch class that can be called using Execute Anon or other classes.  
Updates multiple fields on unlimited records of a single Object.
#
# Code to run in Anon Apex or Integration
//Insert Field Value as Correct DataType  
Map<String, Object> fieldMap = new Map<String, Object>{  
&nbsp;&nbsp;&nbsp;&nbsp;'Company' => 'Updated Test Company',  
&nbsp;&nbsp;&nbsp;&nbsp;'LastCalledDate' => Date.valueOf('2021-05-13'),  
&nbsp;&nbsp;&nbsp;&nbsp;'NumberOfEmployees' => 100  
};  
  
BatchFieldUpdater batchUpdate = new BatchFieldUpdater(  
&nbsp;&nbsp;&nbsp;&nbsp;fieldMap,  
&nbsp;&nbsp;&nbsp;&nbsp;'SELECT Id, Field__c FROM Object__c WHERE Field__c = \\'Some Text Field\\''  
&nbsp;&nbsp;&nbsp;&nbsp;,new String[] {'user@email.com'} //Remove Line If Email Not Required  
);  
  
ID batchProcessId = Database.executeBatch(batchUpdate);
