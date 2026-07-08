import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color darkGreen = Color(0xFF1E3A24);
  static const Color primaryGreen = Color(0xFF355E3B);
  static const Color gold = Color(0xFFD9A520);
  static const Color background = Color(0xFFF8F6F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildGreeting(),
              const SizedBox(height: 20),
              _buildInfoCards(),
              const SizedBox(height: 32),
              _buildScanButton(context),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Tap to scan crops',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _buildStatsRow(),
              const SizedBox(height: 28),
              _buildRecentScansHeader(),
              const SizedBox(height: 16),
              _buildScanTile(
                icon: Icons.warehouse,
                iconColor: gold,
                title: 'Warehouse A - Lot 12',
                subtitle: '2 hours ago',
                badgeText: 'SAFE',
                badgeColor: const Color(0xFFE8F5E9),
                badgeTextColor: primaryGreen,
                trailingText: '98% Match',
                trailingColor: primaryGreen,
              ),
              const SizedBox(height: 12),
              _buildScanTile(
                icon: Icons.grass,
                iconColor: gold,
                title: 'Field North - Sec 3',
                subtitle: 'Yesterday, 4:30 PM',
                badgeText: 'AT RISK',
                badgeColor: const Color(0xFFFDECEA),
                badgeTextColor: const Color(0xFFC62828),
                trailingText: 'Re-scan Suggested',
                trailingColor: const Color(0xFFC62828),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: darkGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.shield_outlined,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Aflatoxin Detector',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),
        const Spacer(),
        const CircleAvatar(
          radius: 20,
          backgroundColor: gold,
          child: Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Good Morning,',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: darkGreen,
          ),
        ),
        Text(
          'John',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Ready to secure your harvest today?',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'NAIROBI, KENYA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '24°C',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Cloudy',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 12),
                Icon(Icons.cloud, color: gold, size: 28),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.lightbulb_outline, color: gold, size: 20),
                SizedBox(height: 8),
                Text(
                  'DAILY TIP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: gold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Keep corn moisture below 13.5% to prevent mold growth.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return Center(
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 8),
        ),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: darkGreen,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.pushNamed(context, '/camera'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.camera_alt, color: Colors.white, size: 36),
                  SizedBox(height: 8),
                  Text(
                    'AI SCAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem('124', 'HEALTHY', primaryGreen),
          _buildDivider(),
          _buildStatItem('02', 'RISKY', const Color(0xFFC62828)),
          _buildDivider(),
          _buildStatItem('Aug 24', 'LAST SCAN', darkGreen),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildRecentScansHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recent Scans',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'See All',
            style: TextStyle(
              fontSize: 13,
              color: gold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required String trailingText,
    required Color trailingColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: trailingColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: darkGreen,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 'Home', true),
          _buildNavItem(Icons.history, 'History', false),
          _buildNavItem(Icons.notifications_none, 'Notifications', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? gold : Colors.white70,
          size: 24,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? gold : Colors.white70,
          ),
        ),
      ],
    );
  }
}