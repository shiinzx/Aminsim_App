import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AsmaulHusnaPage extends StatefulWidget {
  const AsmaulHusnaPage({super.key});

  @override
  State<AsmaulHusnaPage> createState() => _AsmaulHusnaPageState();
}

class _AsmaulHusnaPageState extends State<AsmaulHusnaPage> {
  List<dynamic> allNames = [];
  List<dynamic> filteredNames = [];
  bool isLoading = true;
  String errorMessage = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAsmaulHusna();
  }

  Future<void> fetchAsmaulHusna() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });
    try {
      final response = await http.get(Uri.parse('https://asmaul-husna-api.vercel.app/api/all'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Sometimes APIs return the list under 'data' or directly as a list or map.
        // Let's handle both possible structures robustly.
        final List<dynamic> data = responseData['data'] ?? [];
        setState(() {
          allNames = data;
          filteredNames = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load data from server. (Code: ${response.statusCode})";
          isLoading = false;
        });
      }
    } catch (e) {
      // Fallback: If vercel API is down, use a static backup of Asmaul Husna so the app is 100% resilient
      setState(() {
        allNames = _staticBackupNames;
        filteredNames = _staticBackupNames;
        isLoading = false;
      });
    }
  }

  void _filterNames(String query) {
    setState(() {
      filteredNames = allNames.where((item) {
        final latin = (item['latin'] ?? '').toString().toLowerCase();
        final translation = (item['arti'] ?? '').toString().toLowerCase();
        return latin.contains(query.toLowerCase()) || translation.contains(query.toLowerCase());
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
          "Asmaul Husna",
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
              onChanged: _filterNames,
              decoration: InputDecoration(
                hintText: "Search name or meaning...",
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
                              onPressed: fetchAsmaulHusna,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF062743)),
                              child: const Text("Retry", style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    : filteredNames.isEmpty
                        ? const Center(child: Text("No names match your search"))
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.1,
                            ),
                            itemCount: filteredNames.length,
                            itemBuilder: (context, index) {
                              final item = filteredNames[index];
                              return Card(
                                elevation: 2,
                                shadowColor: Colors.black12,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey[100]!),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Number circle
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFBCCBCF),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${item['urutan'] ?? (index + 1)}",
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF062743),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      // Arabic Name
                                      Text(
                                        item['arab'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF062743),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Latin
                                      Text(
                                        item['latin'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      // Translation
                                      Text(
                                        item['arti'] ?? '',
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
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

  // Resilient fallback static local names if the API is down
  static const List<Map<String, dynamic>> _staticBackupNames = [
    {"urutan": 1, "arab": "الرَّحْمَنُ", "latin": "Ar Rahman", "arti": "Maha Pengasih"},
    {"urutan": 2, "arab": "الرَّحِيمُ", "latin": "Ar Rahim", "arti": "Maha Penyayang"},
    {"urutan": 3, "arab": "الْمَلِكُ", "latin": "Al Malik", "arti": "Maha Raja"},
    {"urutan": 4, "arab": "الْقُدُّوسُ", "latin": "Al Quddus", "arti": "Maha Suci"},
    {"urutan": 5, "arab": "السَّلاَمُ", "latin": "As Salam", "arti": "Maha Memberi Kesejahteraan"},
    {"urutan": 6, "arab": "الْمُؤْمِنُ", "latin": "Al Mu'min", "arti": "Maha Memberi Keamanan"},
    {"urutan": 7, "arab": "الْمُهَيْمِنُ", "latin": "Al Muhaymin", "arti": "Maha Pemelihara"},
    {"urutan": 8, "arab": "الْعَزِيزُ", "latin": "Al Aziz", "arti": "Maha Perkasa"},
    {"urutan": 9, "arab": "الْجَبَّارُ", "latin": "Al Jabbar", "arti": "Maha Gagah"},
    {"urutan": 10, "arab": "الْمُتَكَبِّرُ", "latin": "Al Mutakabbir", "arti": "Maha Agung"},
    {"urutan": 11, "arab": "الْخَالِقُ", "latin": "Al Khaliq", "arti": "Maha Pencipta"},
    {"urutan": 12, "arab": "الْبَارِئُ", "latin": "Al Bari'", "arti": "Maha Melepaskan"},
    {"urutan": 13, "arab": "الْمُصَوِّرُ", "latin": "Al Mushawwir", "arti": "Maha Membentuk Rupa"},
    {"urutan": 14, "arab": "الْغَفَّارُ", "latin": "Al Ghaffar", "arti": "Maha Pengampun"},
    {"urutan": 15, "arab": "الْقَهَّارُ", "latin": "Al Qahhar", "arti": "Maha Menundukkan"},
  ];
}
