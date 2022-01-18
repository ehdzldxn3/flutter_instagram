import 'package:flutter/material.dart';
import './style.dart' as style;
import 'package:http/http.dart' as http;  //http 요청
import 'dart:convert';

void main() {
  runApp(
      MaterialApp(
        theme: style.theme,
        home : MyApp(),
      )
  );
}



class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  int tab = 0;
  List data = [];
  getData() async{
    //DIO 알아오기
    //get 요청
    var get = await http.get(Uri.parse('https://codingapple1.github.io/app/data.json'));
    setState(() {
      //json 파싱
      var res = jsonDecode(get.body);
      data = res;
    });
  }
  
  //위젯이 처음 실행될떄 실행하는 함수 
  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Instagram'),
          actions: [
            IconButton(
                icon: Icon(Icons.add_box_outlined),
                onPressed: (){},
                iconSize: 30,
            )
          ]
      ),
      body: [ Home(data : data), Text('샵페이지')][tab],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (i) {
            setState(() {
              tab = i;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'HOME'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'SHOP'),
          ],
      )
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key, this.data}) : super(key: key);
  //부모가 보내준 데이터는 수정하지 않는다
  final data;
  
  @override
  Widget build(BuildContext context) {
    if(data.isNotEmpty){
      return ListView.builder(
          itemCount: 3,
          itemBuilder: (c, i) {
            return Column(
              children: [
                //웹상에서 가져온 이미지
                Image.network(data[i]['image']),
                Container(
                  constraints: BoxConstraints(maxWidth: 600),
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data[i]['likes'].toString()),
                      Text(data[i]['user']),
                      Text(data[i]['content']),
                    ],
                  ),
                )
              ],
            );
          });
    } else {
      return CircularProgressIndicator();
      prit
    }

  }
}
