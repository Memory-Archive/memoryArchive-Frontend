import 'package:dio/dio.dart';

/// Builds the same DioException a real HTTP error would produce, so mock data
/// sources exercise the real error-handling path (safeApiCall and the backend
/// error parser) and not a shortcut.
DioException mockHttpError({
  required String path,
  required int statusCode,
  required Map<String, dynamic> body,
}) {
  final request = RequestOptions(path: path);
  return DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: request,
      statusCode: statusCode,
      data: body,
    ),
  );
}

/// The artificial latency used by every mock data source.
const Duration mockLatency = Duration(milliseconds: 600);
