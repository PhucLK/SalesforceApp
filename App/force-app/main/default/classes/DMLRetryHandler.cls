public class DMLRetryHandler {
    
    // Maximum number of retries
    private static final Integer MAX_RETRIES = 10;
    
    // Sleep duration between retries in milliseconds
    private static final Integer RETRY_SLEEP_DURATION = 1000;

    // Perform insert or update operation with retry logic
    public static void performDMLWithRetry(List<SObject> records) {
        if (records == null || records.isEmpty()) {
            return;
        }
        
        Integer retryCount = 0;
        while (retryCount < MAX_RETRIES) {
            try {
                // Perform DML operation
                Database.upsert(records, false);
                // If successful, exit loop
                break;
            } catch (DmlException e) {
                // Handle DML exception
                Boolean retry = false;
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    if (isRowLockError(e.getDmlMessage(i))) {
                        retry = true;
                        break;
                    }
                }
                
                if (retry) {
                    // Increment retry count
                    retryCount++;
                    // Log error
                    System.debug('Row lock error encountered. Retrying (' + retryCount + '/' + MAX_RETRIES + ')');
                    // Sleep before retrying
                    try {
                        // Sleep for specified duration
                        Long start = System.now().getTime();
                        while (System.now().getTime() - start < RETRY_SLEEP_DURATION) {
                            // Busy wait
                        }
                    } catch (Exception ex) {
                        System.debug('Sleep interrupted');
                    }
                } else {
                    // Maximum retry count reached or error is not row lock related, log error and exit loop
                    System.debug('Maximum retry limit reached or error is not row lock related. Unable to perform DML operation.');
                    break;
                }
            }
        }
    }
    
    // Check if the given DML message indicates a row lock error
    private static Boolean isRowLockError(String errorMessage) {
        return errorMessage.contains('UNABLE_TO_LOCK_ROW');
    }
}
