import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> {
  int _counter = 0;
  int _target = 33; // Default target
  int _lapCount = 0;

  void _increment() {
    HapticFeedback.lightImpact(); // Haptic feedback on tap
    setState(() {
      _counter++;
      if (_counter == _target && _target != 0) {
        _lapCount++;
        _counter = 0;
        HapticFeedback.vibrate(); // Vibrate strongly when target reached
        _showTargetReachedSnackBar();
      }
    });
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() {
      _counter = 0;
      _lapCount = 0;
    });
  }

  void _showTargetReachedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Target $_target reached! Lap $_lapCount completed."),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = _target == 0 ? 0.0 : (_counter / _target);

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
          "Tasbih Digital",
          style: TextStyle(color: Color(0xFF062743), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          children: [
            // Target Selector Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _targetButton(33),
                const SizedBox(width: 10),
                _targetButton(99),
                const SizedBox(width: 10),
                _targetButton(100),
                const SizedBox(width: 10),
                _targetButton(0, label: "Unlimited"),
              ],
            ),
            const SizedBox(height: 50),

            // Lap Counter
            if (_target != 0) ...[
              Text(
                "LAP: $_lapCount",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Progress Ring & Counter
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[100],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF062743)),
                  ),
                ),
                GestureDetector(
                  onTap: _increment,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFBCCBCF).withOpacity(0.3), width: 4),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$_counter",
                          style: const TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF062743),
                          ),
                        ),
                        Text(
                          _target == 0 ? "/ ∞" : "/ $_target",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),

            // Reset Button
            ElevatedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text("Reset Counter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF062743),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Tap the center circle to count. Tap targets above to switch limits.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _targetButton(int value, {String? label}) {
    bool isSelected = _target == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _target = value;
          _counter = 0;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF062743) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey[300]!),
        ),
        child: Text(
          label ?? "$value",
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
