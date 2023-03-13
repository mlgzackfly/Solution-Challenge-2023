import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:safego/model/api/fetch.dart';

class NewsData {
  final String title;
  final String content;
  final String pubDate;
  final dynamic photos;
  final String link;

  NewsData(this.title, this.content, this.pubDate, this.photos, this.link);
}

class TrafficNews extends StatefulWidget {
  const TrafficNews({Key? key}) : super(key: key);

  @override
  State<TrafficNews> createState() => _TrafficNewsState();
}

class _TrafficNewsState extends State<TrafficNews> {
  var data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    load();
  }

  void load() async {
    EasyLoading.show();
    data = await FetchTrafficNews().news();
    EasyLoading.dismiss();
    print(data);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (data != null)
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                primary: false,
                itemCount: data! == null ? 0 : data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          ListTile(
                            title: Text("${data[index]['Title']}"),
                            subtitle: Text(
                                data[index]['PubDate'].toString().split(" ")[0],
                                textAlign: TextAlign.right),
                            onTap: () => {
                              Navigator.pushNamed(
                                context,
                                '/news',
                                arguments: NewsData(
                                  data[index]['Title'],
                                  data[index]['Content'],
                                  data[index]['PubDate'],
                                  data[index]['Photos'],
                                  data[index]['Link'],
                                ),
                              )
                            },
                          ),
                        ],
                      ),
                      Divider(),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
