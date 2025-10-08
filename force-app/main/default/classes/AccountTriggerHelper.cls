public class AccountTriggerHelper {
    
    public static void setTypeProspect(List<Account> newAccounts) {
        for (Account acc : newAccounts) {
            if (acc.Type == null) {
                acc.Type = 'Prospect';
            }
        }
    }

    public static void copyShippingToBilling(List<Account> newAccounts) {
        for (Account acc : newAccounts) {
            // BONUS: Check if shipping fields are not empty before copying
            if (String.isNotBlank(acc.ShippingStreet) ||
                String.isNotBlank(acc.ShippingCity) ||
                String.isNotBlank(acc.ShippingState) ||
                String.isNotBlank(acc.ShippingPostalCode) ||
                String.isNotBlank(acc.ShippingCountry)) {
                
                acc.BillingStreet = acc.ShippingStreet;
                acc.BillingCity = acc.ShippingCity;
                acc.BillingState = acc.ShippingState;
                acc.BillingPostalCode = acc.ShippingPostalCode;
                acc.BillingCountry = acc.ShippingCountry;
            }
        }
    }

    public static void setRating(List<Account> newAccounts) {
         for (Account acc : newAccounts) {
            if (acc.Phone != null && 
                acc.Website != null &&
                acc.Fax != null) {
                acc.Rating = 'Hot';
            }
        }
    }

    public static void createRelatedContact(List<Account> newAccounts) {
        List<Contact> relatedCons = new List<Contact>();
        
        for (Account acc : newAccounts) {
            Contact newContact = new Contact(
                LastName = 'DefaultContact',
                Email = 'default@email.com',
                AccountId = acc.Id
            );
            
            relatedCons.add(newContact);
        }

        try {
            insert relatedCons;
        } catch (DmlException e) {
            System.debug('Error inserting contacts: ' + e.getMessage());
            
            // Optionally add error to the account records
            for (Account acc : newAccounts) {
                acc.addError('Failed to create default contact: ' + e.getMessage());
            }
        }
    }

}