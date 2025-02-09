import 'dart:developer';

import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/foundation.dart';
import 'package:inspector_gadget/prompts/closing_parts.dart';
import 'package:inspector_gadget/prompts/request_instruction.dart';
import 'package:inspector_gadget/prompts/system_instruction.dart';
import 'package:inspector_gadget/tools/tools_mixin.dart';

class AiService with ToolsMixin {
  ChatSession? chatSession;

  GenerativeModel getModel(String systemInstruction) {
    // Flattened tools into one tool: [getFunctionDeclarations()]
    // Multi tool how it should be: getToolDeclarations()
    // Issue 16883
    // https://github.com/firebase/flutterfire/issues/16883
    final tools = getToolDeclarations();
    final modelType = 'pro'; // 'flash' 'pro'
    return FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-1.5-$modelType',
      safetySettings: [
        SafetySetting(
          HarmCategory.harassment,
          HarmBlockThreshold.none,
        ),
        SafetySetting(
          HarmCategory.hateSpeech,
          HarmBlockThreshold.none,
        ),
        SafetySetting(
          HarmCategory.sexuallyExplicit,
          HarmBlockThreshold.high,
        ),
        SafetySetting(
          HarmCategory.dangerousContent,
          HarmBlockThreshold.none,
        ),
      ],
      systemInstruction: Content.text(systemInstruction),
      tools: tools,
    );
  }

  ChatSession? getChatSession(String systemInstruction) {
    if (chatSession == null) {
      debugPrint('systemInstruction: $systemInstructionTemplate');
      final model = getModel(systemInstructionTemplate);
      chatSession = model.startChat();
    }

    return chatSession;
  }

  Future<GenerateContentResponse?> chatStep(String prompt) async {
    final chat = getChatSession(systemInstructionTemplate);
    if (chat == null) {
      return null;
    }

    final stuffedPrompt = StringBuffer();
    stuffedPrompt
      ..write(
        requestInstructionTemplate.replaceAll(
          requestInstructionVariable,
          prompt,
        ),
      )
      ..write(closingInstructions);

    final stuffed = stuffedPrompt.toString();
    debugPrint('stuffed: $stuffed');
    var message = Content.text(stuffed);

    var response = GenerateContentResponse([], null);
    try {
      response = await chat.sendMessage(message);
    } catch (e) {
      log('Exception during chat.sendMessage: $e');
      return null;
    }

    List<FunctionCall> functionCalls;
    while ((functionCalls = response.functionCalls.toList()).isNotEmpty) {
      final responses = <FunctionResponse>[];
      for (final functionCall in functionCalls) {
        debugPrint('Function call ${functionCall.name}, '
            'params: ${functionCall.args}');
        try {
          final response = await dispatchFunctionCall(
            functionCall,
          );
          debugPrint('Function call result ${response?.response}');
          if (response?.response != null) {
            responses.add(response!);
          }
        } catch (e) {
          log('Exception during transcription: $e');
          return null;
        }
      }

      message.parts.addAll(responses);

      try {
        response = await chat.sendMessage(message);
      } catch (e) {
        log('Exception during function iteration chat.sendMessage: $e');
        return null;
      }
    }

    return response;
  }
}
