// lib/screens/about_screen.dart
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1F0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('About FarmLog', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF76C442),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF76C442).withOpacity(0.3),
                      blurRadius: 30, spreadRadius: 5),
                ],
              ),
              child: const Center(
                child: Text('🌾', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('FarmLog',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Version 1.0.0',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14)),
            const SizedBox(height: 8),
            Text('A planting diary for Nigerian smallholder farmers',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 36),
            _featureCard('🌱', 'Crop Tracking', 'Log every crop with location, size and planting date.'),
            const SizedBox(height: 10),
            _featureCard('💰', 'Input Cost Logging', 'Track seeds, fertiliser, labour and more in ₦.'),
            const SizedBox(height: 10),
            _featureCard('📦', 'Harvest Records', 'Record yield quantity and estimated sale value.'),
            const SizedBox(height: 10),
            _featureCard('📊', 'Profit & Loss', 'Instantly see if each season is in profit or loss.'),
            const SizedBox(height: 10),
            _featureCard('📴', '100% Offline', 'All data stored privately on your device — no internet needed.'),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2E1C),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF76C442).withOpacity(0.3), width: 1),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF76C442).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('CREDITS',
                        style: TextStyle(color: Color(0xFF76C442), fontSize: 11,
                            fontWeight: FontWeight.w700, letterSpacing: 2)),
                  ),
                  const SizedBox(height: 16),
                  const Text('Made by',
                      style: TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 6),
                  const Text('Israel Olukayode',
                      style: TextStyle(color: Colors.white, fontSize: 22,
                          fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                  const SizedBox(height: 12),
                  Divider(color: Colors.white.withOpacity(0.07)),
                  const SizedBox(height: 12),
                  Text('Built with Flutter & Dart',
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('© ${DateTime.now().year} Israel Olukayode. All rights reserved.',
                      style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 11),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _featureCard(String emoji, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF1A2E1C), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 3),
                Text(desc, style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
