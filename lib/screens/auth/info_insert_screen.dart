import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modu_messenger_firebase/models/user_model.dart';
import 'package:modu_messenger_firebase/screens/home_screen.dart';

import '../../api/user_apis.dart';
import '../../main.dart';

// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃                             기본정보 입력화면                              ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
class InfoInsertScreen extends StatefulWidget {
  const InfoInsertScreen({super.key});

  @override
  State<InfoInsertScreen> createState() => _InfoInsertScreenState();
}

class _InfoInsertScreenState extends State<InfoInsertScreen> {
  // 성별 선택
  int _selectedGender = 0;

  // 생일 선택
  DateTime _selectedDate = DateTime.now();

  // 기분 선택
  String _selectedMood = '';

  // ios 날짜 선택 UI
  void _showCupertinoDatePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery
                .of(context)
                .copyWith()
                .size
                .height / 3,
            child: CupertinoDatePicker(
              initialDateTime: _selectedDate,
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (DateTime newDate) {
                setState(() {
                  _selectedDate = newDate;
                });
              },
            ),
          );
        });
  }

  // 기분 선택 다이얼로그
  void _showMoodDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Mood'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _moodOption('Happy'),
                _moodOption('Sad'),
                _moodOption('Excited'),
                _moodOption('Angry'),
                _moodOption('Relaxed'),
                _moodOption('Nervous'),
              ],
            ),
          ),
        );
      },
    );
  }

  // 기분 선택 다이얼로그 리스트 UI
  Widget _moodOption(String mood) {
    return ListTile(
      title: Text(mood),
      onTap: () {
        setState(() {
          _selectedMood = mood;
        });
        Navigator.of(context).pop();
      },
    );
  }

  // 라디오 버튼 UI
  Widget _buildCustomRadioButton(int value, String text, String gender) {
    bool isSelected = _selectedGender == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: isSelected
              ? gender == 'M'
              ? Colors.blue
              : Colors.pink
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // ┏━━━━━━━━━━━━━━━┓
  // ┃   initState   ┃
  // ┗━━━━━━━━━━━━━━━┛
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(56, 56, 60, 1), // LoginScreen backgroundColor
        // ┏━━━━━━━━┓
        // ┃  Body  ┃
        // ┗━━━━━━━━┛
        body: SizedBox(
          width: mq.width,
          height: mq.height,
          // 화면 요소
          child: Column(
            children: [
              // 타이틀 위쪽 여백
              SizedBox(
                width: mq.width,
                height: mq.height * .2,
              ),
              // 타이틀 박스
              SizedBox(
                height: mq.height * .1,
                child: const Text(
                  "사용자 정보 입력 화면 (아직 저장은 안됨)",
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
              ),
              // ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
              // ┃  Body - 성별 선택 RADIO   ┃
              // ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
              SizedBox(
                height: mq.height * .05,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildCustomRadioButton(0, '남자', 'M'),
                    SizedBox(width: 10),
                    _buildCustomRadioButton(1, '여자', 'G'),
                  ],
                ),
              ),
              // ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
              // ┃  Body - 생일 선택         ┃
              // ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
              SizedBox(
                height: mq.height * .15,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => _showCupertinoDatePicker(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: const Text(
                          'Select Date',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      'Selected Date: ${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}',
                      style: const TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
              // ┃  Body - 기분 선택         ┃
              // ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
              SizedBox(
                height: mq.height * .15,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: _showMoodDialog,
                      child: Text('Select Mood'),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Selected Mood: $_selectedMood',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // ┏━━━━━━━━━━━━━━━━━━━━━┓
              // ┃  Body - 저장 버튼   ┃
              // ┗━━━━━━━━━━━━━━━━━━━━━┛
              SizedBox(
                  width: mq.width * 0.9,
                  height: mq.height * 0.06,
                  child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Btn-BackgroundColor
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))), // Btn-Shape
                      ),
                      onPressed: () {
                        ModuUser user = ModuUser(image: '',
                            gender: _selectedGender == 0 ? 'M' : 'G',
                            birthDay: '',
                            theme: '',
                            emotionMsg: '',
                            introduce: '',
                            name: '',
                            createdAt: '',
                            isOnline: false,
                            id: '',
                            lastActive: '',
                            email: '',
                            isDefaultInfoSet: true,
                            pushToken: '');

                        UserAPIs.updateUserDefaultInfo(user);

                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                      },
                      // LoginBtn-Element
                      label: RichText(
                        text: const TextSpan(style: TextStyle(color: Colors.black, fontSize: 16), children: [
                          TextSpan(text: '저장 '),
                        ]),
                      )))
            ],
          ),
        ));
  }
}
