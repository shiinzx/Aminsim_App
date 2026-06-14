import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DoaPage extends StatefulWidget {
  const DoaPage({super.key});

  @override
  State<DoaPage> createState() => _DoaPageState();
}

class _DoaPageState extends State<DoaPage> {
  List<dynamic> allDoas = [];
  List<dynamic> filteredDoas = [];
  bool isLoading = true;
  String errorMessage = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDoas();
  }

  Future<void> fetchDoas() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });
    try {
      final response = await http.get(Uri.parse('https://doa-doa-api-ahmadramadhan.fly.dev/api'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          allDoas = data;
          filteredDoas = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load data from server. (Code: ${response.statusCode})";
          isLoading = false;
        });
      }
    } catch (e) {
      // Fallback to static backup list if API is unreachable
      setState(() {
        allDoas = _staticBackupDoas;
        filteredDoas = _staticBackupDoas;
        isLoading = false;
      });
    }
  }

  void _filterDoas(String query) {
    setState(() {
      filteredDoas = allDoas.where((item) {
        final title = (item['doa'] ?? '').toString().toLowerCase();
        final meaning = (item['terjemah'] ?? '').toString().toLowerCase();
        return title.contains(query.toLowerCase()) || meaning.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF062743)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Doa Sehari-hari",
          style: TextStyle(color: Color(0xFF062743), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              onChanged: _filterDoas,
              decoration: InputDecoration(
                hintText: "Search daily prayer...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF062743))))
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(errorMessage, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: fetchDoas,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF062743)),
                              child: const Text("Retry", style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    : filteredDoas.isEmpty
                        ? const Center(child: Text("No prayers match your search"))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                            itemCount: filteredDoas.length,
                            itemBuilder: (context, index) {
                              final item = filteredDoas[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 15),
                                elevation: 2,
                                shadowColor: Colors.black12,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey[100]!),
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                    child: ExpansionTile(
                                      tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                      title: Text(
                                        item['doa'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF062743),
                                          fontSize: 14,
                                        ),
                                      ),
                                      childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                      children: [
                                        const Divider(height: 1),
                                        const SizedBox(height: 15),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            item['ayat'] ?? '',
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF062743),
                                              height: 1.6,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        if (item['latin'] != null && (item['latin'] as String).isNotEmpty) ...[
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              item['latin'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                                color: Colors.amber,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Artinya:\n${item['terjemah'] ?? ''}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  // Backup static list if offline or API is down
  static const List<Map<String, String>> _staticBackupDoas = [
    {
      "id": "1",
      "doa": "Doa Sebelum Makan",
      "ayat": "اَللّٰهُمَّ بَارِكْ لَنَا فِيْمَا رَزَقْتَنَا وَقِنَا عَذَابَ النَّارِ",
      "latin": "Allahumma baariki lanaa fiimaa razaqtanaa wa qinaa 'adzaaban naar.",
      "terjemah": "Ya Allah, berkahilah kami dalam rezeki yang telah Engkau berikan kepada kami dan peliharalah kami dari siksa neraka."
    },
    {
      "id": "2",
      "doa": "Doa Sesudah Makan",
      "ayat": "اَلْحَمْدُ ِللهِ الَّذِىْ اَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِيْنَ",
      "latin": "Alhamdu lillahil ladzii ath'amanaa wa saqaanaa wa ja'alanaa muslimiin.",
      "terjemah": "Segala puji bagi Allah yang telah memberi makan dan minum kepada kami dan telah menjadikan kami orang-orang muslim."
    },
    {
      "id": "3",
      "doa": "Doa Sebelum Tidur",
      "ayat": "بِاسْمِكَ اللّهُمَّ أَحْيَا وَأَمُوتُ",
      "latin": "Bismika Allahumma ahyaa wa amuutu.",
      "terjemah": "Dengan nama-Mu ya Allah aku hidup dan aku mati."
    },
    {
      "id": "4",
      "doa": "Doa Bangun Tidur",
      "ayat": "اَلْحَمْدُ ِللهِ الَّذِىْ اَحْيَانَا بَعْدَمَا اَمَاتَنَا وَاِلَيْهِ النُّشُوْرُ",
      "latin": "Alhamdu lillahil ladzii ahyaanaa ba'da maa amaatanaa wa ilaihin nusyuur.",
      "terjemah": "Segala puji bagi Allah yang telah menghidupkan kami setelah mematikan kami dan kepada-Nya lah kami kembali."
    }
  ];
}
