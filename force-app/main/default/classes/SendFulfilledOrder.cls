/**
 * Created by sulga on 16/12/2023.
 */

public without sharing class SendFulfilledOrder {

    @InvocableMethod(Label='SendFulfilledOrderById' Description='Gets required data from Orders and sends them to NPS API.')
    public static void sendRecords(List<Id> orderIds) {
        if (!orderIds.isEmpty()) {
            // Split the orderIds into batches of 30 and send each batch
            List<List<Id>> orderBatches = splitListIntoBatches(orderIds, 30);
            for (List<Id> batch : orderBatches) {
                sendRecordsAsyncCallout(batch);
            }
        }
    }
    private static List<List<Id>> splitListIntoBatches(List<Id> inputList, Integer batchSize) {
        List<List<Id>> batches = new List<List<Id>>();
        List<Id> currentBatch = new List<Id>();

        for (Id id : inputList) {
            currentBatch.add(id);

            if (currentBatch.size() >= batchSize) {
                batches.add(currentBatch);
                currentBatch = new List<Id>();
            }
        }

        if (currentBatch.size() > 0) {
            batches.add(currentBatch);
        }

        return batches;
    }
    private static List<Order> getFulfilledOrders(List<Id> orderIds) {
        return [SELECT Id, OrderNumber, Status, BillToContact.Email
        FROM Order
        WHERE Id IN :orderIds AND Status = 'Fulfilled'];
    }
    @Future(Callout=true)
    private static void sendRecordsAsyncCallout(List<Id> orderIds)
    {
        String responseMessage;
        List<OrderRequest> orderRequestList = new List<OrderRequest>();

        List<Order> orders = getFulfilledOrders(orderIds);
        if (!orders.isEmpty()) {
            for (Order o : orders) {
                orderRequestList.add(new OrderRequest(o.Id, o.OrderNumber, o.BillToContact.Email));
            }
        }

        responseMessage = sendHttpRequest(orderRequestList);
        System.debug(responseMessage);
    }

    private static String sendHttpRequest(List<OrderRequest> orderRequestList) {
        String responseMessage;
        Http http = new Http();
        HttpRequest request = createHttpRequest(JSON.serialize(orderRequestList));
        HttpResponse response = new HttpResponse();

        try {
            response = http.send(request);
            if (response.getStatusCode() == 200) {

                if (String.isNotBlank(response.getBody())) {
                    responseMessage = 'Successful - Response Body:' + response.getBody();
                } else {
                    responseMessage = 'Successful Empty - Response Body:' + response.getBody();
                }
            } else {
                responseMessage = 'Not Successful - Response Code: ' + response.getStatusCode() + 'Not Successful - Response Body:' + response.getBody();
            }
        } catch (Exception e) {
            responseMessage = 'Order Send Service threw an Exception ' + e.getMessage();
        }
        return responseMessage;
    }

    private class OrderRequest {
        private OrderRequest(String sfId, String orderNumber, String customerEmail) {
            this.sfId = sfId;
            this.orderNumber = orderNumber;
            this.customerEmail = customerEmail;
        }

        String sfId{ get; set; }
        String orderNumber{ get; set; }
        String customerEmail{ get; set; }
    }

    private static HttpRequest createHttpRequest(String body) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Thermondo_NPS_API');
        request.setHeader('Content-Type','application/json; charset=UTF-8');
        request.setMethod('POST');
        request.setBody(body);
        System.debug('Request Body: ' + body);
        return request;
    }

}