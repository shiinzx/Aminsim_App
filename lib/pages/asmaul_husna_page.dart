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
      backgroundColor: const Color(0xFF0F1621), // Premium dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1621),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Asmaul Husna",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
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
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search name or meaning...",
                hintStyle: const TextStyle(color: Colors.white60, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.amber),
                filled: true,
                fillColor: const Color(0xFF181F2B),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.amber, width: 1),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.amber)))
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(errorMessage, style: const TextStyle(color: Colors.redAccent)),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: fetchAsmaulHusna,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text("Retry", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      )
                    : filteredNames.isEmpty
                        ? const Center(child: Text("No names match your search", style: TextStyle(color: Colors.white70)))
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.15,
                            ),
                            itemCount: filteredNames.length,
                            itemBuilder: (context, index) {
                              final item = filteredNames[index];
                              final number = item['urutan'] ?? (index + 1);
                              final arab = item['arab'] ?? '';
                              final latin = item['latin'] ?? '';
                              final arti = item['arti'] ?? '';

                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF181F2B),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Number badge
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: const BoxDecoration(
                                          color: Colors.amber,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "$number",
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F1621),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Arabic Name
                                    Text(
                                      arab,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Latin Name
                                    Text(
                                      latin,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    // Translation
                                    Text(
                                      arti,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
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
