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
    // prefs.clear();
    if (prefs.containsKey('events') == false) {
      Map<String, List<String>> events = {
        // '20230620' : [ 0, 0, 4.5, 202306],
        // '20230621' : [ 0, 0, 4.5, 202306],
        // '20230622' : [ 0, 0, 4.5, 202306 ],
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
