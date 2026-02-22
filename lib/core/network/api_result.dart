class ApiResult<T> {
  final bool ok;
  final T? data;
  final Map<String, dynamic> meta;
  final String? message;
  final Map<String, dynamic>? errors;

  const ApiResult({
    required this.ok,
    this.data,
    this.meta = const {},
    this.message,
    this.errors,
  });
}