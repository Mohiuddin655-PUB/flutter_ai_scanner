import 'delegate.dart';
import 'request.dart';
import 'response.dart';

class Ai {
  Ai._();

  AiDelegate? _delegate;

  static Ai? _i;

  static Ai get i => _i ??= Ai._();

  static set delegate(AiDelegate delegate) => i._delegate = delegate;

  static AiDelegate get delegate {
    if (i._delegate == null) {
      throw UnimplementedError("AiDelegate not initialized yet!");
    }
    return i._delegate!;
  }

  static Future<AiCompletionResponse<T>> completions<T>(
    AiCompletionRequest<T> request,
  ) {
    return delegate.completions(request);
  }
}
