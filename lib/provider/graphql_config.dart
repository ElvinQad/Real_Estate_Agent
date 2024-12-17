import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:clever_realtor/services/logger_service.dart';
import 'dart:io';
import 'package:clever_realtor/constants.dart';
import 'dart:async' show TimeoutException;

class GraphQLConfig {
  static String get uri {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        // Android emulator uses 10.0.2.2 to access host machine's localhost
        return 'http://10.0.2.2:3000/graphql';
      } else if (Platform.isIOS) {
        // iOS simulator can use localhost
        return 'http://localhost:3000/graphql';
      } else {
        // For web or other platforms
        return 'http://localhost:3000/graphql';
      }
    }
    return ApiConstants.prodEndpoint;
  }

  static ValueNotifier<GraphQLClient> initializeClient() {
    LoggerService.info('Initializing GraphQL client with URI: $uri');

    final HttpLink httpLink = HttpLink(
      uri,
      defaultHeaders: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    final TimeoutLink timeoutLink = TimeoutLink(
      timeout: ApiConstants.timeoutDuration,
    );

    final ErrorLink errorLink = ErrorLink(
      onException: (Request request, NextLink forward, Exception exception) {
        String errorMessage = 'GraphQL connection error';
        if (exception is ServerException) {
          if (exception.originalException is SocketException) {
            final socketException = exception.originalException as SocketException;
            errorMessage = 'Network error: ${socketException.message}. '
                'URI: $uri. Make sure the server is running and accessible.';
          } else if (exception.originalException is TimeoutException) {
            errorMessage =
                'Request timed out after ${ApiConstants.timeoutDuration.inSeconds} seconds';
          }
        }

        LoggerService.error(
          errorMessage,
          {
            'uri': uri,
            'request': request.operation.operationName,
            'error': exception.toString(),
          },
          StackTrace.current,
        );

        return Stream.error(exception);
      },
    );

    final Link link = Link.from([
      errorLink,
      timeoutLink,
      httpLink,
    ]);

    final GraphQLClient client = GraphQLClient(
      link: link,
      cache: GraphQLCache(
        store: HiveStore(),
      ),
      defaultPolicies: DefaultPolicies(
        query: Policies(
          fetch: FetchPolicy.networkOnly, // Changed to ensure fresh data
          error: ErrorPolicy.all,
          cacheReread: CacheRereadPolicy.mergeOptimistic,
        ),
      ),
    );

    return ValueNotifier(client);
  }
}

class TimeoutLink extends Link {
  final Duration timeout;

  TimeoutLink({required this.timeout});

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    return forward!(request).timeout(timeout);
  }
}
