public class AccountProcessor implements Queueable 
{
	public Map<Integer, List<Account>> indexToAccounts;
	public Integer index;

	public AccountProcessor(Map<Integer, List<Account>> indexToAccounts, Integer index)
	{
		this.indexToAccounts = indexToAccounts;
		this.index = index;
	}

	public void execute(QueueableContext context) 
	{
		System.debug('AccountProcessor started');

		// If there are more records to process, enqueue next processing job
		if (indexToAccounts.containsKey(index + 1))
		{
			System.debug('Enqueuing next AccountProcessor...');
			System.enqueueJob(new AccountProcessor(indexToAccounts, index + 1));
		}

		// Retrieve Accounts from current index, process Accounts
		System.debug('indexToAccounts.get(' + index + '): ' + indexToAccounts.get(index).size());
		List<Account> accountsToProcess = processAccounts(indexToAccounts.get(index));
		System.debug('accountsToProcess.size(): ' + accountsToProcess.size());

		// Update accounts
		update accountsToProcess;
	}

	public List<Account> processAccounts(List<Account> accountsToProcess)
	{
		List<Account> revisedAccounts = new List<Account>();
		// Iterate through Accounts and process them
		for(Account account : accountsToProcess) 
		{
			account.Processed_Time__c = Datetime.now();

			revisedAccounts.add(account);
		}

		return revisedAccounts;
	}
}