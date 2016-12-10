global class AccountProcessorBatch implements Database.Batchable<sObject>, Database.Stateful
{
	Integer accountsPerJob = 50;
	String query = 'SELECT Id, Name, Processed_Time__c FROM Account WHERE Processed_Time__c = null';
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) 
   	{
		// Construct the master work list separated by index.
		// Each index is associated with up to 50 records (or the same value
		// as accountsPerJob).
		Map<Integer, List<Account>> indexToAccounts = constructAccountsWorkList((List<Account>) scope);
		System.debug('indexToAccounts.keySet().size(): ' + indexToAccounts.keySet().size());

		// Begin queueable jobs, starting at index zero.
		System.enqueueJob(new AccountProcessor(indexToAccounts, 0));
	}
	
	global void finish(Database.BatchableContext BC) 
	{
		
	}
	
	private Map<Integer, List<Account>> constructAccountsWorkList(List<Account> accounts)
	{
		Map<Integer, List<Account>> indexToAccounts = new Map<Integer, List<Account>>();
		Integer currentIndex = 0;
		for(Account account : accounts) 
		{
			// Map the index to its list of Accounts. If no key yet exists,
			// create one and begin the Account list.
			if (indexToAccounts.containsKey(currentIndex))
			{
				indexToAccounts.get(currentIndex).add(account);
			}
			else 
			{
				indexToAccounts.put(currentIndex, new List<Account>{account});	
			}

			// If the current list size on this index exceeds our limit
			// per job, then increment the index.
			if (indexToAccounts.get(currentIndex).size() >= accountsPerJob)
			{
				currentIndex++;
			}
		}

		return indexToAccounts;
	}
}