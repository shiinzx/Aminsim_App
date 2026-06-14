import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'quran_read_page.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> allSurahs = [];
  List<dynamic> filteredSurahs = [];
  bool isLoading = true;
  String lastReadSurah = "Al-Fatihah";
  int lastReadSurahNumber = 1;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Length 4 for Surah, Para, Page, Hijb
    _loadLastRead();
    fetchAllSurah(); // Ambil data dari API pas halaman dibuka
  }

  // Load last read surah from local storage
  Future<void> _loadLastRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        lastReadSurah = prefs.getString('last_read_surah') ?? "Al-Fatihah";
        lastReadSurahNumber = prefs.getInt('last_read_surah_number') ?? 1;
      });
    } catch (e) {
      // Ignore
    }
  }

  // Save last read surah to local storage
  Future<void> _saveLastRead(String surahName, int surahNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_read_surah', surahName);
      await prefs.setInt('last_read_surah_number', surahNumber);
      setState(() {
        lastReadSurah = surahName;
        lastReadSurahNumber = surahNumber;
      });
    } catch (e) {
      // Ignore
    }
  }

  // Fungsi ambil data daftar surat dari API
  Future<void> fetchAllSurah() async {
    try {
      final response = await http.get(Uri.parse('https://equran.id/api/v2/surat'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            allSurahs = json.decode(response.body)['data'];
            filteredSurahs = allSurahs;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _filterSurahs(String query) {
    setState(() {
      filteredSurahs = allSurahs.where((surah) {
        final name = (surah['namaLatin'] ?? '').toString().toLowerCase();
        final translation = (surah['arti'] ?? '').toString().toLowerCase();
        return name.contains(query.toLowerCase()) || translation.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1621), // Deep dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1621),
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.amber),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Search Surah...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: _filterSurahs,
              )
            : const Text(
                "QUR'AN",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white70),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _filterSurahs("");
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LAST READ CARD (Yellow Card with 3D Book Cover and "Back to reading" button)
          _buildLastReadCard(),

          // TAB NAVIGATION (SURAH, PARA, PAGE, HIJB)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.amber,
              indicatorWeight: 2,
              labelColor: Colors.amber,
              unselectedLabelColor: Colors.grey[400],
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: "Surah"),
                Tab(text: "Para"),
                Tab(text: "Page"),
                Tab(text: "Hijb"),
              ],
            ),
          ),

          // LIST SURAH (DARI API)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                isLoading
                    ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.amber)))
                    : _buildSurahList(),
                const Center(child: Text("Halaman Para", style: TextStyle(color: Colors.white))),
                const Center(child: Text("Halaman Page", style: TextStyle(color: Colors.white))),
                const Center(child: Text("Halaman Hijb", style: TextStyle(color: Colors.white))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastReadCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFCD34D), // Golden-yellow card background
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFCD34D).withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.menu_book_outlined, color: Colors.black54, size: 16),
                    SizedBox(width: 6),
                    Text(
                      "Last Read",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "Surah",
                  style: TextStyle(color: Colors.black54, fontSize: 11),
                ),
                Text(
                  lastReadSurah,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                // "Back to reading" Pill button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuranReadPage(
                          surahNumber: lastReadSurahNumber,
                          surahName: lastReadSurah,
                        ),
                      ),
                    ).then((_) => _loadLastRead());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1621), // Dark container background
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Back to reading",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.chevron_right, color: Colors.white, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Quran book illustration on the right
          Image.asset(
            'assets/quran_book.png',
            width: 90,
            height: 110,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.book, size: 80, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      itemCount: filteredSurahs.length,
      itemBuilder: (context, index) {
        final surah = filteredSurahs[index];
        return GestureDetector(
          onTap: () {
            final name = surah['namaLatin'];
            final number = surah['nomor'];
            _saveLastRead(name, number);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuranReadPage(
                  surahNumber: number,
                  surahName: name,
                ),
              ),
            ).then((_) => _loadLastRead());
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF181F2B), // Dark card background
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
            ),
            child: Row(
              children: [
                // 8-pointed Rub el Hizb Star (using rotated squares in Flutter)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: math.pi / 4,
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.amber, width: 1.5),
                        ),
                      ),
                    ),
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber, width: 1.5),
                      ),
                    ),
                    Text(
                      "${surah['nomor']}",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 15),
                // Surah Name Latin
                Text(
                  surah['namaLatin'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white
                  ),
                ),
                const SizedBox(width: 8),
                // Surah Name Arabic
                Text(
                  surah['nama'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const Spacer(),
                // Play Button (Yellow circle with dark play icon)
                Container(
                  width: 32, height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    size: 20,
                    color: Color(0xFF0F1621),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}