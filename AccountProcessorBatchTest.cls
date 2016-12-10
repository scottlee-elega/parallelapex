@isTest
private class AccountProcessorBatchTest
{
	public static final Integer numberOfAccounts = 50;

	@isTest
	static void testAccountProcessorBatch()
	{
		// Given:
		insert createAccounts();

		// When:
		Test.startTest();
		Database.executeBatch(new AccountProcessorBatch());
		Test.stopTest();

		// Then:
		List<Account> accountProcessed = [SELECT Id, Name, Processed_Time__c 
										FROM Account
										WHERE Processed_Time__c != null];
		System.assertEquals(numberOfAccounts, accountProcessed.size(),
			numberOfAccounts + ' Account successfully processed');

	}

	private static List<Account> createAccounts()
	{
		List<Account> accounts = new List<Account>();		
		for(Integer i = 0; i < numberOfAccounts; i++) 
		{
			Account account = new Account();
			account.Name = 'Example ' + String.valueOf(i);

			accounts.add(account);
		}

		return accounts;
	}
}