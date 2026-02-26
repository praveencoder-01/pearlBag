import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_website/admin/utils/formatters.dart';

/// =======================================================
/// Charts (fl_chart) - improved styling
/// =======================================================
///
class OrderAnalytics {
  final List<double> last7DaysRevenue; // index 0..6
  final List<String> last7DaysLabels; // e.g. Mon Tue ...
  final List<double> last6MonthsRevenue; // index 0..5
  final List<String> last6MonthsLabels; // e.g. Sep Oct ...
  final Map<String, int>
  statusCounts; // Pending/Processing/Shipped/Delivered/Cancelled

  OrderAnalytics({
    required this.last7DaysRevenue,
    required this.last7DaysLabels,
    required this.last6MonthsRevenue,
    required this.last6MonthsLabels,
    required this.statusCounts,
  });

  static OrderAnalytics fromOrders(List<QueryDocumentSnapshot> docs) {
    final now = DateTime.now();
    DateTime dayStart(DateTime d) => DateTime(d.year, d.month, d.day);

    final last7 = List<double>.filled(7, 0.0);
    final labels7 = List<String>.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return dowShort(d.weekday);
    });

    final last6 = List<double>.filled(6, 0.0);
    final labels6 = List<String>.generate(6, (i) {
      final m = DateTime(now.year, now.month - (5 - i), 1);
      return monShort(m.month);
    });

    final status = <String, int>{
      'Pending': 0,
      'Processing': 0,
      'Shipped': 0,
      'Delivered': 0,
      'Cancelled': 0,
    };

    for (final d in docs) {
      final data = d.data() as Map<String, dynamic>;

      final amountAny = data['totalAmount'];
      final amount = (amountAny is num) ? amountAny.toDouble() : 0.0;

      final ts = data['createdAt'];
      final created = (ts is Timestamp) ? ts.toDate() : null;

      final rawStatus = (data['orderStatus'] ?? 'Pending').toString();
      final normalized = normalizeStatus(rawStatus);
      status[normalized] = (status[normalized] ?? 0) + 1;

      if (created == null) continue;

      final createdDay = dayStart(created);
      final today = dayStart(now);
      final diff = today.difference(createdDay).inDays; // 0 = today
      if (diff >= 0 && diff <= 6) {
        final idx = 6 - diff; // oldest..newest
        last7[idx] += amount;
      }

      final createdMonth = DateTime(created.year, created.month, 1);
      for (int i = 0; i < 6; i++) {
        final bucketMonth = DateTime(now.year, now.month - (5 - i), 1);
        if (bucketMonth.year == createdMonth.year &&
            bucketMonth.month == createdMonth.month) {
          last6[i] += amount;
          break;
        }
      }
    }

    return OrderAnalytics(
      last7DaysRevenue: last7,
      last7DaysLabels: labels7,
      last6MonthsRevenue: last6,
      last6MonthsLabels: labels6,
      statusCounts: status,
    );
  }
}
