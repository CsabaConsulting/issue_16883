import 'dart:convert';

import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:http/http.dart' as http;
import 'package:inspector_gadget/tools/function_tool.dart';

class LyricsTool implements FunctionTool {
  @override
  List<FunctionDeclaration> getFunctionDeclarations() {
    return [
      FunctionDeclaration(
        'lyricsLookup',
        'Look up a lyrics of a song by a given artist and title',
        parameters: {
          'artist': Schema.string(
            description: 'The artist of the song',
          ),
          'title': Schema.string(
            description: 'The title of the song',
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
    return call.name == 'lyricsLookup';
  }

  @override
  Future<FunctionResponse> dispatchFunctionCall(FunctionCall call) async {
    final result = switch (call.name) {
      'lyricsLookup' => {
          'query': await _lyricsLookup(call.args),
        },
      _ => <String, String>{}
    };

    return FunctionResponse(call.name, result);
  }

  Future<String> _lyricsLookup(Map<String, Object?> jsonObject) async {
    final artist = (jsonObject['artist'] ?? '') as String;
    final title = (jsonObject['title'] ?? '') as String;
    if (artist.isNullOrWhiteSpace || title.isNullOrWhiteSpace) {
      return 'N/A';
    }

    const lyricsApiBaseUrl = 'api.lyrics.ovh';
    final lyricsApiPath = '/v1/$artist/$title';
    final lyricsApiUrl = Uri.https(lyricsApiBaseUrl, lyricsApiPath);

    final searchResult = await http.get(lyricsApiUrl);
    if (searchResult.statusCode == 200) {
      final resultJson = json.decode(searchResult.body) as Map<String, dynamic>;
      if (resultJson.containsKey('lyrics')) {
        return resultJson['lyrics'] as String;
      }
    }

    return 'N/A';
  }
}
