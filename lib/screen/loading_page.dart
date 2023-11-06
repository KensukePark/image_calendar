import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen/home_page.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);
  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  List<List<num>> statics_list = [];
  Map<String, dynamic> load_events = {};
  void check_data() async {
    var prefs = await SharedPreferences.getInstance();
    //prefs.clear();
    if (prefs.containsKey('events') == false) {
      Map<String, List<num>> events = {
        '20230620' : [ 0, 0, 4.5, 202306],
        '20230621' : [ 0, 0, 4.5, 202306],
        '20230622' : [ 0, 0, 4.5, 202306 ],
        '20230628' : [ 0, 0, 4.5, 202306 ],
        '20230629' : [ 0, 0, 4.5, 202306 ],
        '20230630' : [ 0, 0, 6, 202306 ],
        '20230701' : [ 0, 0, 5, 202307],
        '20230702' : [ 0, 0, 9, 202307],
        '20230704' : [ 0, 0, 3, 202307],
        '20230705' : [ 0, 0, 4.5, 202307],
        '20230708' : [ 0, 0, 9, 202307],
        '20230709' : [ 17, 2, 0, 202307],
        '20230711' : [ 2, 19, 0, 202307],
        '20230713' : [ 0, 0, 9.5, 202307],
        '20230715' : [ 11, 6, 0, 202307],
        '20230716' : [ 13, 4, 0, 202307],
        '20230718' : [ 15, 5, 0, 202307],
        '20230719' : [ 16, 0, 0, 202307],
        '20230721' : [ 10, 3, 0, 202307],
        '20230722' : [ 16, 0, 0, 202307],
        '20230724' : [ 15, 0, 0, 202307],
        '20230727' : [ 18, 1, 0, 202307],
        '20230803' : [ 10, 0, 0, 202308 ],
        '20230805' : [ 15, 3, 0, 202308 ],
        '20230806' : [ 17, 2, 0, 202308 ],
        '20230808' : [ 15, 5, 0, 202308 ],
        '20230809' : [ 11, 0, 0, 202308 ],
        '20230810' : [ 6, 6, 0, 202308 ],
        '20230811' : [ 13, 1, 0, 202308],
        '20230813' : [ 16, 5, 0, 202308 ],
        '20230814' : [ 21.5, 8, 0, 202308 ],
        '20230816' : [ 20, 1, 0 , 202308],
        '20230817' : [ 13, 3, 0 , 202308],
        '20230819' : [ 12, 3, 0 , 202308],
        '20230821' : [ 9, 9 , 0, 202308],
        '20230822' : [ 12, 12, 0 , 202308],
        '20230825' : [ 11, 6, 0 , 202308],
        '20230827' : [ 18, 1, 0 , 202308],
        '20230828' : [ 10, 2, 0 , 202308],
        '20230831' : [ 13.5, 5, 0 , 202308],
        '20230902' : [ 5, 2, 0, 202309],
        '20230903' : [ 16, 3, 0, 202309],
        '20230906' : [ 10, 10, 0, 202309],
        '20230907' : [ 14, 13, 0, 202309],
        '20230908' : [ 14, 14, 0, 202309],
        '20230910' : [ 17, 3, 0, 202309],
        '20230911' : [ 15, 6, 0, 202309],
        '20230913' : [ 8, 13, 0, 202309],
        '20230915' : [ 10, 19, 0, 202309],
        '20230916' : [ 28, 7, 0, 202309],
        '20230917' : [ 14, 2, 0, 202309],
        '20230926' : [ 14, 5, 0, 202309],
        '20230927' : [ 18, 0, 0, 202309],
        '20230928' : [ 14, 11, 0, 202309],
        '20230930' : [ 22, 15, 0, 202309],
        '20231002' : [ 18, 9, 0, 202310],
        '20231003' : [ 15, 8, 0, 202310],
        '20231005' : [ 18, 12, 0, 202310],
      };
      String encode_event = json.encode(events);
      //print(encode_event);
      prefs.setString('events', encode_event);
    }
    String? decode_event = prefs.getString('events');
    load_events = json.decode(decode_event!);
    var temp_list = load_events.values.toList();
    for (int i=0; i<temp_list.length; i++) {
      if (statics_list.length == 0) {
        statics_list.add([temp_list[i][3].toInt(), 1,
          (temp_list[i][0]*650+temp_list[i][1]*160+temp_list[i][2]*1100).toInt()]);
      }
      else {
        bool check_add = false;
        for (int j=0; j<statics_list.length; j++) {
          if (statics_list[j][0] == temp_list[i][3].toInt()) {
            statics_list[j][1]++;
            statics_list[j][2]+= (temp_list[i][0]*650+temp_list[i][1]*160+temp_list[i][2]*1100).toInt();
            check_add = true;
            break;
          }
        }
        if (check_add == false) {
          statics_list.add([temp_list[i][3].toInt(), 1,
            (temp_list[i][0]*650+temp_list[i][1]*160+temp_list[i][2]*1100).toInt()]);
        }
        print(statics_list);
      }
    }
    var key_list = load_events.keys.toList();
    Map<DateTime, List<dynamic>> final_events = {};
    for (int i=0; i<key_list.length; i++) {
      int temp_year = int.parse(key_list[i].substring(0,4));
      int temp_month = int.parse(key_list[i].substring(4,6));
      int temp_day = int.parse(key_list[i].substring(6));
      final_events[DateTime.utc(temp_year, temp_month, temp_day)] = load_events[key_list[i]];
    }
    String? img = prefs.getString('img');
    if (img != null) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
        return HomePage(list: img);
      }), (route) => false);
    }
    else {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
        return HomePage(list: 'empty');
      }), (route) => false);
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    check_data();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     fit: BoxFit.cover,
        //     image: AssetImage('assets/images/chunsik_bg_3.jpg'), // 배경 이미지
        //     colorFilter: ColorFilter.mode(
        //         Colors.black.withOpacity(0.3), BlendMode.dstATop),
        //   ),
        // ),
      ),
    );
  }
}
