import 'dart:async';
import 'dart:io';
import 'package:charcode/ascii.dart';
import 'connection_info.dart';
import 'lockable_headers.dart';
import 'response.dart';
import 'session.dart';

class MockHttpRequest
    implements HttpRequest, StreamSink<List<int>>, StringSink {
  int _contentLength = 0;
  BytesBuilder _buf;
  final Completer _done = new Completer();
  final LockableMockHttpHeaders _headers = new LockableMockHttpHeaders();
  MockHttpSession _session;
  final StreamController<List<int>> _stream = new StreamController<List<int>>();

  @override
  final List<Cookie> cookies = [];

  @override
  final HttpConnectionInfo connectionInfo =
      new MockHttpConnectionInfo(remoteAddress: InternetAddress.ANY_IP_V4);

  @override
  final MockHttpResponse response = new MockHttpResponse();

  @override
  HttpSession get session => _session;

  @override
  final String method;

  @override
  final Uri uri;

  @override
  bool persistentConnection = true;

  /// [copyBuffer] corresponds to `copy` on the [BytesBuilder] constructor.
  MockHttpRequest(this.method, this.uri,
      {bool copyBuffer: true,
      String protocolVersion,
      String sessionId,
      this.certificate,
      this.persistentConnection}) {
    _buf = new BytesBuilder(copy: copyBuffer != false);
    _session = new MockHttpSession(id: sessionId ?? 'mock-http-session');
    this.protocolVersion =
        protocolVersion?.isNotEmpty == true ? protocolVersion : '1.1';
  }

  @override
  int get contentLength => _contentLength;

  @override
  HttpHeaders get headers => _headers;

  @override
  Uri get requestedUri => uri;

  @override
  String protocolVersion;

  @override
  X509Certificate certificate;

  @override
  void add(List<int> data) {
    if (_done.isCompleted)
      throw new StateError('Cannot add to closed MockHttpRequest.');
    else {
      _headers.lock();
      _contentLength += data.length;
      _buf.add(data);
    }
  }

  @override
  void addError(error, [StackTrace stackTrace]) {
    if (_done.isCompleted)
      throw new StateError('Cannot add to closed MockHttpRequest.');
    else
      _stream.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream<List<int>> stream) {
    var c = new Completer();
    stream.listen(add, onError: addError, onDone: c.complete);
    return c.future;
  }

  @override
  Future close() async {
    await flush();
    _headers.lock();
    _stream.close();
    _done.complete();
    return await _done.future;
  }

  @override
  Future get done => _done.future;

  // @override
  Future flush() async {
    _contentLength += _buf.length;
    _stream.add(_buf.takeBytes());
  }

  @override
  void write(Object obj) {
    obj?.toString()?.codeUnits?.forEach(writeCharCode);
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) {
    write(objects.join(separator ?? ""));
  }

  @override
  void writeCharCode(int charCode) {
    add([charCode]);
  }

  @override
  void writeln([Object obj = ""]) {
    write(obj ?? "");
    add([$cr, $lf]);
  }

  @override
  Future<bool> any(bool test(List<int> element)) => _stream.stream.any(test);

  @override
  Stream<List<int>> asBroadcastStream(
          {void onListen(StreamSubscription<List<int>> subscription),
          void onCancel(StreamSubscription<List<int>> subscription)}) =>
      _stream.stream.asBroadcastStream(onListen: onListen, onCancel: onCancel);

  @override
  Stream asyncExpand<E>(Stream convert(List<int> event)) => _stream.stream
      .asyncExpand(convert);

  @override
  Stream
      asyncMap<E>(convert(List<int> event)) => _stream.stream.asyncMap(convert);

  @override
  Future<bool> contains(Object needle) => _stream.stream.contains(needle);

  @override
  Stream<List<int>> distinct(
          [bool equals(List<int> previous, List<int> next)]) =>
      _stream.stream.distinct(equals);

  @override
  Future drain<E>([dynamic futureValue]) => _stream.stream.drain(futureValue);

  @override
  Future<List<int>> elementAt(int index) => _stream.stream.elementAt(index);

  @override
  Future<bool> every(bool test(List<int> element)) =>
      _stream.stream.every(test);

  @override
  Stream expand<S>(Iterable convert(List<int> value)) => _stream.stream
      .expand(convert);

  @override
  Future<List<int>> get first => _stream.stream.first;

  @override
  Future firstWhere(bool test(List<int> element), {Object defaultValue()}) =>
      _stream.stream.firstWhere(test, defaultValue: defaultValue);

  @override
  Future fold<S>(dynamic initialValue,
          dynamic combine(dynamic previous, List<int> element)) =>
      _stream.stream.fold(initialValue, combine);

  @override
  Future forEach(void action(List<int> element)) =>
      _stream.stream.forEach(action);

  @override
  Stream<List<int>> handleError(Function onError, {bool test(error)}) =>
      _stream.stream.handleError(onError, test: test);

  @override
  bool get isBroadcast => _stream.stream.isBroadcast;

  @override
  Future<bool> get isEmpty => _stream.stream.isEmpty;

  @override
  Future<String> join([String separator = ""]) =>
      _stream.stream.join(separator ?? "");

  @override
  Future<List<int>> get last => _stream.stream.last;

  @override
  Future lastWhere(bool test(List<int> element), {Object defaultValue()}) =>
      _stream.stream.lastWhere(test, defaultValue: defaultValue);

  @override
  Future<int> get length => _stream.stream.length;

  @override
  StreamSubscription<List<int>> listen(void onData(List<int> event),
          {Function onError, void onDone(), bool cancelOnError}) =>
      _stream.stream.listen(onData,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError == true);

  @override
  Stream
      map<S>(dynamic convert(List<int> event)) => _stream.stream.map(convert);

  @override
  Future pipe(StreamConsumer<List<int>> streamConsumer) =>
      _stream.stream.pipe(streamConsumer);

  @override
  Future<List<int>> reduce(
          List<int> combine(List<int> previous, List<int> element)) =>
      _stream.stream.reduce(combine);

  @override
  Future<List<int>> get single => _stream.stream.single;

  @override
  Future<List<int>> singleWhere(bool test(List<int> element)) =>
      _stream.stream.singleWhere(test);

  @override
  Stream<List<int>> skip(int count) => _stream.stream.skip(count);

  @override
  Stream<List<int>> skipWhile(bool test(List<int> element)) =>
      _stream.stream.skipWhile(test);

  @override
  Stream<List<int>> take(int count) => _stream.stream.take(count);

  @override
  Stream<List<int>> takeWhile(bool test(List<int> element)) =>
      _stream.stream.takeWhile(test);

  @override
  Stream<List<int>> timeout(Duration timeLimit,
          {void onTimeout(EventSink<List<int>> sink)}) =>
      _stream.stream.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<List<List<int>>> toList() => _stream.stream.toList();

  @override
  Future<Set<List<int>>> toSet() => _stream.stream.toSet();

  @override
  Stream transform<S>(StreamTransformer streamTransformer) => _stream.stream
      .transform(streamTransformer);

  @override
  Stream<List<int>> where(bool test(List<int> event)) =>
      _stream.stream.where(test);
}