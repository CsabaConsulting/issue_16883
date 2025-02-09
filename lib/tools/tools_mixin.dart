import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:inspector_gadget/tools/datetime_tool.dart';
import 'package:inspector_gadget/tools/function_tool.dart';
import 'package:inspector_gadget/tools/location_tool.dart';
import 'package:inspector_gadget/tools/lyrics_tool.dart';
import 'package:inspector_gadget/tools/seven_timer_weather_tool.dart';

mixin ToolsMixin {
  List<FunctionTool> functionTools = [];

  List<FunctionTool> initializeFunctionTools() {
    if (functionTools.isNotEmpty) {
      return functionTools;
    }

    functionTools.addAll([
      LocationTool(),
      DateTimeTool(),
      SevenTimerWeatherTool(),
      LyricsTool(),
    ]);

    return functionTools;
  }

  List<Tool> getToolDeclarations() {
    final funcTools = initializeFunctionTools();
    final tools = <Tool>[];
    for (final funcTool in funcTools) {
      tools.add(funcTool.getTool());
    }

    return tools;
  }

  Tool getFunctionDeclarations() {
    final funcTools = initializeFunctionTools();
    final functionDeclarations = <FunctionDeclaration>[];
    for (final funcTool in funcTools) {
      functionDeclarations.addAll(funcTool.getFunctionDeclarations());
    }

    return Tool.functionDeclarations(
      functionDeclarations,
    );
  }

  Future<FunctionResponse?> dispatchFunctionCall(FunctionCall call) async {
    for (final functionTool in functionTools) {
      if (functionTool.canDispatchFunctionCall(call)) {
        final futureResponse = functionTool.dispatchFunctionCall(call);

        final functionResponses = await Future.wait([futureResponse]);
        if (functionResponses.isNotEmptyOrNull) {
          return functionResponses[0];
        }
      }
    }

    return FunctionResponse(call.name, {});
  }
}
