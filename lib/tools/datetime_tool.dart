import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:inspector_gadget/tools/function_tool.dart';

class DateTimeTool implements FunctionTool {
  @override
  List<FunctionDeclaration> getFunctionDeclarations() {
    return [
      FunctionDeclaration(
        'fetchCurrentDateTime',
        'Returns the current datetime.',
        parameters: {},
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
    return call.name == 'fetchCurrentDateTime';
  }

  @override
  Future<FunctionResponse> dispatchFunctionCall(FunctionCall call) async {
    final result = switch (call.name) {
      'fetchCurrentDateTime' => {
          'dateTime': {'lat': 36.746841, 'lon': -119.772591},
        },
      _ => <String, String>{}
    };

    return FunctionResponse(call.name, result);
  }
}
