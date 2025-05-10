import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trainerxpert/widgets/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  late GenerativeModel _model;
  bool _isLoading = false;
  bool _apiError = false;

  @override
  void initState() {
    super.initState();
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    debugPrint('API Key: ${apiKey.isEmpty ? "NOT FOUND" : "LOADED"}');

    if (apiKey.isEmpty) {
      _apiError = true;
      _messages.add(
        ChatMessage(
          text:
              "Configuration Error: API key not found. Please check your .env file.",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      return;
    }

    try {
      _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
      _addWelcomeMessage();
    } catch (e) {
      _apiError = true;
      _messages.add(
        ChatMessage(
          text: "Initialization Error: ${e.toString()}",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        text:
            "Hello! I'm your AI fitness trainer. How can I help you with your fitness goals today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_apiError) {
      _messages.add(
        ChatMessage(
          text: "Cannot send messages due to configuration error",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      return;
    }

    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: message, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    _messageController.clear();

    try {
      final response = await _model.generateContent(
        [
          Content.text("""
You are a professional Fitness Expert Chatbot.

Only respond to questions related to fitness, exercise, gym routines, nutrition, diet plans, supplements, fat loss, muscle gain, and recovery. 
Strictly DO NOT answer anything outside the fitness and wellness domain. If the user asks about anything unrelated (e.g., tech, academics, finance, etc.), simply respond with: 
"I’m your Fitness Expert Chatbot, and I can only help with fitness, health, and wellness-related topics."

User asked: $message
          """),
        ],
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
        ],
      );

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from API');
      }

      setState(() {
        _messages.add(
          ChatMessage(
            text: response.text!,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        _messages.add(
          ChatMessage(
            text: "Error: ${e.toString()}",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Trainer Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _messages[index],
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !_apiError,
                    decoration: InputDecoration(
                      hintText:
                          _apiError
                              ? 'Chat disabled due to error'
                              : 'Ask about workouts, nutrition...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color:
                      _apiError ? Colors.grey : Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
