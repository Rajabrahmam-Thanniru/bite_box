import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;
import 'package:provider/provider.dart';

class PushNotificationService {
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "bite-box-ecb04",
      "private_key_id": "b68310039cd91792ad7d82761c44a7babb41e1cb",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDa2yie4vwTJPe6\ngZKQLO5XRK1rG/n/+Jgwa2aJQKkgI90o/rDGNeN+0gfhWj9BysaPkeXpYeL4WKEW\niqVSAI+x466wvPp3agm2edNw4IEyBv+9rnzoKI4Qg9UJszoGFzlJiRRnoPrs1lAm\nG7pIhVw7IMJbGdUmQufOZe7oakJPX8I2oQR+Et2/bKfkv8Hh6MVsOGVPOe/Yg0y+\n+nZlxnvVyr5lhEajSL3KywNoTDnil5P9H2plPc8gqhx592FvkEUxdpT+UXgA+fBg\n5qpSnxBXbbfq3gVmqR2L810l4nJxjanora/ZOFoV2l9ETAArU+rFNCV5qN0j2QaO\nJOMOTrLxAgMBAAECggEAM/FxFijUYCzVeRgYs4xecyrzJ+lHcCfN4ywSdX/5xA2P\nB5RPW3PdzzNFOIilW9WnQ9sCYN5hMsVCUmnMrAZDFJrv0rW/kokBziPi+bbnIvsD\nRr87mRRLB4NqlDdMDbcEWz4kMCZGd+CzvB+3mk/AoK35QwsCCmc1wkhyKApUO6cT\nuNndZyjgwVKh6mpRu/gtpKsozWocmM6i6RmaC+U5/kyzkynre0LbFm/cqNMrfqrD\niX6UwSyc2K7HI1SHK7iOWeLlHXVFz44UG0gp5OjXg75hpjj5DUPWl5muw9oS61yp\n9D52GNP1zvtqny2eZBwr0GICRPbR9zvh35f3YG+wuwKBgQDzFeqCSW5zx9QlMAr9\npdi0qE02PWv/7egXHZJSgYY4JH+24xjMSUBR81gnTZj6iZcBO01w8O/gMobCI8Cm\nV2wJofsA80oKvbv6cm0dH2zScIQkhu0nt1Id6CPcGn+DglS/yCNjy1baolJOrddu\nAth9M6FgP3Ip+GhE/+b4cDbCLwKBgQDme7WO3q8yDAOZvQnSA39FqAzEdb+mtiAS\nzQmVyGYvo0JbnyGgmQNaxx1bh4AU6ahpRy32uezQEwkUiRd+OCYsbZU4YZfTwEb6\nJaveqstnU3bt5ITe3bJDEgTObj7iogo5up+0I8T3GHbZBegfjBpbwoogmIrvNWI8\n9cZySvY03wKBgQDETWJ/rEUiArFzBoUZqKCD45XWw2s/1iOi5yKOtkJpfDAWxPX1\nowHqLBV4R9XOHOZw/C7hkfBkoOjqRm0A54A7ly9X6SBV5Dq1WUp8RjBfELXluYAy\nnnwV4q1yxYNL9Cf0Z+8MW9zb2lGVcBWUpX+mO9eKHjJXal7pua4P2q6dyQKBgBF2\n8kz/JrteGa++mU3mofA/SahhW8JgLpH+I2nMI6IcdtzGdB/dOFnamKjk3Zm4EuDX\nWe5GLGGf76I0uSkBTDM1oocBLiYHfdlanWlj+8G6m1pvZHoWxnk6lk6mH/HAYZH6\nSDu4MiafHfJX9jzduumVFi5eILj7jJQd84mZkIp1AoGBAJe9kZXeac/MNQGcwUa+\nmDilAbzogfknRDFSaTzCMKUr4xu71SlwurK83eXsE4GTFSV2iLBdpQR85g/FAddx\nXBL7k4/eAzF7XK1a61zcpQZSiTUFgzG82m7ELcdtYrZ3/OdMQFueFIHjApvCsJMd\n+xTyWf05qu1iDMwsDDTNuB+Q\n-----END PRIVATE KEY-----\n",
      "client_email": "bite-box1@bite-box-ecb04.iam.gserviceaccount.com",
      "client_id": "108507707934261079069",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/bite-box1%40bite-box-ecb04.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };
    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging",
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database"
    ];
    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    //get the access token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);
    client.close();
    return credentials.accessToken.data;
  }

  static sendNotificationToSelectedDriver(
      String deviceToken, BuildContext context, String orderID) async {
    final String serverAccessTokenKey = await getAccessToken();
    String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/bite-box-ecb04/messages:send';
    final Map<String, dynamic> messages = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': 'New Order',
          'body': 'You Have Received A New Order',
        },
        'data': {
          'orderID': orderID,
        }
      }
    };
    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': ' Bearer $serverAccessTokenKey'
      },
      body: jsonEncode(messages),
    );
    if (response.statusCode == 200) {
      print('Notification Sent');
    } else {
      print('Notification Failed');
    }
  }

  static sendNotificationToUser(String deviceToken, BuildContext context,
      String orderID, String title, String body) async {
    final String serverAccessTokenKey = await getAccessToken();
    String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/bite-box-ecb04/messages:send';
    final Map<String, dynamic> messages = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': '$title',
          'body': '$body',
        },
        'data': {
          'orderID': orderID,
        }
      }
    };
    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': ' Bearer $serverAccessTokenKey'
      },
      body: jsonEncode(messages),
    );
    if (response.statusCode == 200) {
      print('Notification Sent');
    } else {
      print('Notification Failed');
    }
  }
}
