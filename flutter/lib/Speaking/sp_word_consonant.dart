import 'package:flutter/material.dart';
import 'package:zerozone/Login/login.dart';
import 'package:zerozone/Login/refreshToken.dart';

import 'sp_word_select.dart';
import 'sp_practiceview_word.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class WordList {
  final String word;
  final int index;

  WordList(this.word, this.index);
}

class ChooseWordConsonantPage extends StatefulWidget {
  const ChooseWordConsonantPage({Key? key}) : super(key: key);

  @override
  _ChooseWordConsonantPageState createState() => _ChooseWordConsonantPageState();
}

class _ChooseWordConsonantPageState extends State<ChooseWordConsonantPage> {

  int letterId = 0;
  String letter = 'ㄱ';

  final wordList = new List<WordList>.empty(growable: true);

  List<String> consonantList = ['ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'];

  getGridViewSelectedItem(BuildContext context, String gridItem, int index){

    letterInfo(gridItem, index + 1);
  }

  void letterInfo(String gridItem, int index) async {

    Map<String, String> _queryParameters = <String, String>{
      'onsetId': index.toString(),
      'onset': gridItem
    };

    var url = Uri.http('localhost:8080', '/speaking/list/word', _queryParameters);

    var response = await http.get(url, headers: {'Accept': 'application/json', "content-type": "application/json", "Authorization": "Bearer ${authToken}" });

    print(url);

    if (response.statusCode == 200) {
      print('Response body: ${jsonDecode(utf8.decode(response.bodyBytes))}');

      var body = jsonDecode(utf8.decode(response.bodyBytes));

      dynamic data = body["data"];

      for(dynamic i in data){
        String a = i["word"];
        int b = i["id"];
        wordList.add(WordList(a, b));
      }

      print("wordList: ${wordList}");
      // urlInfo(letter, letterId);

      Navigator.of(context).pop();
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => WordSelectPage(consonant: gridItem, wordList: wordList))
      );

    }
    else if(response.statusCode == 401){
      await RefreshToken(context);
      if(check == true){
        letterInfo(gridItem, index);
        check = false;
      }
    }
    else {
      print('error : ${response.reasonPhrase}');
    }

  }

  void urlInfo(String letter, int letterId) async {

    Map<String, String> _queryParameters = <String, String>{
      'id' : letterId.toString(),
    };

    var url = Uri.http('localhost:8080', '/speaking/practice/letter', _queryParameters);

    var response = await http.get(url, headers: {'Accept': 'application/json', "content-type": "application/json", "Authorization": "Bearer ${authToken}" });

    print(url);

    if (response.statusCode == 200) {
      print('Response body: ${jsonDecode(utf8.decode(response.bodyBytes))}');

      var body = jsonDecode(utf8.decode(response.bodyBytes));

      dynamic data = body["data"];

      String url = data["url"];
      String type = data["type"];

      print("url : ${url}");
      print("type : ${type}");

    }
    else if(response.statusCode == 401){
      await RefreshToken(context);
      if(check == true){
        urlInfo(letter, letterId);
        check = false;
      }
    }
    else {
      print('error : ${response.reasonPhrase}');
    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text(
            '말하기 연습 - 단어',
            style: TextStyle(color: Color(0xff333333), fontSize: 24, fontWeight: FontWeight.w800),
          ),
          backgroundColor: Color(0xffC8E8FF),
          foregroundColor: Color(0xff333333),
        ),
        body: new Container(
          padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0, bottom: 100.0),
          child: new Column(
              children: [ Expanded(child: GridView.count(
                crossAxisCount: 3,
                children: consonantList.asMap().map((index,data) => MapEntry(index, GestureDetector(

                    onTap: (){
                      getGridViewSelectedItem(context, data, index);
                    },
                    child: Container(

                        margin:EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        decoration:BoxDecoration(
                            color: (index/3)%2 < 1 ? Color(0xffD8EFFF) : Color(0xff97D5FE),
                            borderRadius:BorderRadius.all(Radius.circular(15.0))
                        ) ,

                        child: Center(
                          child: Text(
                            data,
                            style: TextStyle(fontSize: 42, color: Color(0xff333333), fontWeight: FontWeight.w900),
                            textAlign: TextAlign.center,
                          ),

                        ))))
                ).values.toList(),
              ),)
              ]),
        ));


  }
}
