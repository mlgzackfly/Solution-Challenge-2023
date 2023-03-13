import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:safego/pages/trafficnews.dart';
import '../model/api/fetch.dart';

class News extends StatefulWidget {
  const News({Key? key}) : super(key: key);

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  var data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    load();
  }

  void load() async {
    data = await FetchTrafficNews().news();
    print(data);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as NewsData;
    return Container(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Text(
                args.title,
                style: TextStyle(fontSize: 24),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  args.pubDate,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                  border: Border.all(width: 0.5),
                ),
                child: Column(
                  children: [
                    SelectableText(
                      removeAllHtmlTags(
                        HtmlUnescape().convert(args.content),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (args.photos != null)
                      for (var links in args.photos)
                        SizedBox(
                          width: double.infinity,
                          height: 400,
                          child: args.photos != null
                              ? Image.network(links)
                              : const Icon(Icons.photo),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
