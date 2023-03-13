import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safego/model/api/fetch.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:url_launcher/url_launcher.dart';

class AttractionsPage extends StatefulWidget {
  const AttractionsPage({Key? key}) : super(key: key);

  @override
  State<AttractionsPage> createState() => _AttractionsPageState();
}

class _AttractionsPageState extends State<AttractionsPage> {
  var data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  void loadData() async {
    EasyLoading.show();
    data = await Provider.of<FetchAttrations>(context, listen: false).fetch();
    EasyLoading.dismiss();
    setState(() {});
  }

  void openMap(String addr) async {
    String mapsUrl = "https://www.google.com/maps/search/?api=1&query=$addr";

    if (await canLaunch(mapsUrl)) {
      await launch(mapsUrl);
    } else {
      throw "無法開啟地圖 $mapsUrl";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (data != null)
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                primary: false,
                itemCount: data!["data"] == null ? 0 : data!["data"].length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          data!["data"][index]["公司名稱"],
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          data!["data"][index]["類別"],
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const Divider(),
                        Text(data!["data"][index]["優惠方式"]),
                        SelectableText(data!["data"][index]["連絡電話"]),
                        TextButton(
                          onPressed: () =>
                              openMap(data!["data"][index]["店面地址"]),
                          child: Text(data!["data"][index]["店面地址"]),
                        ),
                        Text("活動到期日:${data!["data"][index]["活動到期日"]}"),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
