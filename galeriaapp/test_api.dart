import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse('https://api.unsplash.com/photos?page=1&per_page=1'));
    request.headers.add('Authorization', 'Client-ID ET7UrmjptWQIQ8ihWaR5RsJEfEiyCOrJQMY7F1B6Qek');
    request.headers.add('Accept-Version', 'v1');
    
    final response = await request.close();
    print('Status code: ${response.statusCode}');
    
    final responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode == 200) {
      print('Success!');
      final data = jsonDecode(responseBody) as List;
      if (data.isNotEmpty) {
        print('Image URL: ${data[0]['urls']['regular']}');
      }
    } else {
      print('Error: $responseBody');
    }
  } finally {
    client.close();
  }
}
