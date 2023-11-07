import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_calendar/screen/loading_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

String vals="Null";

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.list, required this.final_events}) : super(key: key);
  final String list;
  final final_events;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<DateTime, List<dynamic>> events = {};
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  List<dynamic> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }
  bool exist_check = false;
  int year = 2023;
  int month = 11;
  int day = 7;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.final_events);
    year = int.parse(selectedDay.toString().substring(0,4));
    month = int.parse(selectedDay.toString().substring(5,7));
    day = int.parse(selectedDay.toString().substring(8,10));
    events = widget.final_events;
    if ( _getEventsForDay(DateTime.utc(year, month, day)).length != 0) {
      exist_check = true;
    }
  }
  @override
  Widget build(BuildContext context) {
    final actionSheet = CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "カメラで撮影",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w200
              ),
            ),
            isDefaultAction: true,
            onPressed: (){
              print("Action 1 Selected");
              setState(() {
                vals="Action 1";
              });
              Navigator.of(context).pop(true);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              "ギャラリーから選択",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w200
              ),
            ),
            isDefaultAction: true,
            onPressed: (){
              print("Action 2 Selected");
              setState(() {
                vals="Action 2";
              });
              Navigator.of(context).pop(false);
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "キャンセル",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w200
            ),
          ),
          onPressed: (){
            print(" cencel was childed");
            setState(() {
              vals="Cencel";
            });
            Navigator.pop(context);
          },
        )
    );
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? isCamera = await showCupertinoModalPopup(context: context, builder: (context)=>actionSheet);
          if (isCamera == null) return;
          XFile? _image; //이미지를 담을 변수 선언
          final ImagePicker picker = ImagePicker();
          var prefs = await SharedPreferences.getInstance();
          try {
            String? decode_event = prefs.getString('events');

            Map<String, dynamic> temp_events = json.decode(decode_event!);
            String utc_year = year.toString();
            String utc_month = month.toString();
            utc_month.length == 1 ? utc_month = '0' + utc_month : utc_month = month.toString();
            String utc_day = day.toString();
            utc_day.length == 1 ? utc_day = '0' + utc_day : utc_day = day.toString();
            String utc_temp = utc_year+utc_month+utc_day;

            final XFile? pickedFile = await picker.pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery);
            if (pickedFile != null) {
              setState(() {
                _image = XFile(pickedFile.path); //가져온 이미지를 _image에 저장
              });
              Uint8List? imageRaw = await _image?.readAsBytes();
              if (imageRaw != null) {
                if (temp_events.containsKey(utc_temp)) {
                  var temp_list = temp_events[utc_temp];
                  temp_list.add(base64Encode(imageRaw));
                  temp_events[utc_temp] = temp_list;
                }
                else {
                  temp_events[utc_temp] = [base64Encode(imageRaw)];
                }
                String encode_event = json.encode(temp_events);
                prefs.setString('events', encode_event);
              }
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
                return LoadingPage();
              }), (route) => false);
            }
          } catch (e) {
            print(e);
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                TableCalendar(
                  locale: "ja_JP",
                  firstDay: DateTime.utc(1900, 1, 1),
                  lastDay: DateTime.utc(2099, 12, 31),
                  focusedDay: focusedDay,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  eventLoader: _getEventsForDay,
                  onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                    setState((){
                      this.selectedDay = selectedDay;
                      this.focusedDay = focusedDay;
                      print(selectedDay);
                      year = int.parse(selectedDay.toString().substring(0,4));
                      month = int.parse(selectedDay.toString().substring(5,7));
                      day = int.parse(selectedDay.toString().substring(8,10));
                      if ( _getEventsForDay(DateTime.utc(year, month, day)).length == 0) {
                        exist_check = false;
                      }
                      else {
                        exist_check = true;
                        print(widget.final_events[DateTime.utc(year, month, day)][0]);
                        print(DateTime.utc(year, month, day));
                      }
                    });
                  },
                  selectedDayPredicate: (DateTime day) {
                    return isSameDay(selectedDay, day);
                  },
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible : false,
                    isTodayHighlighted : false,
                    rangeStartDecoration: BoxDecoration(
                      color : const Color(0xFFF48FB1),
                      shape: BoxShape.circle,
                    ),
                    rangeEndDecoration: BoxDecoration(
                      color: const Color(0xFFF48FB1),
                      shape: BoxShape.circle,
                    ),
                    rangeHighlightColor: const Color(0xFFF48FB1),
                    todayDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration : const BoxDecoration(
                      color: const Color.fromRGBO(163, 122, 68, 109),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                widget.list == 'empty' ? Container() : Container(
                  child: Center(
                    child: Image.memory(
                      base64Decode(widget.list),
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.9,
                    ),
                  ),
                ),
                Container(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width - 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.transparent,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 24,
                          child: Center(
                            child: Text(
                              selectedDay.toString().substring(0,4) + '年' + selectedDay.toString().substring(5,7) + '月' + selectedDay.toString().substring(8,10) + '日',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15,),
                        exist_check == true ? 
                            Container(
                              child: Image.memory(
                                base64Decode(widget.final_events[DateTime.utc(year, month, day)][0]),
                              ),
                            ) : Container(),


                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
