import 'dart:convert';

import 'package:http/http.dart' as http;

String apiKey = "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";

class ApiServices {
  static String baseUrl = "https://api.openai.com/v1/completions";

  static Map<String, String> header = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey'
  };
  static sendMessage(String? message) async {
    var result = await http.post(
      Uri.parse(baseUrl),
      headers: header,
      body: jsonEncode(
        {
          "model": "text-davinci-003",
          "prompt": '$message',
          "temperature": 0,
          "max_tokens": 100,
          "top_p": 1,
          "frequency_penalty": 0.0,
          "presence_penalty": 0.0,
          "stop": ["Human", "AI:"]
        },
      ),
    );
    if (result.statusCode == 200) {
      var data = jsonDecode(result.body.toString());
      var msg = data['choices'][0]['text'];
      return msg;
    } else {
      print('failed to fetch data');
    }
  }
}
