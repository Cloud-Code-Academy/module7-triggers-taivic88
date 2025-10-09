public with sharing class OpportunityTriggerHelper {

    public static void validateAmount (List<Opportunity> opps) {
        try {
            if (opps == null || opps.isEmpty()) {
                return;
            }

            for (Opportunity opp : opps) {
                if (opp.Amount <= 5000) {
                    opp.addError('Opportunity amount must be greater than 5000');
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in validateAmount: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            throw e; // Re-throw to ensure trigger fails properly
        }
        
    }

    public static void deleteCloseWonOpps (List<Opportunity> opps) {
        try {
            if (opps == null || opps.isEmpty()) {
                return;
            }

            Set<Id> accountIds = new Set<Id>();
            for (Opportunity opp : opps) {
                if (opp.AccountId != null) {
                    accountIds.add(opp.AccountId);
                }
            }
            
            Map<Id, Account> accountMap = new Map<Id, Account>([
                SELECT Id, Industry
                FROM Account
                WHERE Id IN :accountIds
            ]);
                
            for (Opportunity opp : opps) {
                Account relatedAccount = accountMap.get(opp.AccountId);
                
                if (relatedAccount != null && 
                    relatedAccount.Industry == 'Banking' && 
                    opp.StageName == 'Closed Won') {
                        opp.addError('Cannot delete closed opportunity for a banking account that is won');
                }
            }
        } catch (QueryException e) {
            System.debug(LoggingLevel.ERROR, 'Query error in deleteCloseWonOpps: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            throw e;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in deleteCloseWonOpps: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            throw e;
        }
        
    }

    public static void setPrimaryContact (List<Opportunity> opps) {
        try {
            if (opps == null || opps.isEmpty()) {
                return;
            }
            
            Set<Id> accountIds = new Set<Id>();
            for (Opportunity opp : opps) {
                if (opp.AccountId != null) {
                    accountIds.add(opp.AccountId);
                }
            }

            Map<Id, Account> idToAccs = new Map<Id, Account>([
                SELECT Id, 
                    (SELECT Id
                    FROM Contacts
                    WHERE Title = 'CEO'
                    LIMIT 1)
                FROM Account
                WHERE Id IN :accountIds
            ]);

            for (Opportunity opp : opps) {
                if (opp.AccountId != null && idToAccs.containsKey(opp.AccountId)) {
                    Account relatedAccount = idToAccs.get(opp.AccountId);

                    if (relatedAccount.Contacts != null && !relatedAccount.Contacts.isEmpty()) {
                        Contact relatedAccPrimaryCon = relatedAccount.Contacts[0];
                        opp.Primary_Contact__c = relatedAccPrimaryCon.Id;
                    }    
                }
            }
        } catch (QueryException e) {
            System.debug(LoggingLevel.ERROR, 'Query error in setPrimaryContact: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            throw e;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in setPrimaryContact: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            throw e;
        }
    }
}