/**
 * Created by sulga on 18/12/2023.
 */

@IsTest
private class SendFulfilledOrderTest {

    public class MockHttpResponseGenerator implements HttpCalloutMock {

        public Integer statusCode;
        public String body;
        public MockHttpResponseGenerator(String body, Integer statusCode) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(statusCode);
            return res;
        }
    }
    @TestSetup
    static void testData() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User user = new User(
                Alias = 'test',
                Email = 'testUser@test.com.test',
                EmailEncodingKey = 'UTF-8',
                LastName = 'tester',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = profile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                Username = 'testUser@tester.com.test',
                IsActive = true
        );
        insert user;

        Account testAcc = new Account(
                Name = 'testAccount',
                AccountNumber = '1234567'
        );
        insert testAcc;

        Contract testContract = new Contract(
                ContractTerm = 1,
                StartDate = Date.newInstance(2023, 1, 1),
                AccountId = testAcc.Id,
                Status = 'Draft'
        );
        insert testContract;
        testContract.Status='Activated';
        update testContract;

        Contact testContact = new Contact(
                AccountId = testAcc.Id,
                LastName = 'Tester',
                Email = 'test@mail.com'
        );
        insert testContact;

        Pricebook2 priceBook = new Pricebook2(
                Name = 'Example Price Book',
                Description = 'This is the Price Book description.',
                IsActive = true
        );

        insert priceBook;

        Product2 product = new Product2(
                Name = 'Example Product',
                Family = 'Example Product Family',
                QuantityUnitOfMeasure = 'inches',
                IsActive = true
        );

        insert product;

        Id standardPriceBook = Test.getStandardPricebookId();


        PricebookEntry standardPriceBookEntry = new PricebookEntry(
                Pricebook2Id = standardPriceBook,
                Product2Id = product.Id,
                UnitPrice = 100.00,
                UseStandardPrice = false,
                IsActive = true
        );

        insert standardPriceBookEntry;

        PricebookEntry priceBookEntry = new PricebookEntry(
                Pricebook2Id = priceBook.Id,
                Product2Id = product.Id,
                UnitPrice = 100.00,
                UseStandardPrice = false,
                IsActive = true
        );

        insert priceBookEntry;

        Order testOrder1 = new Order(
                AccountId = testAcc.Id,
                EffectiveDate = Date.newInstance(2023, 1, 1),
                Status = 'Draft',
                ContractId=testContract.Id,
                BillToContactId = testContact.Id,
                Pricebook2Id = standardPriceBook
        );
        insert testOrder1;

        OrderItem testOrderItem1 = new OrderItem(
                OrderId = testOrder1.Id,
                PricebookEntryId = standardPriceBookEntry.Id,
                Quantity = 1,
                UnitPrice = 100
        );
        insert testOrderItem1;

        testOrder1.Status='Fulfilled';
        update testOrder1;

        Order testOrder2 = new Order(
                AccountId = testAcc.Id,
                EffectiveDate = Date.newInstance(2023, 1, 1),
                Status = 'Draft',
                ContractId=testContract.Id,
                BillToContactId = testContact.Id,
                Pricebook2Id = standardPriceBook
        );
        insert testOrder2;

        Order testOrder3 = new Order(
                AccountId = testAcc.Id,
                EffectiveDate = Date.newInstance(2023, 1, 1),
                Status = 'Draft',
                ContractId=testContract.Id,
                BillToContactId = testContact.Id,
                Pricebook2Id = standardPriceBook
        );
        insert testOrder3;

        OrderItem testOrderItem2 = new OrderItem(
                OrderId = testOrder3.Id,
                PricebookEntryId = standardPriceBookEntry.Id,
                Quantity = 1,
                UnitPrice = 100
        );
        insert testOrderItem2;


        testOrder3.Status='Fulfilled';
        update testOrder3;
    }


    @IsTest
    static void testSendRecords(){
        //We are not returning anything from an InvocableMethod and we dont make any changes in records so the testing I made may not show the real world scenarios
        String responseBodyMock = '{Empty}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(responseBodyMock,200));
        List<Id> orderIds=new List<Id>();
        List<Order> testOrders = [SELECT Id, Status FROM Order WHERE Status = 'Empty' LIMIT 1];
        for(Order testOrder : testOrders)
        {
            orderIds.add(testOrder.Id);
        }
        SendFulfilledOrder.sendRecords(orderIds);
        System.assertEquals(0, Limits.getFutureCalls()); // There is no future calls when sending empty list
        Test.stopTest();
    }

    @IsTest
    static void testSendRecordsOneOrder200(){
        //We are not returning anything from an InvocableMethod and we dont make any changes in records so the testing I made may not show the real world scenarios
        String responseBodyMock = '{SUCCESS}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(responseBodyMock,200));
        List<Id> orderIds=new List<Id>();
        List<Order> testOrders = [SELECT Id, Status FROM Order WHERE Status = 'Fulfilled' LIMIT 1];
        for(Order testOrder : testOrders)
        {
            orderIds.add(testOrder.Id);
        }
        SendFulfilledOrder.sendRecords(orderIds);
        System.assertEquals(1, Limits.getFutureCalls()); // There is 1 future call when sending a correct list with 200 mock http status
        Test.stopTest();
    }

    @IsTest
    static void testSendRecordsSeveralOrders200(){
        //We are not returning anything from an InvocableMethod and we dont make any changes in records so the testing I made may not show the real world scenarios
        String responseBodyMock = '{SUCCESS}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(responseBodyMock,200));
        List<Id> orderIds=new List<Id>();
        List<Order> testOrders = [SELECT Id, Status FROM Order WHERE Status = 'Fulfilled' LIMIT 2];
        for(Order testOrder : testOrders)
        {
            orderIds.add(testOrder.Id);
        }
        SendFulfilledOrder.sendRecords(orderIds);
        System.assertEquals(1, Limits.getFutureCalls()); // There is 1 future call when sending a correct list with 200 mock http status
        Test.stopTest();
    }
    @IsTest
    static void testSendRecords200ButEmptyBody(){
        //We are not returning anything from an InvocableMethod and we dont make any changes in records so the testing I made may not show the real world scenarios
        String responseBodyMock = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(responseBodyMock,200));
        List<Id> orderIds=new List<Id>();
        List<Order> testOrders = [SELECT Id, Status FROM Order WHERE Status = 'Fulfilled' LIMIT 2];
        for(Order testOrder : testOrders)
        {
            orderIds.add(testOrder.Id);
        }
        SendFulfilledOrder.sendRecords(orderIds);
        System.assertEquals(1, Limits.getFutureCalls()); // There is 1 future call when sending an empty list with 200 mock http status
        Test.stopTest();
    }
    @IsTest
    static void testSubmitQueryToSAP500(){
        //We are not returning anything from an InvocableMethod and we dont make any changes in records so the testing I made may not show the real world scenarios
        String responseBodyMock = '{Internal Server Error}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(responseBodyMock,500));
        List<Id> orderIds=new List<Id>();
        List<Order> testOrders = [SELECT Id, Status FROM Order WHERE Status = 'Fulfilled' LIMIT 1];
        for(Order testOrder : testOrders)
        {
            orderIds.add(testOrder.Id);
        }
        SendFulfilledOrder.sendRecords(orderIds);
        System.assertEquals(1, Limits.getFutureCalls()); // There is 1 future call when sending a correct list with 500 mock http status
        Test.stopTest();
    }
    @IsTest
    static void testSubmitQueryToSAPCatchBlock(){

        //We are not returning anything from an InvocableMethod and we dont make any changes in records so the testing I made may not show the real world scenarios
        String responseBodyMock = '{Internal Server Error}';
        Test.startTest();
        List<Id> orderIds=new List<Id>();
        List<Order> testOrders = [SELECT Id, Status FROM Order WHERE Status = 'Fulfilled' LIMIT 1];
        for(Order testOrder : testOrders)
        {
            orderIds.add(testOrder.Id);
        }
        try{
            SendFulfilledOrder.sendRecords(orderIds);
        }
        catch (Exception e) {
            System.debug('catchBlockForTest: '+  e.getMessage());
        }
        Test.stopTest();
    }
}