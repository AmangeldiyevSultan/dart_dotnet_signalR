import 'package:logging/logging.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:http/http.dart' as http;

import '../server_url.dart';

void main() async {
  final serverUrl = kServerUrl;

  // Configer the logging
  Logger.root.level = Level.ALL;
// Writes the log messages to the console
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

//   final hubProtLogger = Logger("SignalR - hub");
// If youn want to also to log out transport messages:
//   final transportProtLogger = Logger("SignalR - transport");

//   final connectionOptions = HttpConnectionOptions();
  final httpOptions = HttpConnectionOptions(
      transport: HttpTransportType.longPolling,
      client: _HttpClient(
        defaultHeaders: {
          'Content-Type': 'application/json',
          // 'Accept': 'application/json',
        },
      ),
      // customHeaders: {
      //   'Content-Type': 'application/octet-stream',
      // },
      accessTokenFactory: () async => token,
      logMessageContent: true,
      logging: (level, message) => print('$level: $message'));

  final hubConnection = HubConnectionBuilder()
      .withUrl(serverUrl, httpOptions)
      .withAutomaticReconnect()
      .build();

  // await hubConnection.invoke('register');
  print('SignalR hubConnection register.');
  _startHubConnection(hubConnection);

  registerChatEvents(hubConnection).catchError((error) {
    print('Error registering chat events: $error');
  });
}

const String token =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxNDAiLCJuYW1lIjoiU3VsdGFuIiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvZW1haWxhZGRyZXNzIjoiYW1hbmdlbGRpZXZzdWx0YW4yMDAzQG1haWwucnUiLCJBc3BOZXQuSWRlbnRpdHkuU2VjdXJpdHlTdGFtcCI6IlhPN1VRWkk3SkIyVEFQUUlQQjU1UEZNVFVYN1RZWUoyIiwicm9sZSI6IkFkbWluIiwiaHR0cDovL3d3dy5hc3BuZXRib2lsZXJwbGF0ZS5jb20vaWRlbnRpdHkvY2xhaW1zL3RlbmFudElkIjoiMiIsImp0aSI6Ijg1ODhkODJkLWM5MjQtNGZlNC05N2MxLTk4ODg3MmRjMzM5ZiIsImlhdCI6MTcxMzE1NTAwMywidG9rZW5fdmFsaWRpdHlfa2V5IjoiYzgwZDZlNjAtM2M1Zi00YmZiLThkODEtMThjMzFjZGY1ZTUzIiwidXNlcl9pZGVudGlmaWVyIjoiMTQwQDIiLCJ0b2tlbl90eXBlIjoiMCIsInJlZnJlc2hfdG9rZW5fdmFsaWRpdHlfa2V5IjoiMmRlODgyNTktNGE0Yy00OWM2LTliN2MtYjQ2MGIwYmZlZGEzIiwibmJmIjoxNzEzMTU1MDAzLCJleHAiOjE3MTMyNDE0MDMsImlzcyI6IkxpbmtFZCIsImF1ZCI6IkxpbmtFZCJ9.P1ZddDYrjWDhvLk-J8B7JfTM8HJ6RH_n_e7ul16NpsM';

