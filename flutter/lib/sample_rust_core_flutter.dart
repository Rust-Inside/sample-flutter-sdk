import 'dart:convert' as convert;
import 'dart:ffi' as ffi;
import 'dart:isolate' as isolate;
import 'package:ffi/ffi.dart' as mem;

@ffi.Native<ffi.Pointer<mem.Utf8> Function(ffi.Pointer<mem.Utf8>)>(
  symbol: 'sample_rust_core_flutter_call', assetId: 'package:sample_rust_core_flutter/sample_rust_core_flutter.dart',
)
external ffi.Pointer<mem.Utf8> _nativeCall(ffi.Pointer<mem.Utf8> request);

@ffi.Native<ffi.Void Function(ffi.Pointer<mem.Utf8>)>(
  symbol: 'sample_rust_core_flutter_free', assetId: 'package:sample_rust_core_flutter/sample_rust_core_flutter.dart',
)
external void _nativeFree(ffi.Pointer<mem.Utf8> response);

Object? _call(String method, List<Object?> args) {
  final message = convert.jsonEncode([method, ...args]);
  final request = mem.StringUtf8Pointer(message).toNativeUtf8(allocator: mem.calloc);
  try {
    final response = _nativeCall(request);
    try {
      final data = convert.jsonDecode(mem.Utf8Pointer(response).toDartString()) as Map;
      if (data.containsKey('error')) throw StateError(data['error'] as String);
      return data['value'];
    } finally {
      _nativeFree(response);
    }
  } finally {
    mem.calloc.free(request);
  }
}

// Send only the method name and wire values to the worker isolate.
Future<Object?> _worker(String method, List<Object?> args) =>
    isolate.Isolate.run(() => _call(method, args));

abstract base class _Client {
  static final _finalizer = Finalizer<int>((id) => _call('_close', [id]));
  final int _id;
  int _pending = 0;
  bool _closed = false;

  _Client(this._id) { _finalizer.attach(this, _id, detach: this); }

  Future<Object?> _invoke(String method, List<Object?> args) async {
    if (_closed) throw StateError('SDK client is closed');
    _pending++;
    try {
      return await _worker(method, [_id, ...args]);
    } finally {
      _pending--;
      if (_closed && _pending == 0) _release();
    }
  }

  void _release() {
    _finalizer.detach(this);
    _call('_close', [_id]);
  }

  /// Release native state after any calls already in progress have finished.
  void close() {
    if (_closed) return;
    _closed = true;
    if (_pending == 0) _release();
  }
}

final class Me {
  final String id;
  final String handle;
  final String displayName;
  const Me({required this.id, required this.handle, required this.displayName});
  factory Me._from(Map data) => Me(
    id: data['id'] as String,
    handle: data['handle'] as String,
    displayName: data['displayName'] as String,
  );
}

final class AccountClient extends _Client {
  AccountClient({required String baseUrl, required String authorization})
    : super(_call('AccountClient.new', [baseUrl, authorization]) as int);

  Future<Me> getMe() async =>
      Me._from(await _invoke('AccountClient.get_me', []) as Map);
}
