import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modu_messenger_firebase/helper/custom_dialogs.dart';
import 'package:modu_messenger_firebase/screens/home_screen.dart';

import '../../api/apis.dart';
import '../../main.dart';

// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃                                로그인 화면                                 ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
class InfoInsertScreen extends StatefulWidget {
  const InfoInsertScreen({super.key});

  @override
  State<InfoInsertScreen> createState() => _InfoInsertScreenState();
}

class _InfoInsertScreenState extends State<InfoInsertScreen> {
  // ┏━━━━━━━━━━━━━━━┓
  // ┃   initState   ┃
  // ┗━━━━━━━━━━━━━━━┛
  @override
  void initState() {
    super.initState();
  }

  int _selectedValue = 0;

  DateTime _selectedDate = DateTime.now();

  void _showCupertinoDatePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height / 3,
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
        }
    );
  }

  String _selectedMood = 'No mood selected';

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
              // 공백 박스
              SizedBox(
                height: mq.height * .1,
                child: Text("사용자 정보 입력 화면 (아직 저장은 안됨)", style: TextStyle(color: Colors.white, fontSize: 30),),
              ),
              SizedBox(
                height: mq.height * .05,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildCustomRadioButton1(0, '남자'),
                    SizedBox(width: 10),
                    _buildCustomRadioButton2(1, '여자'),
                  ],
                ),
              ),
              SizedBox(
                height: mq.height * .15,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => _showCupertinoDatePicker(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          'Select Date',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Selected Date: ${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}',
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                  ],
                ),
              ),
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
              // ┃  Body - LoginBtn    ┃
              // ┗━━━━━━━━━━━━━━━━━━━━━┛
              SizedBox(
                  width: mq.width * 0.9,
                  height: mq.height * 0.06,
                  child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Btn-BackgroundColor
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15))), // Btn-Shape
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                            context, MaterialPageRoute(builder: (_) => HomeScreen()));
                      },
                      // LoginBtn-Element
                      label: RichText(
                        text: const TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 16),
                            children: [
                              TextSpan(text: '저장 '),
                            ]),
                      )))
            ],
          ),
        ));
  }
  Widget _buildCustomRadioButton1(int value, String text) {
    bool isSelected = _selectedValue == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedValue = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
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
  Widget _buildCustomRadioButton2(int value, String text) {
    bool isSelected = _selectedValue == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedValue = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.grey[200],
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: isSelected ? Colors.red : Colors.grey),
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
}
