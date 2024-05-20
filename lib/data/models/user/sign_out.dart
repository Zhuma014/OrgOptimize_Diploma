import 'package:urven/data/models/base/api_result.dart';

class SignOut extends APIResponse {
  String? exception; // #LocalVariable

  SignOut.map(dynamic o) : super.map(o);

  SignOut.withError(String errorValue)
      : exception = errorValue,
        super.map(null);
}
