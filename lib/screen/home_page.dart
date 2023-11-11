import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cr_file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_calendar/screen/loading_page.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:io';
import 'dart:typed_data';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.list, required this.final_events, required this.focus_day}) : super(key: key);
  final String list;
  final final_events;
  final focus_day;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _current = 0;
  final CarouselController _controller = CarouselController();
  Map<DateTime, List<dynamic>> events = {};
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  List<dynamic> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }
  List<Widget> img_list = [];
  bool exist_check = false;
  int year = 1999; //초기값
  int month = 12; //초기값
  int day = 31; //초기값
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    int temp_year = int.parse(widget.focus_day.substring(0,4));
    int temp_month = int.parse(widget.focus_day.substring(5,7));
    int temp_day = int.parse(widget.focus_day.substring(8));
    focusedDay = DateTime.utc(temp_year, temp_month, temp_day);
    selectedDay = DateTime.utc(temp_year, temp_month, temp_day);
    //print(widget.final_events);
    year = int.parse(selectedDay.toString().substring(0,4));
    month = int.parse(selectedDay.toString().substring(5,7));
    day = int.parse(selectedDay.toString().substring(8,10));
    events = widget.final_events;
    if ( _getEventsForDay(DateTime.utc(year, month, day)).length != 0) {
      exist_check = true;
      for (int i=0; i<widget.final_events[DateTime.utc(year, month, day)].length; i++) {
        img_list.add(Image.memory(base64Decode(widget.final_events[DateTime.utc(year, month, day)][i])));
      }
    }
  }
  void _showAlert(String title) {
    showCupertinoDialog(context: context, builder: (context) {
      return CupertinoAlertDialog(
        title: Text(title),
        actions: [
          Column(
            children: [
              CupertinoDialogAction(isDefaultAction: true, child: Text("다운로드"), onPressed: () {
                Navigator.pop(context);
              }),
              CupertinoDialogAction(isDefaultAction: true, child: Text("삭제"), onPressed: () {
                Navigator.pop(context);
              })
            ],
          )
        ],
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    final actionSheet = CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "カメラで撮影",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.w200
              ),
            ),
            isDefaultAction: true,
            onPressed: (){
              Navigator.of(context).pop(true);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              "ギャラリーから選択",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.w200
              ),
            ),
            isDefaultAction: true,
            onPressed: (){
              Navigator.of(context).pop(false);
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "キャンセル",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold
            ),
          ),
          onPressed: (){
            Navigator.pop(context);
          },
        )
    );
    final clickPopup = CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "写真をダウンロード",
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w500
              ),
            ),
            isDefaultAction: true,
            onPressed: (){
              Navigator.of(context).pop(true);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              "写真を削除",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500
              ),
            ),
            isDefaultAction: true,
            onPressed: (){
              Navigator.of(context).pop(false);
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "キャンセル",
            style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold
            ),
          ),
          onPressed: (){
            Navigator.pop(context);
          },
        )
    );
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
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
              prefs.setString('focus_day', focusedDay.toString().substring(0,10));
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
                    img_list = [];
                  }
                  else {
                    img_list = [];
                    exist_check = true;
                    print(widget.final_events[DateTime.utc(year, month, day)][0]);
                    print(DateTime.utc(year, month, day));
                    print(widget.final_events[DateTime.utc(year, month, day)].length);
                    for (int i=0; i<widget.final_events[DateTime.utc(year, month, day)].length; i++) {
                      img_list.add(Image.memory(base64Decode(widget.final_events[DateTime.utc(year, month, day)][i])));
                    }
                  }
                });
              },
              selectedDayPredicate: (DateTime day) {
                return isSameDay(selectedDay, day);
              },
              calendarStyle: CalendarStyle(
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
                holidayTextStyle: TextStyle(
                  color: Colors.redAccent
                ),
                weekendTextStyle: TextStyle(
                    color: Colors.redAccent
                ),
                markersMaxCount: 1,
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.transparent,
              ),
              child: Text(
                selectedDay.toString().substring(0,4) + '年' + selectedDay.toString().substring(5,7) + '月' + selectedDay.toString().substring(8,10) + '日',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            exist_check == true ?
            Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CarouselSlider.builder(
                      itemCount: widget.final_events[DateTime.utc(year, month, day)].length,
                      itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
                          InkWell(
                            onTap: () async {
                              // _showAlert(DateTime.utc(year, month, day).toString().substring(0,10) + '날의 ${itemIndex+1}번째 사진');
                              bool? check = await showCupertinoModalPopup(context: context, builder: (context)=>clickPopup);
                              if (check == null) return;
                              else if (check == true) {
                                print('download');
                                var uint = base64Decode(widget.final_events[DateTime.utc(year, month, day)][itemIndex]);
                                Directory appDocDirectory = await getApplicationDocumentsDirectory();
                                //File(appDocDirectory.path+'my_image.jpg').writeAsBytes(base64Decode(widget.final_events[DateTime.utc(year, month, day)][itemIndex]));
                                final tempdir = await getTemporaryDirectory();
                                //File file = await File('${tempdir.path}/image.png').create();
                                //File('my_image.jpg').writeAsBytes(uint);
                                // final result = await ImageGallerySaver.saveImage(
                                //     Uint8List.fromList(uint),
                                //     quality: 100,
                                //     name: "${DateTime.now()}"
                                // );
                                final downdir = await getExternalStorageDirectory();
                                final _directory = await getDownloadsDirectory();

                                //안드로이드 SDK 30 미만용 코드
                                //사진을 쓰기 권한을 이용하여 Download 폴더에 저장
                                /*
                                File(appDocDirectory.path + '/' + '${DateTime.now()}.jpg').writeAsBytes(uint);
                                print('try save');
                                File('/storage/emulated/0/Download/' + '${DateTime.now()}.jpg').writeAsBytes(uint);
                                print('save complete');
                                 */

                                //최신 SDK 전용 코드
                                //쓰기 권한을 얻을 수 없으므로 App 내부 폴더에 임시로 사진을 저장후
                                //이를 복사하는 방식으로 사진을 저장함. 저장후 임시 사진은 삭제
                                var temp_name = appDocDirectory.path + '/' + '${DateTime.now()}.jpg';
                                File(temp_name).writeAsBytes(uint).then((value) async { //App폴더에 사진을 임시 저장후
                                  print(value);
                                  print('start');
                                  final file = await CRFileSaver.saveFileWithDialog(
                                    SaveFileDialogParams(
                                        sourceFilePath: temp_name, //App폴더에 저장한 임시 사진을 Source로 이용
                                        destinationFileName: '${DateTime.now()}.jpg'
                                    ),
                                  ).then((value2) {
                                    print(value2);
                                    File(temp_name).delete();
                                    //App폴더안에 임시 저장한 사진 삭제
                                  });
                                  print('end process');
                                });
                              }
                              else {
                                var prefs = await SharedPreferences.getInstance();
                                print('delete');
                                String? decode_event = prefs.getString('events');
                                Map<String, dynamic> temp_events = json.decode(decode_event!);
                                String utc_year = year.toString();
                                String utc_month = month.toString();
                                utc_month.length == 1 ? utc_month = '0' + utc_month : utc_month = month.toString();
                                String utc_day = day.toString();
                                utc_day.length == 1 ? utc_day = '0' + utc_day : utc_day = day.toString();
                                String utc_temp = utc_year+utc_month+utc_day;
                                var temp_list = temp_events[utc_temp];
                                temp_list.removeAt(itemIndex);
                                temp_events[utc_temp] = temp_list;
                                String encode_event = json.encode(temp_events);
                                prefs.setString('events', encode_event);
                                prefs.setString('focus_day', focusedDay.toString().substring(0,10));
                                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
                                  return LoadingPage();
                                }), (route) => false);
                              }
                            },
                            child: Image.memory(
                              base64Decode(widget.final_events[DateTime.utc(year, month, day)][itemIndex]),
                            ),
                          ),
                      options: CarouselOptions(
                          height: MediaQuery.of(context).size.height*0.35,
                          aspectRatio: 16/9,
                          viewportFraction: 0.8,
                          initialPage: 0,
                          enableInfiniteScroll: false,
                          reverse: false,
                          autoPlay: false,
                          enlargeCenterPage: true,
                          enlargeFactor: 0.3,
                          scrollDirection: Axis.horizontal,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _current = index;
                            });
                          }),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: img_list.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () => _controller.animateToPage(entry.key),
                          child: Container(
                            width: 12.0,
                            height: 12.0,
                            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black)
                                    .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                )
              // Image.memory(
              //   base64Decode(widget.final_events[DateTime.utc(year, month, day)][0]),
              // ),
            ) : Container(),
          ],
        ),
      ),
    );
  }
}
