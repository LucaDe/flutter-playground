import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

const NEWS_FEED_URL = 'https://www.n-tv.de/rss';

class NewsItem {
  final String title;
  final String description;
  final String category;
  final String sourceUrl;

  NewsItem(this.title, this.description, this.category, this.sourceUrl);
}

class NewsService {
  List<NewsItem> _createNewsItems(String feed) {
    var parsedFeed = xml.parse(feed);
    var items = parsedFeed
        .findAllElements('item')
        .map((node) => NewsItem(
              node.findElements('title').single.text,
              node.findElements('description').single.text,
              node.findElements('category').single.text,
              node.findElements('link').single.text,
            ))
        .toList();
    return items;
  }

  Future<List<NewsItem>> getNews() {
    return http.get(NEWS_FEED_URL).then((response) {
      return _createNewsItems(response.body);
    });
  }
}
