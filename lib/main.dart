import 'package:flutter/material.dart';
import './style.dart' as style;
import 'package:http/http.dart' as http;  //http 요청
import 'dart:convert';  //
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'notification .dart';



void main() {
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Store()),

        ],

        child: MaterialApp(
          theme: style.theme,
          home : MyApp(),
        ),
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
  var userImg;
  var userContent;


  saveData() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    storage.setString('key', 'value');
    Map map = {'map' : 'map'};
    storage.setString('map', jsonEncode(map));  //제이슨으로 바꿔줌 String
    String result = storage.getString('map') ?? '없어요';  //데이터 널체크
    print(jsonDecode(result));  //제이슨형식으로 해석해줌
  }

  addMyData() {
    var myData = {
      'id': data.length,
      'image': userImg,
      'likes': 5,
      'date': 'July 25',
      'content': userContent,
      'liked': false,
      'user': 'John Kim'
    };
    setState(() {
      data.insert(0, myData);
    });

    print(data);
  }
  
  setUserContent(a) {
    setState(() {
      userContent = a;
    });
  }

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
    saveData();
    initNotification(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(child: Text('+'),onPressed: (){
        showNotification();
      },),
      appBar: AppBar(
        title: Text('Instagram'),
          actions: [
            IconButton(
                icon: Icon(Icons.add_box_outlined),
                onPressed: () async {
                  // 갤러리에서 이미지 가져오기 셋팅 
                  //안드로이드는 사진첩에 그냥 접근 가능
                  ImagePicker picker = ImagePicker();
                  var img = await picker.pickImage(source: ImageSource.gallery);
                  if(img != null){
                    setState(() {
                      userImg = File(img.path);
                    });
                  }

                  Image.file(userImg);


                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Upload(
                        userImg : userImg,
                        setUserContent : setUserContent,
                        addMyData : addMyData,))
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
                widget.data[i]['image'].runtimeType == String 
                    ? Image.network(widget.data[i]['image'])
                    : Image.file(widget.data[i]['image']),
                Container(
                  constraints: BoxConstraints(maxWidth: 600),
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        child: Text(widget.data[i]['user']),
                        onTap: () {
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                  pageBuilder: (context, a1, a2) => Profile(),
                                  transitionsBuilder: (c, a1, a2, child) =>
                                      FadeTransition(
                                          opacity: a1, child: child)
                              ));
                        },
                      ),
                      Text('좋아요 ${widget.data[i]['likes'].toString()}'),
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

//프로바이더 stroe
class Store extends ChangeNotifier {
  String name = 'test';
  int follower = 0;
  bool friend = false;

  List profileImg = [];

  getProfileImg() async{
    http.Response result = await http.get(Uri.parse('https://codingapple1.github.io/app/profile.json'));
    var res = jsonDecode(result.body);
    profileImg = res;
    notifyListeners();

  }

  addFollower() {
    if(!friend) {
      follower++;
      friend = true;
    } else {
      follower--;
      friend = false;
    }
   notifyListeners();
  }
}

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.watch<Store>().name),),
      body: CustomScrollView(
          
        slivers: [
          SliverToBoxAdapter(
            child: ProfileHeader(),
          ),
          SliverGrid(
          
              delegate: SliverChildBuilderDelegate(
                  (context, i) => Image.network(context.watch<Store>().profileImg[i],),
                  childCount: context.watch<Store>().profileImg.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
          )

        ],
      )
    );
  }
}


class Upload extends StatelessWidget {


  const Upload({Key? key, this.userImg, this.setUserContent, this.addMyData}) : super(key: key);

  final userImg;
  final setUserContent;
  final addMyData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){
            print('asdf');
            addMyData();
          }, icon: Icon(Icons.send))
        ],
      ),
      body: Builder(
        builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Image.file(userImg)),
              Text('이미지업로드화면'),
              TextField(onChanged: (text){
                setUserContent(text);
              },),
              IconButton(onPressed: (){
                Navigator.pop(context);
              }, icon: Icon(Icons.close))
            ],
          );
        }
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey,
        ),
        Text('팔로워 ${context.watch<Store>().follower} 명'),

        ElevatedButton(onPressed: (){
          context.read<Store>().addFollower();
        }, child: Text('팔로우')),
        ElevatedButton(onPressed: (){
          context.read<Store>().getProfileImg();
        }, child: Text('사진가져오기'))
        //Text(context.watch<Store>().follower.toString()),
      ],
    );
  }
}


