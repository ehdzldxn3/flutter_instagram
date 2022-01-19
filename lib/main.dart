import 'package:flutter/material.dart';
import './style.dart' as style;
import 'package:http/http.dart' as http;  //http 요청
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  addData(a) {
    setState(() {
      data.add(a);
      print(data);
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
                onPressed: () async {
                  // 갤러리에서 이미지 가져오기 셋팅
                  ImagePicker picker = ImagePicker();
                  var image = await picker.pickImage(source: ImageSource.gallery);

                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Upload())
                  );
                },
                iconSize: 30,
            )
          ]
      ),
      body: [ Home(data : data, addData : addData), Text('샵페이지')][tab],
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

class Home extends StatefulWidget {
  const Home({Key? key, this.data, this.addData}) : super(key: key);
  //부모가 보내준 데이터는 수정하지 않는다
  final data;
  final addData;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  ScrollController scroll = ScrollController();

  getMore() async {
    var result = await http.get(Uri.parse('https://codingapple1.github.io/app/more1.json'));
    var result2 = jsonDecode(result.body);
    widget.addData(result2);
  }

  @override
  void initState() {
    super.initState();
    //높이 측정할때 사용하는 리스너
    scroll.addListener(() {
      //scroll.position.pixels 스크롤한 거리
      //scroll.position.maxScrollExtent 스크롤의 최대 크기
      if(scroll.position.pixels == scroll.position.maxScrollExtent) {
        getMore();
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    if(widget.data.isNotEmpty){
      return ListView.builder(
          controller: scroll,
          //부모한테 받아온 data
          itemCount: widget.data.length,
          itemBuilder: (c, i) {
            return Column(
              children: [
                //웹상에서 가져온 이미지
                Image.network(widget.data[i]['image']),
                Container(
                  constraints: BoxConstraints(maxWidth: 600),
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('좋아요 ${widget.data[i]['likes'].toString()}'),
                      Text(widget.data[i]['user']),
                      Text(widget.data[i]['content']),
                    ],
                  ),
                )
              ],
            );
          });
    } else {
      return CircularProgressIndicator();
    }
  }
}

class Upload extends StatelessWidget {
  const Upload({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){
            Navigator.pop(context);
          }, icon: Icon(Icons.close))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('data'),
        ],
      ),
    );
  }
}




