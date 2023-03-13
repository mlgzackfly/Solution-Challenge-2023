import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class FeedBackPage extends StatefulWidget {
  const FeedBackPage({Key? key}) : super(key: key);

  @override
  State<FeedBackPage> createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference feedback =
      FirebaseFirestore.instance.collection('feedback');

  final TextEditingController _place = TextEditingController();
  final TextEditingController _content = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? imageURL;
  File? _image;
  int errorsCount = 0;

  Future<dynamic> uploadImage(File file) async {
    String url = "https://api.imgur.com/3/upload";
    String accessToken = "6fdcf5143cd447fef66833339f1c6d9f1d9c7d94";
    var dio = Dio();
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap(
      {
        "image": await MultipartFile.fromFile(file.path, filename: fileName),
      },
    );
    try {
      EasyLoading.show(status: '上傳中...');
      var response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Connection": "keep-alive",
            "Authorization": "Bearer 'Bearer $accessToken",
          },
        ),
      );
      print(response.data);
      if (response.data['success']) {
        EasyLoading.showSuccess('上傳成功！');
        setState(
          () {
            imageURL = response.data['data']['link'];
          },
        );
      }
      EasyLoading.dismiss();
    } on DioError catch (e) {
      print(e);
      if (e.error is SocketException || e.type == DioErrorType.other) {
        // TODO: handle SocketException
        if (errorsCount <= 2) {
          await Future.delayed(const Duration(seconds: 1));
          errorsCount++;
          return await uploadImage(file);
        }
      }
      errorsCount = 0;
    }
  }

  Future<void> sendFeedback() {
    return feedback
        .add(
            {'place': _place.text, 'content': _content.text, 'image': imageURL})
        .then((value) => print("新增回饋"))
        .catchError((error) => print("錯誤： $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            I18nText(
              "feedback.place",
              child: const Text(
                "",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8CBBF1),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextField(
                controller: _place,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.0),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            I18nText(
              "feedback.content",
              child: const Text(
                "",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8CBBF1),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _content,
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.0),
                  ),
                  border: OutlineInputBorder(),
                ),
                expands: true,
                maxLines: null,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            I18nText(
              "feedback.photo",
              child: const Text(
                "",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8CBBF1),
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                child: _image != null
                    ? Image.file(_image!)
                    : const Icon(Icons.photo),
              ),
            ),
            if (imageURL == null)
              Center(
                child: I18nText(
                  "feedback.Description",
                ),
              ),
            if (imageURL != null)
              Center(
                child: Text("$imageURL"),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.all(10.0),
                  width: 100,
                  height: 40,
                  child: InkWell(
                    splashColor: Colors.blue,
                    onTap: () async {
                      XFile? image =
                          await _picker.pickImage(source: ImageSource.gallery);
                      setState(
                        () {
                          if (image != null) {
                            _image = File(image.path);
                          }
                          uploadImage(_image!);
                        },
                      );
                    },
                    child: Ink(
                      decoration: const BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                        color: Color(0xFFFCEECB),
                      ),
                      child: Center(
                        child: I18nText(
                          "feedback.choosePhoto",
                          child: const Text(
                            "",
                            style: TextStyle(
                              color: Color(0xFF65542B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 100,
                  height: 40,
                  child: InkWell(
                    splashColor: Colors.blue,
                    onTap: () => {
                      sendFeedback(),
                      debugPrint(
                          "上傳\n地點：${_place.text}\n內容：${_content.text}\n圖片網址：$imageURL")
                    },
                    child: Ink(
                      decoration: const BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                        color: Color(0xFFFCEECB),
                      ),
                      child: Center(
                        child: I18nText(
                          "feedback.uploadPhoto",
                          child: const Text(
                            "",
                            style: TextStyle(
                              color: Color(0xFF65542B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
