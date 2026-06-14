import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HadithPage extends StatefulWidget {
  const HadithPage({super.key});

  @override
  State<HadithPage> createState() => _HadithPageState();
}

class _HadithPageState extends State<HadithPage> {
  List<dynamic> books = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });
    try {
      final response = await http.get(Uri.parse('https://hadis-api-id.vercel.app/hadith'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          books = responseData;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load Hadith books. (Code: ${response.statusCode})";
          isLoading = false;
        });
      }
    } catch (e) {
      // Fallback backup if API is unavailable
      setState(() {
        books = _staticBackupBooks;
        isLoading = false;
      });
    }
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
          "Hadist Lengkap",
          style: TextStyle(color: Color(0xFF062743), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF062743))))
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: fetchBooks,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF062743)),
                        child: const Text("Retry", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    final String name = book['name'] ?? '';
                    final String slug = book['slug'] ?? '';
                    final int total = book['total'] ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      elevation: 2,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        leading: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFF062743).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.book, color: Color(0xFF062743)),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF062743),
                          ),
                        ),
                        subtitle: Text(
                          "Total: $total Hadist",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HadithBrowserPage(
                                bookId: slug,
                                bookName: name,
                                totalHadiths: total,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }

  static const List<Map<String, dynamic>> _staticBackupBooks = [
    {"slug": "bukhari", "name": "Bukhari", "total": 6638},
    {"slug": "muslim", "name": "Muslim", "total": 4930},
    {"slug": "tirmidzi", "name": "Tirmidzi", "total": 3625},
    {"slug": "nasai", "name": "Nasai", "total": 5364},
    {"slug": "abu-dawud", "name": "Abu Dawud", "total": 4419},
    {"slug": "ibnu-majah", "name": "Ibnu Majah", "total": 4285},
    {"slug": "ahmad", "name": "Ahmad", "total": 4305},
    {"slug": "darimi", "name": "Darimi", "total": 2949},
    {"slug": "malik", "name": "Malik", "total": 1587},
  ];
}

class HadithBrowserPage extends StatefulWidget {
  final String bookId;
  final String bookName;
  final int totalHadiths;

  const HadithBrowserPage({
    super.key,
    required this.bookId,
    required this.bookName,
    required this.totalHadiths,
  });

  @override
  State<HadithBrowserPage> createState() => _HadithBrowserPageState();
}

class _HadithBrowserPageState extends State<HadithBrowserPage> {
  int currentPage = 1;
  static const int limit = 20;
  List<dynamic> hadiths = [];
  bool isLoading = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchHadiths();
  }

  Future<void> fetchHadiths() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });
    try {
      final response = await http.get(Uri.parse(
          'https://hadis-api-id.vercel.app/hadith/${widget.bookId}?page=$currentPage&limit=$limit'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          hadiths = responseData['items'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load Hadiths. (Code: ${response.statusCode})";
          isLoading = false;
        });
      }
    } catch (e) {
      // Offline fallback simulations
      final startRange = (currentPage - 1) * limit + 1;
      setState(() {
        hadiths = [
          {
            "number": startRange,
            "arab": "إنَّمَا الأَعْمَالُ بِالنِّيَّاتِ وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى",
            "id": "Sesungguhnya setiap amalan itu bergantung pada niatnya, dan setiap orang mendapatkan sesuai dengan apa yang ia niatkan."
          }
        ];
        isLoading = false;
      });
    }
  }

  void _nextPage() {
    final maxPages = (widget.totalHadiths / limit).ceil();
    if (currentPage < maxPages) {
      setState(() {
        currentPage++;
      });
      fetchHadiths();
    }
  }

  void _prevPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
      fetchHadiths();
    }
  }

  @override
  Widget build(BuildContext context) {
    final startRange = (currentPage - 1) * limit + 1;
    final endRange = (currentPage * limit > widget.totalHadiths) ? widget.totalHadiths : currentPage * limit;
    final maxPages = (widget.totalHadiths / limit).ceil();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF062743)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.bookName,
          style: const TextStyle(color: Color(0xFF062743), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Range Indicator & Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: currentPage > 1 ? _prevPage : null,
                  icon: const Icon(Icons.arrow_back_ios),
                  color: const Color(0xFF062743),
                ),
                Text(
                  "Hadist $startRange - $endRange of ${widget.totalHadiths}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF062743)),
                ),
                IconButton(
                  onPressed: currentPage < maxPages ? _nextPage : null,
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: const Color(0xFF062743),
                ),
              ],
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
                              onPressed: fetchHadiths,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF062743)),
                              child: const Text("Retry", style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                        itemCount: hadiths.length,
                        itemBuilder: (context, index) {
                          final hadith = hadiths[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 20),
                            elevation: 2,
                            shadowColor: Colors.black12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF062743),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          "No. ${hadith['number']}",
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      hadith['arab'] ?? '',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF062743),
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  const Text(
                                    "Terjemahan:",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.amber),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    hadith['id'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      height: 1.4,
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
}
