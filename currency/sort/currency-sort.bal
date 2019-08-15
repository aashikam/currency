import ballerina/io;
import ballerina/http;


http:Client httpClientEndpoint = new("https://free.currconv.com");

public function main() {
    string input = "";
    float[] currencyValues = [];
    map<any> currencyWithValues = {};
    string[] currencies = [];
    while (currencies.length() < 3) {
        input = io:readln("Enter currency code: ");
        currencies.push(input);
    }
    io:println("Sorting the currencies, ", currencies);
    fork {
        worker w1 {
            string convert = currencies[0] + "_LKR";
            var response = httpClientEndpoint->get("/api/v7/convert?q="+convert+"&compact=ultra&apiKey=2fa32c2fbaa2f2206338");
            float value = <@untainted>handleResponse(response, convert);
            currencyValues.push(value);
            currencyWithValues[value.toString()] = currencies[0];
        }
        worker w2 {
            string convert = currencies[1] + "_LKR";
            var response = httpClientEndpoint->get("/api/v7/convert?q="+convert+"&compact=ultra&apiKey=2fa32c2fbaa2f2206338");
            float value = <@untainted>handleResponse(response, convert);
            currencyValues.push(value);
            currencyWithValues[value.toString()] = currencies[1];
        }
        worker w3 {
            string convert = currencies[2] + "_LKR";
            var response = httpClientEndpoint->get("/api/v7/convert?q="+convert+"&compact=ultra&apiKey=2fa32c2fbaa2f2206338");
            float value = <@untainted>handleResponse(response, convert);
            currencyValues.push(value);
            currencyWithValues[value.toString()] = currencies[2];
        }
    }
    _ = wait {w1, w2, w3};

    io:println(currencyWithValues);
    float[] sorted = sortCurrencies(currencyValues);
    printSortedCurrencies(sorted, currencyWithValues);
}

function printSortedCurrencies(float[] sorted, map<any> currencyWithValues) {
    io:println("Sorted array is: ", sorted);
    string sortedString = "Sorted list: ";
    int i = sorted.length() - 1;
    while (0 <= i) {
        io:println(i);
        string key = sorted[i].toString();
		sortedString = sortedString + currencyWithValues[key].toString();
		i = i - 1;
	}
	io:println(sortedString);
}

function sortCurrencies(float[] currencyValues) returns float[] {
    float[] sortedValues = [];
    io:println(currencyValues);
    int n = currencyValues.length();
    int j = 1;
    int i = 0;
    float temp = 0;
    while(i < n){
        while(j < (n-i)){
            if(currencyValues[j-1] > currencyValues[j]){
                //swap elements
                temp = currencyValues[j-1];
                currencyValues[j-1] = currencyValues[j];
                currencyValues[j] = temp;
            }
            j = j +1;
        }
        i = i +1;
    }
    io:println(currencyValues);
    return currencyValues;
}

function handleResponse(http:Response|error response, string convert) returns  @tainted float {
    float value = 0.0;
    if (response is http:Response) {
        var msg = response.getJsonPayload();
        if (msg is json) {
            io:println(msg);
            if (msg is map<json>) {
                value = <float>msg[convert];
            }
        } else {
            io:println("Invalid payload received:" , msg.reason());
        }
    } else {
        io:println("Error when calling the backend: ", response.reason());
    }
    return value;
}
