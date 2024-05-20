import 'package:urven/utils/primitive/dynamic_utils.dart';

class APIResponse<T> {
  bool success = false;
  T? _result;
  String? message;

  APIResponse.map(dynamic o) {
    if (o != null) {
      // Logger.d('ApiResult=' + o.toString());
      if (o['success'] != null) {
        success = DynamicUtils.parseBool(o['success'], defaultValue: false);
      }
      if (o['result'] != null) {
        _result = o['result'];
      }
    }
  }

  T? getData() => _result;

  APIResponse.withError(String errorValue) : message = errorValue;

  @override
  String toString() {
    return 'APIResponse(success=$success, _result=$_result, message=$message)';
  }
}

