import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:text_to_speech_api/text_to_speech_api.dart';
import '../service/NewsService.dart';
import '../util/constants.dart';

const GREY_COLOR = Color.fromRGBO(64, 75, 96, .9);

class NewsReader extends StatefulWidget {
  @override
  _NewsReaderState createState() => _NewsReaderState();
}

class _NewsReaderState extends State<NewsReader> {
  final TextToSpeechService textToSpeechService = TextToSpeechService(API_KEY);
  final NewsService newsService = NewsService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription _audioPlayerStateSubscription;

  List<NewsItem> _news = [];
  bool _isLoading = false;
  bool _isPlaying = false;
  int _newsIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadNews();

    _audioPlayerStateSubscription =
        _audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.COMPLETED) {
        if (_newsIndex < _news.length - 1) {
          setState(() {
            _newsIndex++;
          });
          _playItem(_news[_newsIndex]);
        } else {
          setState(() {
            _isPlaying = false;
            _newsIndex = 0;
          });
        }
      }
    });
  }

  @override
  dispose() {
    _audioPlayerStateSubscription.cancel();
    _audioPlayer.stop();
    super.dispose();
  }

  _loadNews() async {
    var news = await newsService.getNews();
    print(news);
    setState(() {
      _news = news;
    });
  }

  onNewsItemTap(int index) {
    setState(() {
      _newsIndex = index;
    });
    _playItem(_news[index]);
  }

  _playItem(NewsItem item) async {
    setState(() {
      _isLoading = true;
    });
    String text = '${item.title}. ${item.description}';
    File audioFile = await textToSpeechService.textToSpeech(
      text: text.replaceAll('"', ' '),
    );
    _audioPlayer.play(audioFile.path, isLocal: true);
    setState(() {
      _isLoading = false;
      _isPlaying = true;
    });
  }

  onPlayPress() async {
    if (_isPlaying) {
      // Stop Audio
      _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
      return;
    }
    // Select news item
    _playItem(_news[_newsIndex]);
  }

  _openDetails(int index) async {
    String url = _news[index].sourceUrl;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  onSettingsScreen() {
    print("Navigate");
  }

  Widget _buildNewsCard(int index) {
    NewsItem item = _news[index];
    final buildCardContent = Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        children: <Widget>[
          Text(
            item.title,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.linear_scale, color: Colors.yellowAccent),
                  Text(" ${item.category}",
                      style: TextStyle(color: Colors.white))
                ],
              ),
              Text(" ${item.description}",
                  style: TextStyle(color: Colors.white))
            ],
          ),
        ],
      ),
    );

    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
      child: Material(
        color: GREY_COLOR,
        child: InkWell(
          child: Container(
            decoration: BoxDecoration(),
            child: buildCardContent,
          ),
          onTap: () {
            onNewsItemTap(index);
          },
          onDoubleTap: () {
            _openDetails(index);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GREY_COLOR,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 150.0,
            backgroundColor: GREY_COLOR,
            actions: <Widget>[
              IconButton(icon: Icon(Icons.list), onPressed: onSettingsScreen)
            ],
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title:
                    Text('News Reader', style: TextStyle(color: Colors.white)),
                background: Image(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                      "https://images.unsplash.com/photo-1485579149621-3123dd979885?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2689&q=80"),
                )),
          ),
          SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 1.5,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return _buildNewsCard(index);
              },
              childCount: _news.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onPlayPress,
        child: Icon(_isLoading
            ? Icons.access_time
            : _isPlaying ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}
