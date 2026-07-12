class AppFormatters {
  const AppFormatters._();

  static String rupiah(int value) {
    final safeValue = value < 0 ? 0 : value;
    final text = safeValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return 'Rp $text';
  }

  static String bookingDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;

    final dayName = switch (parsed.weekday) {
      DateTime.monday => 'Senin',
      DateTime.tuesday => 'Selasa',
      DateTime.wednesday => 'Rabu',
      DateTime.thursday => 'Kamis',
      DateTime.friday => 'Jumat',
      DateTime.saturday => 'Sabtu',
      _ => 'Minggu',
    };
    return '$dayName, ${parsed.day}/${parsed.month}/${parsed.year}';
  }

  static String paymentMethod(String value) {
    return switch (value.toLowerCase()) {
      'cash' => 'Bayar di Tempat',
      'qris' => 'QRIS',
      'transfer' || 'bank_transfer' => 'Transfer Bank',
      _ => value.isEmpty || value == '-' ? 'Belum dipilih' : value,
    };
  }
}
