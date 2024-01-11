#include <WiFi.h>
#include <PubSubClient.h>
#include <HTTPClient.h>

const char *ssid = "Malick's Mi";
const char *password = "Wic_K_eD";
const char *mqttServer = "test.mosquitto.org";
const int mqttPort = 1883;

const char *mqttTopic = "saadFarm";
const char *APIKey = "RYTY5Z9HLKHYWLCE";

WiFiClient espClient;
PubSubClient client(espClient);

void setup()
{
    Serial.begin(9600);
    delay(2000);
    connectToWifi();
    client.setServer(mqttServer, mqttPort);
    client.setCallback(callback);
    connectToBroker();
}

void loop()
{
    if (!client.connected())
    {
        connectToBroker();
    }
    if (!WiFi.isConnected())
    {
        connectToWifi();
    }
    client.loop();
    delay(1000);

    if (Serial.available())
    {
        char data = Serial.read();
        if (data == 'H')
        {
            sendDataToThingSpeak(1);
        }
        else if (data == 'L')
        {
            sendDataToThingSpeak(0);
        }
    }
}

void connectToBroker()
{
    while (!client.connected())
    {
        if (client.connect("ESP32Client"))
        {
          delay(100);
            client.subscribe(mqttTopic);
        }
        else
        {
            Serial.print("Failed, rc=");
            Serial.print(client.state());
            Serial.println(" Retrying in 2 seconds...");
            delay(2000);
        }
    }
}

void connectToWifi()
{
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED)
    {
        delay(1000);
        Serial.println("Connecting to WiFi...");
    }
    Serial.println("Connected to WiFi");
}

void sendDataToThingSpeak(int data)
{
    String url = "http://api.thingspeak.com/update?api_key=" + String(APIKey) + "&field1=" + String(data);
    HTTPClient http;
    http.begin(url);
    int httpCode = http.GET();

    if (httpCode > 0)
    {
       
    }
    else
    {
        Serial.printf("[HTTP] GET... failed, error: %s\n", http.errorToString(httpCode).c_str());
    }

    http.end();
}

void callback(char *topic, byte *payload, unsigned int length)
{
    Serial.print("Message received: ");
    for (int i = 0; i < length; i++)
    {
        Serial.print((char)payload[i]);
    }
    Serial.println();

    String receivedMessage = "";
    for (int i = 0; i < length; i++)
    {
        receivedMessage += (char)payload[i];
    }
   
    if (receivedMessage == "ON")
    {
        
        Serial.println('O');
    }
    else if (receivedMessage == "OFF")
    {
        Serial.println('F');
    }
    else
    {
      Serial.println("MQTT not recieved");
    }
}
