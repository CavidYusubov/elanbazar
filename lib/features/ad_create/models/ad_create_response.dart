class AdCreateResponse {
  final bool ok;
  final String message;
  final int id;
  final String status;
  final String title;

  const AdCreateResponse({
    required this.ok,
    required this.message,
    required this.id,
    required this.status,
    required this.title,
  });

  factory AdCreateResponse.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] as Map? ?? {});
    return AdCreateResponse(
      ok: json['ok'] == true,
      message: (json['message'] ?? '').toString(),
      id: ((data['id'] ?? 0) as num).toInt(),
      status: (data['status'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
    );
  }
}