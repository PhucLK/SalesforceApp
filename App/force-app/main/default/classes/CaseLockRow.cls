public with sharing class CaseLockRow {

    // Method to start two asynchronous transactions to update the same record concurrently
    public static void startConcurrentUpdates(List<Id> recordId) {
        // Start the first asynchronous transaction
        updateRecordAsync(recordId);
        // Start the second asynchronous transaction
        updateRecordAsync(recordId);
    }

    // Asynchronously update the record
    @future
    public static void updateRecordAsync(List<Id> recordId) {
        try {
            // Retrieve the record for update
            List<Case> recordToUpdate = [SELECT Id, Description FROM Case WHERE Id IN :recordId FOR UPDATE];
            // Perform some modifications
            For(Case c : recordToUpdate){
                c.Description = 'Updated Description';
                // Update the record
            }
            DMLRetryHandler.performDMLWithRetry(recordToUpdate);
        } catch (Exception e) {
            System.debug('Error updating record: ' + e.getMessage());
        }
    }
}