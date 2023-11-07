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
  const HomePage({Key? key, required this.list}) : super(key: key);
  final String list;

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
            final XFile? pickedFile = await picker.pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery);
            if (pickedFile != null) {
              setState(() {
                _image = XFile(pickedFile.path); //가져온 이미지를 _image에 저장
              });
              Uint8List? imageRaw = await _image?.readAsBytes();
              if (imageRaw != null) {
                List<String>? temp = prefs.getStringList(DateFormat('yyyyMMdd').format(focusedDay));
                if (temp == null) {
                  prefs.setStringList(DateFormat('yyyyMMdd').format(focusedDay), [base64Encode(imageRaw)]);
                }
                else {
                  temp.add(base64Encode(imageRaw));
                  prefs.setStringList(DateFormat('yyyyMMdd').format(focusedDay), temp);
                }
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
                    markerSizeScale : 0.7,
                    markersMaxCount: 1,
                    markerDecoration : const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/chunsik_icon.png'),
                        )
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
