import 'package:flutter/material.dart';
import 'dart:math' as math;

class KiblatPage extends StatefulWidget {
  const KiblatPage({super.key});

  @override
  State<KiblatPage> createState() => _KiblatPageState();
}

class _KiblatPageState extends State<KiblatPage> {
  double _heading = 0.0; // Simulated heading in degrees
  final double _qiblaAngle = 295.0; // Qibla angle from North for Indonesia (approx)

  @override
  Widget build(BuildContext context) {
    // Calculate the relative angle for the Kaaba icon
    double relativeAngle = (_qiblaAngle - _heading) * (math.pi / 180);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F24),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F24),
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          "Arah Kiblat",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF132235),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                children: [
                  const Text(
                    "QIBLA ANGLE (CIANJUR)",
                    style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "295° Northwest",
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Align the compass needle with the Kaaba icon by rotating your device or dragging the compass below.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[300], fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Compass View
            GestureDetector(
              onPanUpdate: (details) {
                // Interactive simulation of compass rotation by drag
                setState(() {
                  _heading = (_heading - details.delta.dx / 2) % 360;
                  if (_heading < 0) _heading += 360;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Compass Ring
                  Transform.rotate(
                    angle: -_heading * (math.pi / 180),
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF132235),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 8),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))
                        ],
                      ),
                      child: Stack(
                        children: [
                          // North Marker
                          const Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                "N",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                              ),
                            ),
                          ),
                          // South Marker
                          const Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                "S",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white70),
                              ),
                            ),
                          ),
                          // East Marker
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                "E",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white70),
                              ),
                            ),
                          ),
                          // West Marker
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                "W",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white70),
                              ),
                            ),
                          ),
                          // Kaaba Icon Marker inside rotation
                          Transform.rotate(
                            angle: _qiblaAngle * (math.pi / 180),
                            child: const Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: EdgeInsets.only(top: 45),
                                child: Icon(Icons.mosque, color: Color(0xFF3B82F6), size: 24),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Needle / Arrow pointing to Qibla (relative to heading)
                  Transform.rotate(
                    angle: relativeAngle,
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 6,
                              height: 90,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin: const EdgeInsets.only(top: 5),
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF3B82F6),
                              ),
                              child: const Icon(
                                Icons.keyboard_arrow_up,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Center Pin
                  Container(
                    width: 25,
                    height: 25,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0A0F24),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Alignment Indicator Text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: (relativeAngle.abs() % (2 * math.pi) < 0.05 || (relativeAngle.abs() % (2 * math.pi) - 2 * math.pi).abs() < 0.05)
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                (relativeAngle.abs() % (2 * math.pi) < 0.05 || (relativeAngle.abs() % (2 * math.pi) - 2 * math.pi).abs() < 0.05)
                    ? "Perfectly Aligned with Qibla!"
                    : "Current Heading: ${(_heading).toStringAsFixed(0)}°",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: (relativeAngle.abs() % (2 * math.pi) < 0.05 || (relativeAngle.abs() % (2 * math.pi) - 2 * math.pi).abs() < 0.05)
                      ? Colors.green
                      : Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
