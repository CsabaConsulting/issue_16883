import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:http/http.dart' as http;
import 'package:inspector_gadget/tools/function_tool.dart';
import 'package:inspector_gadget/geo_request.dart';

class SevenTimerWeatherTool implements FunctionTool {
  @override
  List<FunctionDeclaration> getFunctionDeclarations() {
    return [
      FunctionDeclaration(
        'fetchWeatherForecast',
        'Returns the weather in a given location.',
        parameters: {
          'latitude': Schema.number(
            description: 'Latitude of the weather observation and forecast',
          ),
          'longitude': Schema.number(
            description: 'Longitude of the weather observation and forecast',
          ),
        },
      ),
    ];
  }

  @override
  Tool getTool() {
    return Tool.functionDeclarations(
      getFunctionDeclarations(),
    );
  }

  @override
  bool canDispatchFunctionCall(FunctionCall call) {
    return call.name == 'fetchWeatherForecast';
  }

  @override
  Future<FunctionResponse> dispatchFunctionCall(FunctionCall call) async {
    final result = switch (call.name) {
      'fetchWeatherForecast' => {
          'query': await _fetchWeatherForecast(GeoRequest.fromJson(call.args)),
        },
      _ => <String, String>{}
    };

    return FunctionResponse(call.name, result);
  }

  Future<String> _fetchWeatherForecast(GeoRequest geoRequest,
      [bool isMetric = true]) async {
    if (geoRequest.latitude.abs() < 10e-6 &&
        geoRequest.longitude.abs() < 10e-6) {
      return 'N/A';
    }

    // By Doc: https://www.7timer.info/bin/api.pl?lon=-119.8&lat=36.9&product=civil&output=json
    // Result: https://www.7timer.info/bin/civil.php?lon=-119.8&lat=36.9&ac=0&unit=metric&output=json&tzshift=0
    // Minimal: https://www.7timer.info/bin/civil.php?lon=-119.8&lat=36.9&output=json
    const weatherApiBaseUrl = 'www.7timer.info';
    const weatherApiPath = '/bin/civil.php';
    final weatherApiUrl = Uri.http(weatherApiBaseUrl, weatherApiPath, {
      'lon': geoRequest.longitude.toString(),
      'lat': geoRequest.latitude.toString(),
      'unit': isMetric ? 'metric' : 'british',
      'output': 'json',
      'tzshift': DateTime.now().timeZoneOffset.inHours.toString(),
    });

    final forecastResult = await http.get(weatherApiUrl);
    if (forecastResult.statusCode == 200) {
      return forecastResult.body;
    }

    return 'N/A';
  }
}
