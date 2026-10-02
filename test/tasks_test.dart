import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:qlaya_flutter/qlaya_flutter.dart';

void main() {
  group('QLaya Tasks (Powered by qlaya.int8.onnx)', () {
    test(
        'Classification Task creates correct payload with qlaya.int8.onnx and parses result',
        () async {
      late Map<String, dynamic> capturedBody;

      final mockClient = MockClient((request) async {
        capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
        expect(request.url.path, equals('/predict'));

        return http.Response(
          jsonEncode({
            'model_id': 'qlaya.int8.onnx',
            'latency_ms': 12.4,
            'answers': [
              {
                'id': 'intent',
                'value': 'billing_refund',
                'confidence': 0.96,
              }
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client =
          QLayaClient(baseUrl: 'http://localhost:8000', httpClient: mockClient);

      final result = await client.classify(
        text: 'I was double charged on my card, please refund',
        choices: ['billing_refund', 'cancellation', 'tech_support', 'other'],
        questionId: 'intent',
      );

      // Verify request payload used qlaya.int8.onnx
      expect(capturedBody['text'],
          equals('I was double charged on my card, please refund'));
      expect(capturedBody['model']['id'], equals('qlaya.int8.onnx'));
      expect(capturedBody['model']['file'], equals('qlaya.int8.onnx'));
      expect(capturedBody['model']['repo'], equals('saipy10/qlaya'));
      expect(capturedBody['model']['subfolder'], equals('qlaya-int8'));
      expect(capturedBody['questions'][0]['id'], equals('intent'));
      expect(capturedBody['questions'][0]['type'], equals('choice'));
      expect(
          capturedBody['questions'][0]['choices'], contains('billing_refund'));

      // Verify parsed typed result
      expect(result.choice, equals('billing_refund'));
      expect(result.confidence, equals(0.96));
      expect(result.rawAnswer.id, equals('intent'));
      expect(result.toString(), contains('billing_refund'));

      client.close();
    });

    test('Score Task rates continuous values using qlaya.int8.onnx', () async {
      late Map<String, dynamic> capturedBody;

      final mockClient = MockClient((request) async {
        capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'model_id': 'qlaya.int8.onnx',
            'answers': [
              {
                'id': 'urgency',
                'value': 0.88,
                'confidence': 0.92,
              }
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client =
          QLayaClient(baseUrl: 'http://localhost:8000', httpClient: mockClient);

      final result = await client.score(
        text: 'Production database is offline and customers cannot log in!',
        instruction: 'Rate severity from 0.0 (low) to 1.0 (critical)',
        questionId: 'urgency',
      );

      expect(capturedBody['model']['id'], equals('qlaya.int8.onnx'));
      expect(capturedBody['questions'][0]['type'], equals('score'));
      expect(result.score, equals(0.88));
      expect(result.confidence, equals(0.92));
      expect(result.toString(), contains('0.88'));

      client.close();
    });

    test('Score Task handles string numeric values safely', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'model_id': 'qlaya.int8.onnx',
            'answers': [
              {
                'id': 'score',
                'value': '0.75',
                'confidence': 0.85,
              }
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client =
          QLayaClient(baseUrl: 'http://localhost:8000', httpClient: mockClient);
      final result = await client.score(text: 'Good service');

      expect(result.score, equals(0.75));
      client.close();
    });

    test('Bool Verification Task evaluates conditions with qlaya.int8.onnx',
        () async {
      late Map<String, dynamic> capturedBody;

      final mockClient = MockClient((request) async {
        capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'model_id': 'qlaya.int8.onnx',
            'answers': [
              {
                'id': 'is_complaint',
                'value': true,
                'confidence': 0.98,
              }
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client =
          QLayaClient(baseUrl: 'http://localhost:8000', httpClient: mockClient);

      final result = await client.verify(
        text: 'This product stopped working after 2 days. Terrible quality.',
        statement:
            'The customer is expressing dissatisfaction or filing a complaint',
        questionId: 'is_complaint',
      );

      expect(capturedBody['model']['id'], equals('qlaya.int8.onnx'));
      expect(capturedBody['questions'][0]['type'], equals('bool'));
      expect(result.value, isTrue);
      expect(result.confidence, equals(0.98));
      expect(result.toString(), contains('true'));

      client.close();
    });

    test('Bool Verification Task handles string boolean responses', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'model_id': 'qlaya.int8.onnx',
            'answers': [
              {
                'id': 'verify',
                'value': 'yes',
                'confidence': 0.9,
              }
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client =
          QLayaClient(baseUrl: 'http://localhost:8000', httpClient: mockClient);
      final result = await client.verify(
        text: 'Cancel order',
        statement: 'User wants cancellation',
      );

      expect(result.value, isTrue);
      client.close();
    });

    test('Routing Task resolves workflow destination with qlaya.int8.onnx',
        () async {
      late Map<String, dynamic> capturedBody;

      final mockClient = MockClient((request) async {
        capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'model_id': 'qlaya.int8.onnx',
            'answers': [
              {
                'id': 'route',
                'value': 'tier3_engineering',
                'confidence': 0.94,
              }
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client =
          QLayaClient(baseUrl: 'http://localhost:8000', httpClient: mockClient);

      final result = await client.route(
        text: 'NullPointerException in auth module during oauth callback',
        routes: [
          'tier1_support',
          'tier2_billing',
          'tier3_engineering',
          'general_faq'
        ],
        instruction: 'Route this issue to the most qualified department',
      );

      expect(capturedBody['model']['id'], equals('qlaya.int8.onnx'));
      expect(capturedBody['questions'][0]['choices'],
          contains('tier3_engineering'));
      expect(result.route, equals('tier3_engineering'));
      expect(result.confidence, equals(0.94));
      expect(result.toString(), contains('tier3_engineering'));

      client.close();
    });

    test('runTask directly executes QLayaTask instance', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'model_id': 'qlaya.int8.onnx',
            'answers': [
              {
                'id': 'classification',
                'value': 'finance',
                'confidence': 0.99,
              }
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client =
          QLayaClient(baseUrl: 'http://localhost:8000', httpClient: mockClient);

      final task = QLayaTasks.classify(
        text: 'Quarterly earnings report is ready for audit',
        choices: ['finance', 'marketing', 'hr', 'legal'],
      );

      expect(task.model, equals(QLayaModels.int8));

      final result = await client.runTask(task);
      expect(result.choice, equals('finance'));
      expect(result.confidence, equals(0.99));

      client.close();
    });

    test('predict defaults to qlaya.int8.onnx when model is omitted', () async {
      late Map<String, dynamic> capturedBody;

      final mockClient = MockClient((request) async {
        capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'model_id': 'qlaya.int8.onnx',
            'latency_ms': 15.2,
            'answers': [
              {'id': 'q1', 'value': 'test'}
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client =
          QLayaClient(baseUrl: 'http://localhost:8000', httpClient: mockClient);

      final result = await client.predict(
        text: 'Hello QLaya',
      );

      expect(capturedBody['model']['id'], equals('qlaya.int8.onnx'));
      expect(capturedBody['model']['file'], equals('qlaya.int8.onnx'));
      expect(result.answers.first.value, equals('test'));

      client.close();
    });

    test('predict throws QLayaApiException on HTTP error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final client =
          QLayaClient(baseUrl: 'http://localhost:8000', httpClient: mockClient);

      expect(
        () => client.classify(text: 'test', choices: ['a', 'b']),
        throwsA(isA<QLayaApiException>()
            .having((e) => e.statusCode, 'statusCode', 500)),
      );

      client.close();
    });

    test(
        'throws StateError when server response lacks expected question answer',
        () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'model_id': 'qlaya.int8.onnx', 'answers': []}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client =
          QLayaClient(baseUrl: 'http://localhost:8000', httpClient: mockClient);

      expect(
        () => client.classify(text: 'test', choices: ['a', 'b']),
        throwsA(isA<StateError>()),
      );

      client.close();
    });
  });
}
