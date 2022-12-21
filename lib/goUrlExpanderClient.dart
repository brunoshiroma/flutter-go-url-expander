import 'package:http/http.dart' as http;

class GoUrlExpanderClient {

  static Future<String?> getUrlExpanded(String url) async {
    if (url == 'NO DATA') {
      return null;
    }

    var sanitizedUrl = RegExp(
      r'.*(http[s]{0,1}:\/\/\S+).*',
    ).firstMatch(url)?.group(0);

    if (sanitizedUrl == null) {
      return null;
    }

    sanitizedUrl = Uri.encodeComponent(sanitizedUrl);

    var requestUrl = Uri.parse(
        'https://go-url-expander.brunoshiroma.com/expand?url=$sanitizedUrl');
    var response = await http.get(requestUrl);

    if (response.statusCode == 200) {
      return response.body;

    }

    return null;
  }

}