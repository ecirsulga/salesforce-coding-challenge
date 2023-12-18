# Salesforce Senior Coding Challenge

We appreciate you taking the time to participate and submit a coding challenge! 🥳

In the next step we would like you to implement a simple Invocable Apex Action to be used by your Admin colleagues for a Flow. They need to do HTTP callouts to a NPS Service, whenever an Order got fulfilled. Below you will find a list of tasks and optional bonus points required for completing the challenge.

**🚀 This is a template repo, just use the green button to create your own copy and get started!**

### Invocable:

* accepts the Order Record Ids as Input Parameter
* queries the required records to get the Bill To E-Mail Address (`Contact.Email`) and OrderNumber (`Order.OrderNumber`)
* sends the data to the NPS API
* add a basic Flow, that executes your Action whenever an Order Status is changed to `Fulfilled`

### The Mock NPS API:

* Hosted at https://salesforce-coding-challenge.herokuapp.com
* ✨[API Documentation](https://thermondo.github.io/salesforce-coding-challenge/)
* 🔐 uses HTTP Basic Auth, username: `tmondo`, password: `Noy84LRpYvMZuETB`

### ⚠️ Must Haves:

* [ ] use `sfdx` and `git`, commit all code and metadata needed (so we can test with a scratch org)
* [ ] write good meaningful unit tests
* [ ] properly separate concerns
* [ ] make a list of limitations/possible problems

### ✨ Bonus Points:

* [ ] layer your Code (use [apex-common](https://github.com/apex-enterprise-patterns/fflib-apex-common) if you like)
* [ ] use Inversion of Control to write true unit tests and not integration tests
* [ ] make sure customers don't get duplicate emails
* [ ] think of error handling and return them to the Flow for the Admins to handle

### What if I don't finish?

Finishing these tasks should take about 2-3 hours, but we are all about **'quality > speed'**, so it's better to deliver a clean MVP and leave some TODOs open.

Try to produce something that is at least minimally functional. Part of the exercise is to see what you prioritize first when you have a limited amount of time. For any unfinished tasks, please do add `TODO` comments to your code with a short explanation. You will be given an opportunity later to go into more detail and explain how you would go about finishing those tasks.

---------------------------------------------------------------------------------------------------------------

Limitations/ Possible Problems:

Duplicate Emails: For this we can store custom logs and insert ids and date for every sent order than check it before sending new ones but I didnt make any changes in standart object. This could be ahieved in a real world scenario.

Bulk Data Processing: The code currently processes orders in batches, but it should be tested thoroughly with larger datasets to ensure it remains within Salesforce governor limits. It can exeed the heap limit.

Limited Error Handling: While there is basic error handling in place(because we dont update any record or get any meaningful responses from the callout so), more comprehensive error handling strategies may be needed, especially when dealing with real-world scenarios where API calls can fail for various reasons.

Hardcoded Credentials: API credentials are hardcoded in the code. In a production environment, consider using Named Credentials or a more secure credential management approach.

Unit Testing Limitations: Unit tests cover specific scenarios but may not provide complete coverage for all possible situations, We are not returning anything from an InvocableMethod and we dont make any changes in records so the testing I made may not show the real world scenarios. Additional test cases may be needed.

Integration Testing: The provided tests focus on individual components. Integration testing with the actual NPS API and end-to-end testing within a Salesforce environment may be necessary to ensure complete functionality.
