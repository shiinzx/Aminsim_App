import 'package:flutter/material.dart';

class AlifBaTaPage extends StatefulWidget {
  const AlifBaTaPage({super.key});

  @override
  State<AlifBaTaPage> createState() => _AlifBaTaPageState();
}

class _AlifBaTaPageState extends State<AlifBaTaPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // List of Alphabet letters
  final List<Map<String, String>> _alphabetList = const [
    {"letter": "ا", "name": "Alif", "trans": "a", "desc": "Sound: like 'a' in father"},
    {"letter": "ب", "name": "Ba", "trans": "b", "desc": "Sound: like 'b' in bed"},
    {"letter": "ت", "name": "Ta", "trans": "t", "desc": "Sound: like 't' in tea"},
    {"letter": "ث", "name": "Tha", "trans": "th", "desc": "Sound: soft 'th' like 'th' in think"},
    {"letter": "ج", "name": "Jeem", "trans": "j", "desc": "Sound: like 'j' in jam"},
    {"letter": "ح", "name": "Haa", "trans": "ḥ", "desc": "Sound: sharp, raspy 'h' from middle throat"},
    {"letter": "خ", "name": "Khaa", "trans": "kh", "desc": "Sound: rough 'kh' sound like ch in loch"},
    {"letter": "د", "name": "Dal", "trans": "d", "desc": "Sound: like 'd' in door"},
    {"letter": "ذ", "name": "Dhal", "trans": "dh", "desc": "Sound: like 'th' in this"},
    {"letter": "ر", "name": "Ra", "trans": "r", "desc": "Sound: rolled 'r' like Spanish 'r'"},
    {"letter": "ز", "name": "Zay", "trans": "z", "desc": "Sound: like 'z' in zoo"},
    {"letter": "س", "name": "Seen", "trans": "s", "desc": "Sound: sharp 's' like 's' in sun"},
    {"letter": "ش", "name": "Sheen", "trans": "sh", "desc": "Sound: like 'sh' in shoe"},
    {"letter": "ص", "name": "Saad", "trans": "ṣ", "desc": "Sound: heavy, emphatic 's'"},
    {"letter": "ض", "name": "Daad", "trans": "ḍ", "desc": "Sound: heavy, emphatic 'd'"},
    {"letter": "ط", "name": "Taa", "trans": "ṭ", "desc": "Sound: heavy, emphatic 't'"},
    {"letter": "ظ", "name": "Zaa", "trans": "ẓ", "desc": "Sound: heavy, emphatic voiced 'th'"},
    {"letter": "ع", "name": "Ayn", "trans": "‘", "desc": "Sound: guttural compression from throat"},
    {"letter": "غ", "name": "Ghayn", "trans": "gh", "desc": "Sound: gargled 'g' like Parisian 'r'"},
    {"letter": "ف", "name": "Fa", "trans": "f", "desc": "Sound: like 'f' in far"},
    {"letter": "ق", "name": "Qaf", "trans": "q", "desc": "Sound: deep guttural 'k' from back throat"},
    {"letter": "ك", "name": "Kaf", "trans": "k", "desc": "Sound: like 'k' in king"},
    {"letter": "ل", "name": "Lam", "trans": "l", "desc": "Sound: like 'l' in love"},
    {"letter": "م", "name": "Meem", "trans": "m", "desc": "Sound: like 'm' in man"},
    {"letter": "ن", "name": "Noon", "trans": "n", "desc": "Sound: like 'n' in net"},
    {"letter": "و", "name": "Waw", "trans": "w / u", "desc": "Sound: like 'w' in win or 'oo' in pool"},
    {"letter": "ه", "name": "Haa (Heh)", "trans": "h", "desc": "Sound: light 'h' like 'h' in home"},
    {"letter": "ي", "name": "Ya", "trans": "y / i", "desc": "Sound: like 'y' in yellow or 'ee' in seed"},
  ];

  // Forms of letters (Alone, Beginning, Middle, End)
  final List<Map<String, String>> _letterForms = const [
    {"alone": "ا", "begin": "ا", "middle": "ـا", "end": "ـا", "name": "Alif"},
    {"alone": "ب", "begin": "بـ", "middle": "ـبـ", "end": "ـب", "name": "Ba"},
    {"alone": "ت", "begin": "تـ", "middle": "ـتـ", "end": "ـت", "name": "Ta"},
    {"alone": "ث", "begin": "ثـ", "middle": "ـثـ", "end": "ـث", "name": "Tha"},
    {"alone": "ج", "begin": "جـ", "middle": "ـجـ", "end": "ـج", "name": "Jeem"},
    {"alone": "ح", "begin": "حـ", "middle": "ـحـ", "end": "ـح", "name": "Haa"},
    {"alone": "خ", "begin": "خـ", "middle": "ـخـ", "end": "ـخ", "name": "Khaa"},
    {"alone": "د", "begin": "د", "middle": "ـد", "end": "ـد", "name": "Dal"},
    {"alone": "ذ", "begin": "ذ", "middle": "ـذ", "end": "ـذ", "name": "Dhal"},
    {"alone": "ر", "begin": "ر", "middle": "ـر", "end": "ـر", "name": "Ra"},
    {"alone": "ز", "begin": "ز", "middle": "ـز", "end": "ـز", "name": "Zay"},
    {"alone": "س", "begin": "سـ", "middle": "ـسـ", "end": "ـس", "name": "Seen"},
    {"alone": "ش", "begin": "شـ", "middle": "ـشـ", "end": "ـش", "name": "Sheen"},
    {"alone": "ص", "begin": "صـ", "middle": "ـصـ", "end": "ـص", "name": "Saad"},
    {"alone": "ض", "begin": "ضـ", "middle": "ـضـ", "end": "ـض", "name": "Daad"},
    {"alone": "ط", "begin": "طـ", "middle": "ـطـ", "end": "ـط", "name": "Taa"},
    {"alone": "ظ", "begin": "ظـ", "middle": "ـظـ", "end": "ـظ", "name": "Zaa"},
    {"alone": "ع", "begin": "عـ", "middle": "ـعـ", "end": "ـع", "name": "Ayn"},
    {"alone": "غ", "begin": "غـ", "middle": "ـغـ", "end": "ـغ", "name": "Ghayn"},
    {"alone": "ف", "begin": "فـ", "middle": "ـفـ", "end": "ـف", "name": "Fa"},
    {"alone": "ق", "begin": "قـ", "middle": "ـقـ", "end": "ـق", "name": "Qaf"},
    {"alone": "ك", "begin": "كـ", "middle": "ـكـ", "end": "ـك", "name": "Kaf"},
    {"alone": "ل", "begin": "لـ", "middle": "ـلـ", "end": "ـل", "name": "Lam"},
    {"alone": "م", "begin": "مـ", "middle": "ـمـ", "end": "ـم", "name": "Meem"},
    {"alone": "ن", "begin": "نـ", "middle": "ـنـ", "end": "ـن", "name": "Noon"},
    {"alone": "و", "begin": "و", "middle": "ـو", "end": "ـو", "name": "Waw"},
    {"alone": "ه", "begin": "هـ", "middle": "ـهـ", "end": "ـه", "name": "Haa"},
    {"alone": "ي", "begin": "يـ", "middle": "ـيـ", "end": "ـي", "name": "Ya"},
  ];

  // Tajweed rules list
  final List<Map<String, String>> _tajweedRules = const [
    {
      "title": "Izhar Halqi (إظهار حلقي)",
      "rule": "Read clearly without nasalization.",
      "desc": "Occurs when Noon Sakinah (نْ) or Tanween (ً  ٍ  ٌ) is followed by one of the throat letters: ء, هـ, ع, ح, غ, خ."
    },
    {
      "title": "Idgham (إدغام)",
      "rule": "Merge/blend the letters.",
      "desc": "Occurs when Noon Sakinah or Tanween is followed by letters of يَرْمُلُونَ. Divided into Idgham Bighunnah (with nasalization: ي, ن, م, و) and Idgham Bila Ghunnah (without nasalization: ل, ر)."
    },
    {
      "title": "Ikhfa Haqiqi (إخفاء حقيقي)",
      "rule": "Hide/nasalize the sound.",
      "desc": "Occurs when Noon Sakinah or Tanween is followed by any of the remaining 15 letters. The sound is pronounced from the nose for 2 counts."
    },
    {
      "title": "Iqlab (إقلاب)",
      "rule": "Convert Noon sound to Meem (م).",
      "desc": "Occurs when Noon Sakinah or Tanween is followed by the letter Ba (ب). The sound is converted to a light Meem with ghunnah."
    },
    {
      "title": "Qalqalah (قلقلة)",
      "rule": "Echo or bouncing sound.",
      "desc": "Occurs when one of the five letters of قُطْبُ جَدّ (ق, ط, ب, ج, د) carries a Sukun or is stopped at. The sound is echoed."
    },
  ];

  // Noorani lessons
  final List<Map<String, String>> _nooraniLessons = const [
    {
      "lesson": "Lesson 1: Single Letters",
      "desc": "Learn the individual letters of the Arabic alphabet with their correct names and phonetic origins (Makharij)."
    },
    {
      "lesson": "Lesson 2: Compound Letters (Murakkabat)",
      "desc": "Understand how Arabic letters join together in words, recognizing their forms when combined."
    },
    {
      "lesson": "Lesson 3: The Short Vowels (Harakat)",
      "desc": "Learn the three primary vowels: Fathah (َ) making 'a' sound, Kasrah (ِ) making 'i' sound, and Dammah (ُ) making 'u' sound."
    },
    {
      "lesson": "Lesson 4: Tanween (Double Vowels)",
      "desc": "Learn Fathatain (ً), Kasratain (ٍ), and Dammatain (ٌ) which add a noon sound at the end of vowels."
    },
  ];

  void _showLetterDetail(Map<String, String> item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF181F2B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(color: Colors.amber.withValues(alpha: 0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Letter character circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1621),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber, width: 2),
                ),
                child: Center(
                  child: Text(
                    item["letter"]!,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                item["name"]!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Transliteration: [ ${item["trans"]!} ]",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.amber,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 15),
              Divider(color: Colors.white.withValues(alpha: 0.1)),
              const SizedBox(height: 15),
              Text(
                item["desc"]!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Close", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1621),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1621),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "ALIF BA TA",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header info banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.translate, color: Colors.amber, size: 40),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Arabic Alphabet & Pronunciation",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Learn Hijaiyah letters and their reading shapes.",
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Custom styled TabBar (Pill/buttons)
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)], // Teal/green gradient
                ),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[400],
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              tabs: const [
                Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Alphabet", style: TextStyle(fontWeight: FontWeight.bold)))),
                Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Letter Forms", style: TextStyle(fontWeight: FontWeight.bold)))),
                Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Tajweed Rules", style: TextStyle(fontWeight: FontWeight.bold)))),
                Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Noorani", style: TextStyle(fontWeight: FontWeight.bold)))),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAlphabetTab(),
                _buildLetterFormsTab(),
                _buildTajweedTab(),
                _buildNooraniTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. Alphabet Tab: Grid list of all Hijaiyah letters
  Widget _buildAlphabetTab() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: _alphabetList.length,
      itemBuilder: (context, index) {
        final item = _alphabetList[index];
        return GestureDetector(
          onTap: () => _showLetterDetail(item),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF181F2B),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item["letter"]!,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item["name"]!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "[ ${item["trans"]!} ]",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 2. Letter Forms Tab: Left-to-right table (End | Middle | Beginning | Alone)
  Widget _buildLetterFormsTab() {
    return Column(
      children: [
        // Table Header
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1F293D),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Expanded(child: Center(child: Text("End", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)))),
              Expanded(child: Center(child: Text("Middle", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)))),
              Expanded(child: Center(child: Text("Beginning", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)))),
              Expanded(child: Center(child: Text("Alone", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)))),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Table Content
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            itemCount: _letterForms.length,
            itemBuilder: (context, index) {
              final item = _letterForms[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFF181F2B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
                ),
                child: Row(
                  children: [
                    Expanded(child: Center(child: Text(item["end"]!, style: const TextStyle(fontSize: 22, color: Colors.amber, fontWeight: FontWeight.bold)))),
                    Expanded(child: Center(child: Text(item["middle"]!, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)))),
                    Expanded(child: Center(child: Text(item["begin"]!, style: const TextStyle(fontSize: 22, color: Colors.amber, fontWeight: FontWeight.bold)))),
                    Expanded(
                      child: Center(
                        child: Column(
                          children: [
                            Text(item["alone"]!, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                            Text(item["name"]!, style: TextStyle(fontSize: 9, color: Colors.grey[400])),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 3. Tajweed Rules Tab
  Widget _buildTajweedTab() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      itemCount: _tajweedRules.length,
      itemBuilder: (context, index) {
        final item = _tajweedRules[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF181F2B),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item["title"]!,
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item["rule"]!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item["desc"]!,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 4. Noorani Tab
  Widget _buildNooraniTab() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      itemCount: _nooraniLessons.length,
      itemBuilder: (context, index) {
        final item = _nooraniLessons[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF181F2B),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lesson indicator
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(
                      color: Color(0xFF0F1621),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["lesson"]!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item["desc"]!,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
