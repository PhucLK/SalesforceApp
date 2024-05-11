public with sharing class CaseService {
    public static void closeCases(Set<Id> caseIds, String reason){
        List<Case> caseList = [SELECT Id, Status, Reason FROM Case WHERE Id IN :caseIds];
        for ( Case caseRecord : caseList) {
            caseRecord.Status = 'Closed';
            caseRecord.Reason = reason;
        }

        // Update the database
        SavePoint sp = Database.setSavePoint();

        try {
            update caseList;
        } catch (Exception e) {
            // Rollback
            Database.rollback(sp);
            // Throw exception on to caller
            throw e;
        } 
    }
}