import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

class QuranReadPage extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const QuranReadPage({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<QuranReadPage> createState() => _QuranReadPageState();
}

class _QuranReadPageState extends State<QuranReadPage> {
  Map<String, dynamic>? surahDetail;
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _saveAsLastRead();
    fetchSurahDetail();
  }

  Future<void> _saveAsLastRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_read_surah', widget.surahName);
      await prefs.setInt('last_read_surah_number', widget.surahNumber);
    } catch (e) {
      debugPrint("Error saving last read: $e");
    }
  }

  Future<void> fetchSurahDetail() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });
    try {
      final response = await http.get(
        Uri.parse('https://equran.id/api/v2/surat/${widget.surahNumber}'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (mounted) {
          setState(() {
            surahDetail = body['data'];
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = "Failed to load Surah. Code: ${response.statusCode}";
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Network error. Please check your internet connection.";
          isLoading = false;
        });
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Verse copied to clipboard"),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.amber,
      ),
    );
  }

  void _shareVerse(String text) {
    // A simplified share logic that copies and alerts
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Copied to clipboard for sharing!"),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF2563EB),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1621), // Deep dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1621),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.surahName.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                        const SizedBox(height: 15),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: fetchSurahDetail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (surahDetail == null) return const SizedBox.shrink();

    final verses = surahDetail!['ayat'] as List<dynamic>? ?? [];
    final hasBismillah = widget.surahNumber != 1 && widget.surahNumber != 9;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: verses.length + 1, // +1 for the banner card at the top
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            children: [
              _buildSurahBanner(),
              if (hasBismillah) ...[
                const SizedBox(height: 25),
                const Text(
                  "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),
            ],
          );
        }

        final verseIndex = index - 1;
        final verse = verses[verseIndex];
        return _buildVerseCard(verse, verseIndex);
      },
    );
  }

  Widget _buildSurahBanner() {
    final name = surahDetail!['nama'] ?? '';
    final namaLatin = surahDetail!['namaLatin'] ?? '';
    final arti = surahDetail!['arti'] ?? '';
    final tempatTurun = surahDetail!['tempatTurun'] ?? '';
    final jumlahAyat = surahDetail!['jumlahAyat'] ?? 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          Text(
            namaLatin,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            arti,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 15),
          Divider(
            color: Colors.white.withValues(alpha: 0.15),
            thickness: 1,
            indent: 40,
            endIndent: 40,
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tempatTurun.toString().toUpperCase(),
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.fiber_manual_record, size: 6, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                "$jumlahAyat AYAT",
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseCard(dynamic verse, int index) {
    final nomorAyat = verse['nomorAyat'] ?? (index + 1);
    final teksArab = verse['teksArab'] ?? '';
    final teksLatin = verse['teksLatin'] ?? '';
    final teksIndonesia = verse['teksIndonesia'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF181F2B),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verse Action Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1F293D),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                // Star shape with verse number
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: math.pi / 4,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.amber, width: 1.5),
                        ),
                      ),
                    ),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber, width: 1.5),
                      ),
                    ),
                    Text(
                      "$nomorAyat",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18, color: Colors.white70),
                  onPressed: () => _copyToClipboard("$teksArab\n\n$teksLatin\n\n$teksIndonesia"),
                  tooltip: "Copy Verse",
                ),
                IconButton(
                  icon: const Icon(Icons.share, size: 18, color: Colors.white70),
                  onPressed: () => _shareVerse("$teksArab\n\n$teksLatin\n\n$teksIndonesia"),
                  tooltip: "Share Verse",
                ),
              ],
            ),
          ),
          // Verse texts
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Arabic Text
                Text(
                  teksArab,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 2.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 15),
                // Latin Transliteration
                Text(
                  teksLatin,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                // Translation
                Text(
                  teksIndonesia,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                    height: 1.4,
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