// ignore: constant_identifier_names
const String enc_token =
    'wNYmO41/48SHNstaLVXxHCCre29BZQl1NhC6NM3R3rwZiL572M4gBaHf6sHsTGZf8JSf1BnqkzjnGl4t1GT90L8aDHH9LXqcFuf9akDHhVKr/4M4YBuqEeVtlQT4i7KLkLntBbg+Y8tPipQ/6+kGvsVdJ8tDyhWe0zdzZKQiagWC/Kfh7zlNr5LfSqA8AVOv+I4KN2GzcjqgGMXAbpNF/zEQe7x2viVcgT6cAtIYXBmVS0Q/N4OMBycwuUscfW1Tkejz5NSSFlYgjBtGdEN+rIACD+k8YRqeLBTRtZCbsTLxSWQA+75DQUObhXwkaAfepyrSld23U1XSn2+8jd5awXD+CKUIqIsfbzl8DvKLWSTXmB6IWPVxHIUCS9vTq/ViTj9vHhwuec672J/JH1Xid7Y8VzaHii1als275AuJQ/8/SKUSFXKlAHSJi7h+POBwiSIjqm+8bKvYL5ja6TGHXshiiCq4NVPlwzLrK11XLGaJKJLUkZOoktUMA2Dhl2ZjunVOQ8HKX8JcEdQKUxo6Yfyauc1s28ApWanSpAb4i8FdTPKAll2B9PF2U4GnzOr0wf74r+7VzNn2FQf3wMlDU5KqBgxgWnDUPnm50/nLAu8iZdKqTBwUsnpVgBwViZ6dUbnvReW1bYy7awzvzoqsa3uB7msQ6HhIc81C/S1alhlOm/dd/qDnd/n/u9hU9YPsSzlwIhoL5LYwuAKny7RR7uFFjFWjnAUIJUKk83lXkBRCZIHCUGxB2QZqBO35MDUNd7pX5IIUNu1VX/JRI+1ShC9f/Wnlh15jJ5sG4pramzamwLQZadsafW0sICHe3lK0JWlwcgzdobBECxGGKlt8qxpEwclkzwI6Y7E/0nBv0kbGXbIhtqqmZc1adknMeHqhwFtd87iAnZyE8cdHoJlrst95hMBWONuC+TQMKhCFN/eI188EJr2X42S56NHvTgQnLnhL69CZuMv8IV51X3OZHvB1F0oLw4CSQHHh5FZW+x9J97a32npiVBGmfS867O+MeztvBzO/tXAn3uz7lsF8OHCh4RxWn583pMycT3v/oj2hJVRgiVOUoB8iMBn7xb6cnIlfXBxMEq6SEeEAbj6ALlwoC2UvYVmovZgckPMngvY=';

Future<void> _startHubConnection(HubConnection hubConnection) async {
  try {
    await hubConnection.start();
    print('SignalR hubConnection started.');

    await hubConnection.invoke('register');

    print('SignalR hubConnection register.');

    // await hubConnection.invoke('sendMethod', args: [arg1, arg2]).then((result) {
    //   print('Data sent: $arg1, $arg2');
    // }).catchError((error) {
    //   print('Error sending data: $error');
    // });
  } catch (e) {
    print('Error starting SignalR hubConnection: $e');
  }
}

Future<void> registerChatEvents(HubConnection hubConnection) async {
  // Register the event handler

  print('MY GET ALL FRIENDS');

  // hubConnection.on('getFriendshipRequest', ([friendData, isOwnRequest]) {
  //   print(
  //     'app.chat.friendshipRequestReceived $friendData, $isOwnRequest',
  //   );
  // });

  // hubConnection.on('getUserConnectNotification', ([friend, isConnected]) {
  //   print(
  //     'app.chat.userConnectionStateChanged $friend, $isConnected',
  //   );
  // });

  // hubConnection.on('getUserStateChange', ([friend, state]) {
  //   print(
  //     'app.chat.userStateChanged $friend, $state',
  //   );
  // });
  hubConnection.on(getAllFriends, (message) {
    print('getAllFriends event received: $message');
  });

  hubConnection.on(getWhatsAppMessage, (message) {
    print('IJFNSKJFNKJSDF');
    print('app.chat.whatsAppMessageReceived $message');
  });

  hubConnection.on(getChatMessage, (message) {
    print('huuhuh');

    print('app.chat.messageReceived $message');
  });

  hubConnection.on(getallUnreadWhatsAppMessagesRead, (requestId) {
    print('app.chat.allUnreadWhatsAppMessagesRead $requestId');
  });

  hubConnection.on(getallUnreadMessagesOfUserRead, (friend) {
    print('app.chat.allUnreadMessagesOfUserRead $friend');
  });

  hubConnection.on(getReadStateChange, (data) {
    print('app.chat.readStateChange $data');
  });

  hubConnection.on(getReadStateChangeChild, (data) {
    print('app.chat.readStateChangeChild $data');
  });
}

class _HttpClient extends http.BaseClient {
  _HttpClient({required this.defaultHeaders});
  final _httpClient = http.Client();
  final Map<String, String> defaultHeaders;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(defaultHeaders);
    return _httpClient.send(request);
  }
}
