import 'package:audio_chatgpt/model/chat_model.dart';
import 'package:audio_chatgpt/service/api_services.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

final ValueNotifier<double> _emiResult = ValueNotifier<double>(0.0);

class _SpeechScreenState extends State<SpeechScreen> {
  SpeechToText speechToText = SpeechToText();
  var text = "Hold the button and start speaking";
  var isListening = false;

  final List<ChatMessage> messages = [];
  var scrollcontroller = ScrollController();

  scrollMethod() {
    scrollcontroller.animateTo(scrollcontroller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.blueGrey.shade900,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        endRadius: 75,
        animate: isListening,
        duration: const Duration(milliseconds: 2000),
        glowColor: Colors.teal,
        repeatPauseDuration: const Duration(milliseconds: 100),
        showTwoGlows: true,
        child: GestureDetector(
          onTapDown: (details) async {
            if (!isListening) {
              var available = await speechToText.initialize();
              if (available) {
                setState(() {
                  isListening = true;
                  speechToText.listen(
                    onResult: (result) {
                      setState(() {
                        text = result.recognizedWords;
                      });
                    },
                  );
                });
              }
            }
          },
          onTapUp: (details) async {
            setState(() {
              isListening = false;
            });
            speechToText.stop();

            messages.add(ChatMessage(text: text, type: ChatMessageType.user));
            var msg = await ApiServices.sendMessage(text);

            setState(() {
              messages.add(ChatMessage(text: text, type: ChatMessageType.bot));
            });
          },
          child: CircleAvatar(
            backgroundColor: Colors.teal,
            radius: 35,
            child: Icon(
              isListening ? Icons.stop : Icons.mic_none,
              color: Colors.white,
            ),
          ),
        ),
      ),
      appBar: AppBar(
        leading: const Icon(Icons.sort_rounded, color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
        title: const Text('Voice assistant'),
        actions: [
          IconButton(
            onPressed: () {
              _emiResult.value = 0.0;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => const SpeechScreen()),
              );
            },
            icon: const Icon(Icons.restore),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
        child: Column(
          children: [
            Text(
              text,
              style: TextStyle(
                  color: isListening ? Colors.black87 : Colors.black54,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                    color: Colors.blueGrey.shade900,
                    borderRadius: BorderRadius.circular(12)),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  controller: scrollcontroller,
                  itemCount: messages.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    var chat = messages[index];
                    return chatBubble(chattext: chat.text, type: chat.type);
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            RichText(
              text: const TextSpan(
                text: 'Developer name   ',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w200,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'aj_labs',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget chatBubble({required chattext, required ChatMessageType? type}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CircleAvatar(
        backgroundColor: Colors.teal,
        child: type == ChatMessageType.bot
            ? const Icon(Icons.rocket)
            : const Icon(
                Icons.person,
                color: Colors.white,
              ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
              color: type == ChatMessageType.bot ? Colors.teal : Colors.white,
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12))),
          child: Text(
            '$chattext',
            style: TextStyle(
              color: type == ChatMessageType.bot
                  ? Colors.white
                  : Colors.blueGrey.shade800,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    ],
  );
}
