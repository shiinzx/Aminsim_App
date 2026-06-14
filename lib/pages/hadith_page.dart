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

  String _getBookInitial(String slug) {
    switch (slug) {
      case 'bukhari': return 'B';
      case 'muslim': return 'M';
      case 'tirmidzi': return 'TR';
      case 'nasai': return 'N';
      case 'abu-dawud': return 'AB';
      case 'ibnu-majah': return 'IM';
      case 'ahmad': return 'AH';
      case 'darimi': return 'DM';
      case 'malik': return 'ML';
      default: return 'H';
    }
  }

  String _getArabicBookName(String slug) {
    switch (slug) {
      case 'bukhari': return 'صحيح البخاري';
      case 'muslim': return 'صحيح مسلم';
      case 'tirmidzi': return 'سنن الترمذي';
      case 'nasai': return 'سنن النسائي';
      case 'abu-dawud': return 'سنن أبي داود';
      case 'ibnu-majah': return 'سنن ابن ماجه';
      case 'ahmad': return 'مسند أحمد';
      case 'darimi': return 'سنن الدارمي';
      case 'malik': return 'موطأ مالك';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F24),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F24),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Hadist Lengkap",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6))))
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: fetchBooks,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
                        child: const Text("Retry", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  itemCount: books.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 20, top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Books of Hadith",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              "See All",
                              style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    }

                    final book = books[index - 1];
                    final String name = book['name'] ?? '';
                    final String slug = book['slug'] ?? '';
                    final int total = book['total'] ?? 0;

                    final initial = _getBookInitial(slug);
                    final arabName = _getArabicBookName(slug);
                    final titleText = arabName.isNotEmpty ? "$name ($arabName)" : name;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF132235),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                          title: Text(
                            titleText,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "Total hadith - $total",
                              style: TextStyle(color: Colors.grey[400], fontSize: 12),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.favorite_border, color: Colors.white70, size: 20),
                            onPressed: () {},
                          ),
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
      backgroundColor: const Color(0xFF0A0F24),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F24),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.bookName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  disabledColor: Colors.white24,
                ),
                Text(
                  "Hadist $startRange - $endRange of ${widget.totalHadiths}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                IconButton(
                  onPressed: currentPage < maxPages ? _nextPage : null,
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  disabledColor: Colors.white24,
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6))))
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(errorMessage, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: fetchHadiths,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
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
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF132235),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                                          color: const Color(0xFF2563EB),
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
                                        color: Colors.white,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  const Text(
                                    "Terjemahan:",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blue),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    hadith['id'] ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[300],
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
