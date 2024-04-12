import 'package:logging/logging.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../server_url.dart';

void main() async {
  final serverUrl = kServerUrl;

  // Configer the logging
  Logger.root.level = Level.ALL;
// Writes the log messages to the console
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  final hubProtLogger = Logger("SignalR - hub");
// If youn want to also to log out transport messages:
  final transportProtLogger = Logger("SignalR - transport");

  final connectionOptions = HttpConnectionOptions();
  final httpOptions = HttpConnectionOptions(logger: transportProtLogger);

  final hubConnection = HubConnectionBuilder()
      .withUrl(serverUrl, options: httpOptions)
      .configureLogging(hubProtLogger)
      .withAutomaticReconnect()
      .build();

  _startHubConnection(hubConnection);

  registerChatEvents(hubConnection);

  hubConnection.onclose(({error}) {
    print('hubConnection closed');
  });
}

Future<void> _startHubConnection(HubConnection hubConnection) async {
  try {
    await hubConnection.start();
    print('SignalR hubConnection started.');
  } catch (e) {
    print('Error starting SignalR hubConnection: $e');
  }
}

Future<void> registerChatEvents(HubConnection hubConnection) async {
  // Register the event handler
  print('MY GET ALL FRIENDS');
  hubConnection.on(getAllFriends, (message) {
    print('getAllFriends event received: $message');
  });

  hubConnection.on(getWhatsAppMessage, (message) {
    print('app.chat.whatsAppMessageReceived $message');
  });

  hubConnection.on(getChatMessage, (message) {
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
