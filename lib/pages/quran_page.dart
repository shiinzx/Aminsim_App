import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> allSurahs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchAllSurah(); // Ambil data dari API pas halaman dibuka
  }

  // Fungsi ambil data daftar surat dari API
  Future<void> fetchAllSurah() async {
    try {
      final response = await http.get(Uri.parse('https://equran.id/api/v2/surat'));
      if (response.statusCode == 200) {
        setState(() {
          allSurahs = json.decode(response.body)['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Read Quran",
          style: TextStyle(color: Color(0xFF1E5BB0), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.settings_outlined, color: Colors.grey),
                onPressed: () {},
              ),
              const Text("Settings", style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search surah",
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

          // 2. QUICK ACCESS
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text("Quick Access", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 35,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20),
              children: [
                _buildQuickAccessItem("Al - Kahfi", true),
                _buildQuickAccessItem("Maryam", false),
                _buildQuickAccessItem("Al-A'la", false),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // 3. TAB NAVIGATION (SURAH, JUZ, AYAT)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 45,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color(0xFF1E5BB0),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: "Surah"),
                Tab(text: "Juz"),
                Tab(text: "Ayat"),
              ],
            ),
          ),

          // 4. LIST SURAH (DARI API)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                isLoading 
                  ? const Center(child: CircularProgressIndicator()) 
                  : _buildSurahList(),
                const Center(child: Text("Halaman Juz")),
                const Center(child: Text("Halaman Ayat")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessItem(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1E5BB0) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? Colors.transparent : Colors.grey[300]!),
      ),
      child: Center(
        child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontSize: 12)),
      ),
    );
  }

  Widget _buildSurahList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: allSurahs.length,
      itemBuilder: (context, index) {
        final surah = allSurahs[index];
        return GestureDetector(
          onTap: () {
            // Arahkan ke halaman detail kalau dipencet
            // Navigator.push(context, MaterialPageRoute(builder: (context) => QuranDetailPage(surahNumber: surah['nomor'])));
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                // Nomor Surah
                Container(
                  width: 35, height: 35,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E5BB0).withOpacity(0.1),
                    shape: BoxShape.circle
                  ),
                  child: Center(
                    child: Text("${surah['nomor']}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E5BB0))),
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(surah['namaLatin'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text("${surah['arti']} | ${surah['jumlahAyat']} Ayat", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const Spacer(),
                Text(
                  surah['nama'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E5BB0)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}