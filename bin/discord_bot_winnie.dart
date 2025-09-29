import 'package:nyxx/nyxx.dart';
import 'package:ollama_dart/ollama_dart.dart';

void main() async {
  final ollamaClient = OllamaClient();

  final res = await ollamaClient.listModels();
  print(res.models);

  // await ollamaRespond(ollamaClient, 'Why is the sky blue?');

  final clientNyxx = await Nyxx.connectGateway(
    'TOKEN', // Replace this with your bot's token
    GatewayIntents.allUnprivileged,
    options: GatewayClientOptions(plugins: [logging, cliIntegration]),
  );

  final botUser = await clientNyxx.users.fetchCurrentUser();

  clientNyxx.onMessageCreate.listen((event) async {
    if (event.mentions.contains(botUser)) {
      print(event.message.content);
      await event.message.channel.sendMessage(
        MessageBuilder(
          content: await ollamaRespond(ollamaClient, event.message.content),
          // referencedMessage: event.message.id,
        ),
      );
    }
  });
}

Future<String> ollamaRespond(OllamaClient ollamaClient, String prompt) async {
  final generated = await ollamaClient.generateCompletion(
    request: GenerateCompletionRequest(
      model: 'gemma3n:latest',
      prompt:
          'Only reply short answers, 10 words max, be whimsical and cute, dont ask questions, reply to this: $prompt',
    ),
  );
  print('Winnie responds: ${generated.response}');
  return generated.response!;
}
