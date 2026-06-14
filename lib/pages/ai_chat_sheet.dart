import 'package:flutter/material.dart';

class AiChatBottomSheet extends StatefulWidget {
  const AiChatBottomSheet({super.key});

  @override
  State<AiChatBottomSheet> createState() => _AiChatBottomSheetState();
}

class _AiChatBottomSheetState extends State<AiChatBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      "text": "Assalamu'alaikum! I am your DeenIQ AI Assistant. How can I help you today on your spiritual journey? You can ask me about Quran, Salat, Hijaiyah, or general Islamic knowledge.",
      "isMe": false,
      "time": "Just now"
    }
  ];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        "text": text,
        "isMe": true,
        "time": _getCurrentTime(),
      });
      _controller.clear();
    });

    _scrollToBottom();

    // Trigger AI response after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final aiResponse = _generateAiResponse(text);
      setState(() {
        _messages.add({
          "text": aiResponse,
          "isMe": false,
          "time": _getCurrentTime(),
        });
      });
      _scrollToBottom();
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _generateAiResponse(String query) {
    final cleanQuery = query.toLowerCase();

    if (cleanQuery.contains("quran") || cleanQuery.contains("koran")) {
      return "The Holy Qur'an is the verbatim word of Allah revealed to Prophet Muhammad (PBUH). You can read all 114 Surahs with transliteration and Indonesian translation directly in the 'Al-Quran' tab of this app.";
    } else if (cleanQuery.contains("sholat") || cleanQuery.contains("prayer") || cleanQuery.contains("salat")) {
      return "Salat is the second pillar of Islam and a key daily connection to Allah. The five mandatory prayers are Fajr (Dawn), Dhuhr (Noon), Asr (Afternoon), Maghrib (Sunset), and Isha (Night). You can find countdowns and offline prayer times on your home screen.";
    } else if (cleanQuery.contains("alif") || cleanQuery.contains("hijaiyah") || cleanQuery.contains("alphabet") || cleanQuery.contains("ta")) {
      return "The Arabic Alphabet (Hijaiyah) contains 28 letters. Learning their forms (Alone, Beginning, Middle, End) is the first step to reading the Quran. Explore the interactive learning table in the 'Alif Ba Ta' section under the Menu grid!";
    } else if (cleanQuery.contains("asmaul") || cleanQuery.contains("names") || cleanQuery.contains("nama")) {
      return "Asmaul Husna represents the 99 Beautiful Names of Allah. Reflecting upon these names helps us understand Allah's infinite mercy, wisdom, and power. You can browse all of them on the Asmaul Husna page.";
    } else if (cleanQuery.contains("hello") || cleanQuery.contains("hi") || cleanQuery.contains("assalamualaikum") || cleanQuery.contains("halo")) {
      return "Wa'alaikumussalam! May peace and blessings of Allah be upon you. What topic would you like to explore today?";
    } else {
      return "That's a profound question. Seeking knowledge is highly rewarded in Islam. For specific rulings or verses, you can look up details in the Al-Quran section, or consult with local scholars for complex matters. Is there anything else about Quran, Salat, or Hijaiyah I can help with?";
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep bottom sheet view responsive when keyboard pops up
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1621),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Header Drag Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Sheet Title Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.psychology, size: 20, color: Color(0xFF0F1621)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "DeenIQ AI Assistant",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          "Spiritual Guide Chatbot",
                          style: TextStyle(color: Colors.grey[400], fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg["isMe"] as bool;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF2563EB) : const Color(0xFF181F2B),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
                        bottomRight: isMe ? Radius.zero : const Radius.circular(15),
                      ),
                      border: isMe ? null : Border.all(color: Colors.white.withValues(alpha: 0.03)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg["text"]!,
                          style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                        ),
                        const SizedBox(height: 5),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            msg["time"]!,
                            style: const TextStyle(color: Colors.white38, fontSize: 9),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Input Send Bar
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Color(0xFF181F2B),
              border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: "Ask anything about Islam...",
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                      fillColor: const Color(0xFF0F1621),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Color(0xFF0F1621), size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
