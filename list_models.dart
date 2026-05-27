import 'dart:convert';
import 'dart:io';

void main() async {
  final apiKey = 'AIzaSyCEz2rCERdF1Q1Hbmfe-oaddNfS9OefUF4';
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');
  
  final request = await HttpClient().getUrl(url);
  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  
  try {
    final Map<String, dynamic> data = jsonDecode(responseBody);
    if (data.containsKey('models')) {
      final List models = data['models'];
      for (var model in models) {
        print('${model['name']} -> ${model['displayName']}');
      }
    } else {
      print(responseBody);
    }
  } catch (e) {
    print('Error: $e');
    print(responseBody);
  }
}

