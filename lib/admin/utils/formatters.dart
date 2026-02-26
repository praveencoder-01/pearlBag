String dowShort(int weekday) {
  const map = {
    DateTime.monday: 'Mon',
    DateTime.tuesday: 'Tue',
    DateTime.wednesday: 'Wed',
    DateTime.thursday: 'Thu',
    DateTime.friday: 'Fri',
    DateTime.saturday: 'Sat',
    DateTime.sunday: 'Sun',
  };
  return map[weekday] ?? '';
}

String monShort(int month) {
  const map = {
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec',
  };
  return map[month] ?? '';
}

String normalizeStatus(String s) {
  final t = s.toLowerCase();
  if (t.contains('deliver')) return 'Delivered';
  if (t.contains('cancel')) return 'Cancelled';
  if (t.contains('ship')) return 'Shipped';
  if (t.contains('process')) return 'Processing';
  return 'Pending';
}