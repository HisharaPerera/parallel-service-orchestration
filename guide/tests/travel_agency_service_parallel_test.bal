// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/test;

@test:BeforeSuite
function beforeFunc () {
    // Start the 'travelAgencyService' before running the test
    _ = test:startServices("travel_agency");

    // 'travelAgencyService' needs to communicate with airline reservation, hotel reservation and car rental services
    // Therefore, start these three services before running the test
    // Start the 'airlineReservationService'
    _ = test:startServices("airline_reservation");

    // Start the 'hotelReservationService'
    _ = test:startServices("hotel_reservation");

    // Start the 'carRentalService'
    _ = test:startServices("car_rental");
}

// Client endpoint
endpoint http:Client clientEP {
    url:"http://localhost:9090/travel"
};

// Function to test the Travel agency service
@test:Config
function testTravelAgencyService () {
    // Initialize the empty http requests and responses
    http:Request req;

    // Request Payload
    json requestPayload = {
        "ArrivalDate":"12-03-2018",
        "DepartureDate":"13-04-2018",
        "From":"Colombo",
        "To":"Changi",
        "VehicleType":"Car",
        "Location":"Changi"
    };

    // Set request payload
    req.setJsonPayload(requestPayload);
    // Send a 'post' request and obtain the response
    http:Response response = check clientEP -> post("/arrangeTour", request = req);
    // Expected response code is 200
    test:assertEquals(response.statusCode, 200, msg = "Travel agency service did not respond with 200 OK signal!");
    // Check whether the response is as expected
    // Flight details
    string expectedFlight = "{\"Airline\":\"Emirates\",\"ArrivalDate\":\"12-03-2018\",\"ReturnDate\":\"13-04-2018\"," +
        "\"From\":\"Colombo\",\"To\":\"Changi\",\"Price\":273}";
    json resPayload = check response.getJsonPayload();
    test:assertEquals(resPayload.Flight.toString(), expectedFlight, msg = "Response mismatch!");
    // Hotel details
    string expectedHotel = "{\"HotelName\":\"Elizabeth\",\"FromDate\":\"12-03-2018\"," +
        "\"ToDate\":\"13-04-2018\",\"DistanceToLocation\":2}";
    test:assertEquals(resPayload.Hotel.toString(), expectedHotel, msg = "Response mismatch!");
}

@test:AfterSuite
function afterFunc () {
    // Stop the 'travelAgencyService' after running the test
    test:stopServices("travel_agency");

    // Stop the 'airlineReservationService'
    test:stopServices("airline_reservation");

    // Stop the 'hotelReservationService'
    test:stopServices("hotel_reservation");

    // Stop the 'carRentalService'
    test:stopServices("car_rental");
}
