class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.polyclinic,
    required this.practiceTime,
    required this.imageUrl,
    required this.availableDates,
    required this.availableTimes,
    required this.fee,
  });

  final int id;
  final String name;
  final String specialty;
  final String polyclinic;
  final String practiceTime;
  final String imageUrl;
  final List<String> availableDates;
  final List<String> availableTimes;
  final int fee;
}
