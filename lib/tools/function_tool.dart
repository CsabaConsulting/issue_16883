import 'package:firebase_vertexai/firebase_vertexai.dart';

abstract class FunctionTool {
  List<FunctionDeclaration> getFunctionDeclarations();
  Tool getTool();
  bool canDispatchFunctionCall(FunctionCall call);
  Future<FunctionResponse?> dispatchFunctionCall(FunctionCall call);
}
