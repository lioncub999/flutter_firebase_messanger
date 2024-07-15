import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modu_messenger_firebase/helper/custom_dialogs.dart';
import 'package:modu_messenger_firebase/screens/auth/login_screen.dart';
import 'package:permission_handler/permission_handler.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});

  final ChatUser user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  XFile? _image; // 이미지를 담을 변수 선언
  final ImagePicker _picker = ImagePicker();

  setXfile(image) {
    setState(() {
      _image = image;
    });
  }

  // TODO: 사진 권한 허용
  Future<void> _requestPhotoPermission() async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
    }
    if (status.isGranted) {
      //사진첩 접근 권한 허용됨
      _pickImage(); // 권한이 허용된 경우 이미지 선택 함수 호출
    } else if (status.isDenied) {
      //사진첩 접근 권한 거부됨
    } else if (status.isPermanentlyDenied) {
      //사진첩 접근 권한 영구적으로 거부됨
      _showPermissionDialog();
    }
  }

  // TODO: 사진첩 에서 사진 선택
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // 파일을 선택한 경우
      setState(() {
        _image = pickedFile;
      });

      CustomDialogs.showProgressBar(context);
      await APIs.updateProfilePicture(File(_image!.path));
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  // TODO: 사진 접근 권한 허용 알림
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('권한 필요'),
        content: Text('권한이 필요합니다. 설정에서 권한을 허용해주세요.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            child: Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  // TODO: 카메라 권한 허용
  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    print(status);
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    if (status.isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        CustomDialogs.showProgressBar(context);
        // 파일을 선택한 경우
        setState(() {
          _image = pickedFile;
        });
        await APIs.updateProfilePicture(File(_image!.path));
      }
      Navigator.pop(context);
    } else if (status.isDenied) {
    } else if (status.isPermanentlyDenied) {
      //사진첩 접근 권한 영구적으로 거부됨
      _showPermissionDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Screen"),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              CustomDialogs.showProgressBar(context);

              await APIs.updateActiveStatus(false);

              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => LoginScreen()));

                  APIs.auth = FirebaseAuth.instance;
                });
              });
            },
            icon: const Icon(
              Icons.add_comment,
              color: Colors.white,
            ),
            label: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            )),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  Stack(children: [
                    _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(mq.height * .1),
                            child: Image.file(
                              File(_image!.path),
                              width: mq.height * .2,
                              height: mq.height * .2,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(mq.width * .3),
                            child: CachedNetworkImage(
                              width: mq.height * .2,
                              height: mq.height * .2,
                              fit: BoxFit.cover,
                              imageUrl: widget.user.image,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: MaterialButton(
                        elevation: 1,
                        onPressed: () {
                          _showBottomSheet();
                        },
                        shape: CircleBorder(),
                        child: Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                        color: Colors.white,
                      ),
                    )
                  ]),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  Text(
                    widget.user.email,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : "Required Field",
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'NAME',
                        label: const Text("Name")),
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : "Required Field",
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'about',
                        label: const Text("About")),
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: StadiumBorder(),
                          minimumSize: Size(mq.width * .4, mq.height * .06)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          APIs.updateUserInfo().then((value) {
                            CustomDialogs.showSnackbar(
                                context, 'Profile Updated SuccessFully!');
                          });
                        }
                      },
                      icon: Icon(
                        Icons.edit,
                        size: 28,
                        color: Colors.white,
                      ),
                      label: Text(
                        "UPDATE",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
                top: mq.height * 0.03, bottom: mq.height * 0.05),
            children: [
              Text(
                "Pick Profile Picture",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () async {
                      _requestPhotoPermission();
                    },
                    icon: Icon(
                      Icons.add_photo_alternate,
                      size: 100,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        _requestCameraPermission();
                      },
                      icon: Icon(
                        Icons.camera_enhance,
                        size: 100,
                      ))
                ],
              )
            ],
          );
        });
  }
}
