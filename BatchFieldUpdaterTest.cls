@IsTest
private class BatchFieldUpdaterTest {

    @IsTest
    static void testBatchFieldUpdater() {
        List<Lead> leads = new List<Lead>{
            new Lead(LastName='lastName1', NumberOfEmployees=50, Company='Test Company'),
            new Lead(LastName='lastName2', NumberOfEmployees=25, Company='Test Company')
        };
        insert leads;

        Map<String, Object> dataMap = new Map<String, Object>{
            'Company' => 'Updated Test Company',
            'DoNotCall' => true,
            'NumberOfEmployees' => 100
        };
        String query = 'SELECT Id, DoNotCall, NumberOfEmployees, Company FROM Lead';
        String[] toAddresses = new String[]{'test@example.com'};

        Test.startTest();
        BatchFieldUpdater batchUpdater = new BatchFieldUpdater(dataMap, query, toAddresses);
        Database.executeBatch(batchUpdater);
        Test.stopTest();

        List<Lead> updatedLeads = [SELECT Id, DoNotCall, NumberOfEmployees, Company FROM Lead];
        for (Lead l : updatedLeads) {
            System.assertEquals(100, l.NumberOfEmployees, 'Test Lead NumberOfEmployees Not Updated!');
            System.assertEquals('Updated Test Company', l.Company, 'Test Lead Company Name Not Updated!');
            System.assertEquals(true, l.DoNotCall, 'Test Lead DoNotCall Not Updated!');
        }

        List<EmailMessage> sentEmails = [SELECT Id FROM EmailMessage WHERE Subject LIKE '%Batch Apex Job%'];
        System.assertEquals(1, sentEmails.size(), 'Test Email Not Found!');
    }
}
