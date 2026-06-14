import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class SholatPage extends StatefulWidget {
  const SholatPage({super.key});

  @override
  State<SholatPage> createState() => _SholatPageState();
}

class _SholatPageState extends State<SholatPage> {
  String currentCity = "Cianjur";
  String currentCityId = "1205"; // Default city ID for Cianjur in Kemenag/myquran database
  Map<String, dynamic> todaySchedule = {};
  bool isLoading = true;
  String errorMessage = "";
  final TextEditingController _citySearchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchPrayerTimes(currentCityId);
  }

  Future<void> searchCity(String query) async {
    if (query.trim().isEmpty) {
      setState(() => searchResults = []);
      return;
    }
    try {
      final response = await http.get(Uri.parse('https://api.myquran.com/v2/sholat/kota/cari/$query'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            searchResults = data['data'] ?? [];
          });
        }
      }
    } catch (e) {
      // Ignore search errors in background
    }
  }

  Future<void> fetchPrayerTimes(String cityId) async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });
    final now = DateTime.now();
    final year = now.year;
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    try {
      final response = await http.get(Uri.parse('https://api.myquran.com/v2/sholat/jadwal/$cityId/$year/$month/$day'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == true && responseData['data'] != null) {
          setState(() {
            todaySchedule = responseData['data']['jadwal'] ?? {};
            currentCity = responseData['data']['lokasi'] ?? currentCity;
            currentCityId = cityId;
            isLoading = false;
            searchResults = [];
            isSearching = false;
            _citySearchController.clear();
          });
        } else {
          setState(() {
            errorMessage = "No schedule found for today.";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Server error (Code: ${response.statusCode})";
          isLoading = false;
        });
      }
    } catch (e) {
      // Fallback
      setState(() {
        todaySchedule = _staticBackupSchedule;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _citySearchController.dispose();
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
          "Jadwal Sholat",
          style: TextStyle(color: Color(0xFF062743), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search, color: const Color(0xFF062743)),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchResults = [];
                  _citySearchController.clear();
                }
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Search UI overlay
          if (isSearching) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _citySearchController,
                onChanged: searchCity,
                decoration: InputDecoration(
                  hintText: "Enter city name (e.g. Jakarta, Cianjur)",
                  prefixIcon: const Icon(Icons.location_city, color: Colors.grey),
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
            if (searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final city = searchResults[index];
                    return ListTile(
                      title: Text(city['lokasi'] ?? ''),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        fetchPrayerTimes(city['id']);
                      },
                    );
                  },
                ),
              ),
          ],
          if (!isSearching || searchResults.isEmpty)
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
                                onPressed: () => fetchPrayerTimes(currentCityId),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF062743)),
                                child: const Text("Retry", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => fetchPrayerTimes(currentCityId),
                          color: const Color(0xFF062743),
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                            children: [
                              // City header card
                              Container(
                                padding: const EdgeInsets.all(25),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF062743),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.amber, size: 30),
                                    const SizedBox(height: 10),
                                    Text(
                                      currentCity.toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      todaySchedule['tanggal'] ?? '',
                                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 25),
                              const Text(
                                "Today's Schedule",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF062743)),
                              ),
                              const SizedBox(height: 15),
                              // Prayer list
                              _prayerTimeTile("Imsak", todaySchedule['imsak'] ?? '--:--'),
                              _prayerTimeTile("Subuh", todaySchedule['subuh'] ?? '--:--'),
                              _prayerTimeTile("Terbit", todaySchedule['terbit'] ?? '--:--'),
                              _prayerTimeTile("Dhuha", todaySchedule['dhuha'] ?? '--:--'),
                              _prayerTimeTile("Dzuhur", todaySchedule['dzuhur'] ?? '--:--'),
                              _prayerTimeTile("Ashar", todaySchedule['ashar'] ?? '--:--'),
                              _prayerTimeTile("Magrib", todaySchedule['magrib'] ?? '--:--'),
                              _prayerTimeTile("Isya", todaySchedule['isya'] ?? '--:--'),
                            ],
                          ),
                        ),
            ),
        ],
      ),
    );
  }

  Widget _prayerTimeTile(String title, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF062743),
              ),
            ),
            Row(
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.alarm,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  static const Map<String, String> _staticBackupSchedule = {
    "tanggal": "Minggu, 14 Juni 2026",
    "imsak": "04:32",
    "subuh": "04:42",
    "terbit": "05:59",
    "dhuha": "06:27",
    "dzuhur": "11:52",
    "ashar": "15:10",
    "magrib": "17:51",
    "isya": "19:01"
  };
}
