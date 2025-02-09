import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:inspector_gadget/tools/function_tool.dart';

class LocationTool implements FunctionTool {
  @override
  List<FunctionDeclaration> getFunctionDeclarations() {
    return [
      FunctionDeclaration(
        'fetchGpsLocation',
        'Returns the GPS location of the user.',
        parameters: {
          'place': Schema.number(
            description: 'The place to get the GPS coordinates for',
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
    return call.name == 'fetchGpsLocation';
  }

  @override
  Future<FunctionResponse> dispatchFunctionCall(FunctionCall call) async {
    final result = switch (call.name) {
      'fetchGpsLocation' => {
          'gpsLocation': {'lat': 36.746841, 'lon': -119.772591},
        },
      _ => <String, String>{}
    };

    return FunctionResponse(call.name, result);
  }
}
