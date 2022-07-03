import 'package:android_qr_system/model/attendancemodel.dart';
import 'package:android_qr_system/model/historymodel.dart';
import 'package:android_qr_system/screens/attendancehistory.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:android_qr_system/model/usermodel.dart';
import 'package:android_qr_system/screens/login.dart';
import 'package:intl/intl.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  String qrResult = "";
  String hostID = "";
  String eventName = "";
  String eventAddress = "";
  String timeStamp = "";
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  void initState(){
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 1,
        title: Text("Welcome ${loggedInUser.firstName}"),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: GestureDetector(
                onTap: () {
                  SignOut(context);
                },
                child: Icon(
                  Icons.logout,
                  size: 26,
                  color: Colors.redAccent,
                )
            ),
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(36.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 35),
                      SizedBox(
                        height: 200,
                        child: Image.asset("assets/logo.png",fit: BoxFit.fill),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "My Profile",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text("${loggedInUser.firstName} ${loggedInUser.lastName}",
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      ),
                      Text("${loggedInUser.email}",
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      ),
                      Text("${loggedInUser.phoneNum}",
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(onPressed: () async {
                            ScanResult result = await BarcodeScanner.scan();
                            setState(() {
                              qrResult = result.rawContent;
                              List<String> words = qrResult.split(":");
                              hostID = words[0];
                              eventName = words[1];
                              eventAddress = words[2];

                              String liveTimeStamp = DateFormat("dd MMMM yyyy  |  hh:mm a").format(DateTime.now());
                              timeStamp = liveTimeStamp;
                            });

                            final usersRef = firebaseFirestore
                                .collection('users')
                                .doc(user!.uid)
                                .collection("history")
                                .doc(eventName);

                            usersRef.get()
                                .then((docSnapshot) => {
                                  if (docSnapshot.exists) {
                                    Fluttertoast.showToast(
                                      msg: "Error! Attendance has already scanned for this user!", timeInSecForIosWeb: 5)
                                  }
                                  else {
                                    postAttendanceToFirestore(),
                                    postHistoryToFirestore(),
                                    Fluttertoast.showToast(
                                      msg: "Attendance successfully scanned!", timeInSecForIosWeb: 5)
                                    }
                            });

                          },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 30),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                    Icons.qr_code_2,
                                    size: 70),
                                Text('Scan QR'),
                              ],
                            ),
                          ),
                          SizedBox(width: 15),
                          ElevatedButton(onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AttendanceHistory()));
                          },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 30),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                    Icons.history,
                                    size: 70),
                                Text('History'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //),
          ),
        ),
      ),
    );
  }

  Future<void> SignOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Fluttertoast.showToast(msg: "Signed out successfully!");
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  postAttendanceToFirestore() async {
    //calling firestore
    //calling user model
    //sending the values

    AttendanceModel attendanceModel = AttendanceModel();

    //writing all the values
    attendanceModel.firstName = loggedInUser.firstName;
    attendanceModel.lastName = loggedInUser.lastName;
    attendanceModel.email = loggedInUser.email;
    attendanceModel.phoneNum = loggedInUser.phoneNum;
    attendanceModel.timeStamp = timeStamp;

    await firebaseFirestore
        .collection("users")
        .doc(hostID)
        .collection("events")
        .doc(eventName)
        .collection("attendance")
        .doc(user!.uid)
        .set(attendanceModel.toMap());
  }

  postHistoryToFirestore() async {
    //calling firestore
    //calling user model
    //sending the values

    HistoryModel historyModel = HistoryModel();

    //writing all the values
    historyModel.eventName = eventName;
    historyModel.eventAddress = eventAddress;
    historyModel.timeStamp = timeStamp;

    await firebaseFirestore
        .collection("users")
        .doc(user!.uid)
        .collection("history")
        .doc(eventName)
        .set(historyModel.toMap());
  }
}
