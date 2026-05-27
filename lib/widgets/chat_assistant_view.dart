import 'dart:async';
import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../data/vehicle_data.dart';
import '../services/gemini_service.dart';
import 'glass_card.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class ChatAssistantView extends StatefulWidget {
  final Vehicle? currentVehicle;

  const ChatAssistantView({super.key, this.currentVehicle});

  @override
  State<ChatAssistantView> createState() => _ChatAssistantViewState();
}

class _ChatAssistantViewState extends State<ChatAssistantView> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<String> _suggestions = [
    'What is Nexon\'s mileage?',
    'Creta diesel vs petrol?',
    'Activa 6G features?',
    'Swift price range?',
    'Splendor plus average ketli che?',
    'Access 125 dimensions?'
  ];

  @override
  void initState() {
    super.initState();
    // Welcome message
    String welcomeText = 'Hello! I am your AI Auto Mechanic assistant. 🤖\n'
        'You can ask me questions about specifications, mileage, or pricing.\n'
        'Ask me in English, Hindi, or Gujarati! \n'
        'Example: "Nexon nu mileage ketlu che?" or "Creta diesel hai ya petrol?"';
    
    if (widget.currentVehicle != null) {
      welcomeText = 'Hello! I see you are looking at the ${widget.currentVehicle!.brand} ${widget.currentVehicle!.model}. 🔍\n'
          'Ask me anything about this vehicle, its features, engine condition, or estimated market value!';
    }

    _messages.add(ChatMessage(
      text: welcomeText,
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final apiKey = await GeminiService.getApiKey() ?? GeminiService.defaultApiKey;
      final reply = await GeminiService.generateChatResponse(text, apiKey, widget.currentVehicle);
      
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: reply,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } catch (e) {
      // Offline fallback
      final reply = _generateAIResponse(text);
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: reply,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    }
    _scrollToBottom();
  }

  String _generateAIResponse(String query) {
    final clean = query.toLowerCase();

    // Determine target vehicle in query
    Vehicle? v = widget.currentVehicle;
    for (var vehicle in VehicleDatabase.vehicles) {
      if (clean.contains(vehicle.model.toLowerCase()) || clean.contains(vehicle.brand.toLowerCase())) {
        v = vehicle;
        break;
      }
    }

    // Language detection
    bool isGujarati = clean.contains('che') || clean.contains('ketlu') || clean.contains('ketli') || clean.contains('aape') || clean.contains('nathi') || clean.contains('chale');
    bool isHindi = clean.contains('hai') || clean.contains('kya') || clean.contains('kitna') || clean.contains('kitni') || clean.contains('deta') || clean.contains('deti');

    if (v == null) {
      if (isGujarati) {
        return 'મને કોઈ ચોક્કસ વાહન વિશે પૂછો જેમ કે: Swift, Nexon, Creta, Activa, Splendor, Access. હું તમને તેની કિંમત અને માઇલેજ જણાવીશ.';
      }
      if (isHindi) {
        return 'कृपया किसी विशिष्ट वाहन (जैसे Swift, Nexon, Creta, Activa) के बारे में पूछें। मैं उसकी कीमत, माइलेज और इंजन की जानकारी दे सकता हूँ।';
      }
      return 'I couldn\'t identify which vehicle you are asking about. Please mention a popular model like Swift, Nexon, Creta, Activa, Splendor, or Access 125!';
    }

    final modelName = '${v.brand} ${v.model}';

    // 1. MILEAGE queries
    if (clean.contains('mileage') || clean.contains('average') || clean.contains('kmpl') || clean.contains('milage') || clean.contains('kitna deti')) {
      if (isGujarati) {
        return '$modelName ની માઇલેજ આશરે ${v.mileage} છે. શહેરમાં તે ${v.cityMileage} અને હાઇવે પર ${v.highwayMileage} ની એવરેજ આપે છે.';
      }
      if (isHindi) {
        return '$modelName का माइलेज लगभग ${v.mileage} है। शहर में यह ${v.cityMileage} और हाईवे पर ${v.highwayMileage} की माइलेज देती है।';
      }
      return 'The official mileage for the $modelName is ${v.mileage}. In cities, it delivers around ${v.cityMileage}, and on highway stretches it reaches up to ${v.highwayMileage}.';
    }

    // 2. FUEL type queries
    if (clean.contains('fuel') || clean.contains('petrol') || clean.contains('diesel') || clean.contains('cng') || clean.contains('electric') || clean.contains('koyla') || clean.contains('indhan')) {
      if (isGujarati) {
        return '$modelName માં ${v.fuelType} એન્જિન આવે છે. આ મોડેલ ટ્રાન્સમિશનમાં ${v.transmission} પ્રદાન કરે છે.';
      }
      if (isHindi) {
        return '$modelName में ${v.fuelType} इंजन मिलता है। यह ${v.transmission} ट्रांसमिशन के साथ उपलब्ध है।';
      }
      return 'The $modelName runs on ${v.fuelType}. It features a ${v.engineCC} displacement motor paired with a ${v.transmission} transmission setup.';
    }

    // 3. PRICE queries
    if (clean.contains('price') || clean.contains('kimat') || clean.contains('kimmmat') || clean.contains('rupees') || clean.contains('lakh') || clean.contains('kitne ki') || clean.contains('bhav') || clean.contains('paisa')) {
      if (isGujarati) {
        return '$modelName ની શોરૂમ કિંમત આશરે ${v.priceRange} છે. જૂની સેકન્ડ-હેન્ડ માર્કેટમાં આશરે ${v.usedPriceRange} ની આજુબાજુ મળી શકે છે.';
      }
      if (isHindi) {
        return '$modelName की एक्स-शोरूम कीमत ${v.priceRange} है। सेकंड-हैंड बाजार में यह ${v.usedPriceRange} तक मिल सकती है।';
      }
      return 'The $modelName ex-showroom price is ${v.priceRange}. If you are looking in the used car market, its estimated value is between ${v.usedPriceRange}.';
    }

    // 4. ENGINE / POWER queries
    if (clean.contains('engine') || clean.contains('power') || clean.contains('torque') || clean.contains('cc') || clean.contains('bhp') || clean.contains('taqat')) {
      if (isGujarati) {
        return '$modelName માં ${v.engineCC} નું એન્જિન છે, જે ${v.power} પાવર અને ${v.torque} ટોર્ક જનરેટ કરે છે.';
      }
      if (isHindi) {
        return '$modelName में ${v.engineCC} का इंजन है, जो ${v.power} की पावर और ${v.torque} का टॉर्क देता है।';
      }
      return 'The $modelName is powered by a ${v.engineCC} motor generating ${v.power} and a peak torque of ${v.torque}.';
    }

    // 5. FEATURES / COMFORT queries
    if (clean.contains('feature') || clean.contains('safety') || clean.contains('sunroof') || clean.contains('airbag') || clean.contains('abs') || clean.contains('bluetooth') || clean.contains('suvidha')) {
      final featuresList = v.features.values.expand((element) => element).take(3).join(', ');
      if (isGujarati) {
        return '$modelName માં ઘણા પ્રીમિયમ ફીચર્સ છે જેમ કે: $featuresList. આમાં સેફ્ટી માટે એરબેગ્સ અને ABS સ્ટાન્ડર્ડ છે.';
      }
      if (isHindi) {
        return '$modelName में कई फीचर्स मिलते हैं जैसे: $featuresList. इसमें पैसेंजर सुरक्षा के लिए एयरबैग और ABS शामिल हैं।';
      }
      return 'The key features on $modelName include: $featuresList. It also includes comprehensive safety features like dual/6 airbags, ABS, and stability controls.';
    }

    // 6. DEFAULT response with basic specs
    if (isGujarati) {
      return '$modelName એક સરસ ${v.type} છે. આમાં ${v.engineCC} નું ${v.fuelType} એન્જિન છે. શોરૂમ કિંમત ${v.priceRange} છે. તમે માઇલેજ, એન્જિન અથવા ફીચર્સ વિશે પૂછી શકો છો!';
    }
    if (isHindi) {
      return '$modelName एक शानदार ${v.type} है। इसमें ${v.engineCC} का ${v.fuelType} इंजन लगा है जिसकी कीमत ${v.priceRange} है। आप इसके एक्सीडेंट हिस्ट्री या पार्ट्स के बारे में भी पूछ सकते हैं।';
    }
    return 'The $modelName is a ${v.year} ${v.type} configured with a ${v.engineCC} (${v.fuelType}) powerplant. It boasts an average mileage of ${v.mileage} with a price range of ${v.priceRange}. Ask me for specific details like mileage, safety features, or components health!';
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Suggestion Chips (if message list is short)
        if (_messages.length < 4)
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(
                      _suggestions[index],
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    backgroundColor: Colors.white.withAlpha(12),
                    side: BorderSide(color: Colors.white.withAlpha(15)),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    onPressed: () => _sendMessage(_suggestions[index]),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 8),

        // Messages List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length && _isTyping) {
                return _buildTypingIndicator();
              }

              final msg = _messages[index];
              return _buildMessageBubble(msg);
            },
          ),
        ),

        // Input Field
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(12),
            border: Border(top: BorderSide(color: Colors.white.withAlpha(15))),
          ),
          child: Row(
            children: [
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  borderRadius: 24,
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Ask in English, ગુજરાતી, or हिंदी...',
                      hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                      border: InputBorder.none,
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.cyanAccent, Colors.purpleAccent],
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.black87, size: 20),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return FadeInPoint(
      delayMs: 0,
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          borderRadius: 16,
          fillGradientStart: isUser ? Colors.cyanAccent.withAlpha(35) : Colors.white.withAlpha(12),
          fillGradientEnd: isUser ? Colors.purpleAccent.withAlpha(15) : Colors.white.withAlpha(5),
          customBorder: Border.all(
            color: isUser ? Colors.cyanAccent.withAlpha(120) : Colors.white.withAlpha(20),
            width: 1.0,
          ),
          child: Text(
            msg.text,
            style: const TextStyle(color: Color(0xE6FFFFFF), fontSize: 13.5, height: 1.4),
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        width: 70,
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          borderRadius: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (index) {
              return _PulsingDot(delayMs: index * 200);
            }),
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final int delayMs;
  const _PulsingDot({required this.delayMs});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) {
        _dotController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + (_dotController.value * 0.7),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.cyanAccent,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
