
import 'package:flutter/material.dart';

const navy = Color(0xFF12345A);
const green = Color(0xFF299B70);
const red = Color(0xFFD65B5B);
const orange = Color(0xFFD99A42);

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 850;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back, User!',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Here is your medicine overview for today.',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 25),

              // Summary cards
              GridView.count(
                crossAxisCount: wide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: wide ? 1.7 : 1.5,
                children: const [
                  SummaryCard(
                    title: 'Doses Taken',
                    value: '6 / 7',
                    subtitle: 'Today',
                    icon: Icons.medication,
                    color: green,
                  ),
                  SummaryCard(
                    title: 'Next Dose',
                    value: '07:00 PM',
                    subtitle: 'Vitamin D3',
                    icon: Icons.access_time,
                    color: navy,
                  ),
                  SummaryCard(
                    title: 'Low Stock',
                    value: '3 medicines',
                    subtitle: 'Needs refill',
                    icon: Icons.inventory_2_outlined,
                    color: red,
                  ),
                  SummaryCard(
                    title: 'Expiring Soon',
                    value: '2 medicines',
                    subtitle: 'Within 15 days',
                    icon: Icons.calendar_month,
                    color: orange,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Compliance and device status
              if (wide)
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ComplianceSection(),
                    ),
                    SizedBox(width: 18),
                    Expanded(
                      flex: 2,
                      child: DeviceSection(),
                    ),
                  ],
                )
              else ...[
                const ComplianceSection(),
                const SizedBox(height: 18),
                const DeviceSection(),
              ],

              const SizedBox(height: 25),

              // Inventory and recent activity
              if (wide)
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: InventorySection(),
                    ),
                    SizedBox(width: 18),
                    Expanded(
                      flex: 2,
                      child: ActivitySection(),
                    ),
                  ],
                )
              else ...[
                const InventorySection(),
                const SizedBox(height: 18),
                const ActivitySection(),
              ],
            ],
          ),
        );
      },
    );
  }
}

// Summary card

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 21),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable white section

class WhiteSection extends StatelessWidget {
  final String title;
  final Widget child;

  const WhiteSection({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: navy,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

// Weekly compliance

class ComplianceSection extends StatelessWidget {
  const ComplianceSection({super.key});

  @override
  Widget build(BuildContext context) {
    const days = [
      ['Mon', 92],
      ['Tue', 95],
      ['Wed', 78],
      ['Thu', 98],
      ['Fri', 90],
      ['Sat', 72],
      ['Sun', 86],
    ];

    return WhiteSection(
      title: 'Weekly Compliance',
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 12,
        runSpacing: 15,
        children: days.map((day) {
          return Column(
            children: [
              SizedBox(
                width: 43,
                height: 43,
                child: CircularProgressIndicator(
                  value: (day[1] as int) / 100,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    (day[1] as int) >= 85 ? green : orange,
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '${day[1]}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                day[0] as String,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// Device status

class DeviceSection extends StatelessWidget {
  const DeviceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const WhiteSection(
      title: 'Pillbox Device Status',
      child: Column(
        children: [
          DeviceRow('Connection', 'Online', green),
          DeviceRow('Battery', '92%', green),
          DeviceRow('Wi-Fi', 'Connected', green),
          DeviceRow('Last Sync', '08:25 AM', navy),
        ],
      ),
    );
  }
}

class DeviceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const DeviceRow(this.label, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Medicine inventory

class InventorySection extends StatelessWidget {
  const InventorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return WhiteSection(
      title: 'Medicine Inventory Summary',
      child: Column(
        children: const [
          InventoryRow('Medicine', 'Stock', 'Status', header: true),
          Divider(),
          InventoryRow('Metformin 500mg', '12 / 100', 'Low'),
          Divider(),
          InventoryRow('Amlodipine 5mg', '45 / 100', 'Good'),
          Divider(),
          InventoryRow('Atorvastatin 10mg', '3 / 100', 'Low'),
          Divider(),
          InventoryRow('Vitamin D3', '200 / 300', 'Good'),
        ],
      ),
    );
  }
}

class InventoryRow extends StatelessWidget {
  final String medicine;
  final String stock;
  final String status;
  final bool header;

  const InventoryRow(
    this.medicine,
    this.stock,
    this.status, {
    super.key,
    this.header = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = status == 'Low' ? red : green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              medicine,
              style: TextStyle(
                fontSize: 12,
                color: header ? Colors.grey : navy,
                fontWeight: header ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              stock,
              style: TextStyle(
                fontSize: 12,
                color: header ? Colors.grey : navy,
                fontWeight: header ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                color: header ? Colors.grey : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Recent activity

class ActivitySection extends StatelessWidget {
  const ActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return const WhiteSection(
      title: 'Recent Activity',
      child: Column(
        children: [
          ActivityRow(
            'Morning dose taken',
            'Today · 08:00 AM',
            green,
          ),
          ActivityRow(
            'Afternoon dose missed',
            'Today · 02:00 PM',
            red,
          ),
          ActivityRow(
            'Low stock detected',
            'Today · 09:30 AM',
            orange,
          ),
          ActivityRow(
            'Device back online',
            'Today · 08:25 AM',
            green,
          ),
        ],
      ),
    );
  }
}

class ActivityRow extends StatelessWidget {
  final String title;
  final String time;
  final Color color;

  const ActivityRow(this.title, this.time, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 9, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
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
