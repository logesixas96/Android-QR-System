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
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  String qrResult = "";
  String hostID = "";
  String eventName = "";
  String eventAddress = "";

  get timeStamp => DateFormat('dd MMMM yyyy hh:mm a');

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection("users").doc(user!.uid).get().then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 1,
        title: Text("Welcome ${loggedInUser.firstName}!"),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                signOut(context);
              },
              child: const Icon(Icons.logout, size: 26, color: Colors.redAccent),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/bg.png"), fit: BoxFit.fill),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(36.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 35),
                      SizedBox(
                        height: 200,
                        child: Image.asset("assets/logo.png", fit: BoxFit.fill),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "My Profile",
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "${loggedInUser.firstName} ${loggedInUser.lastName}",
                        style: const TextStyle(
                            color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 20),
                      ),
                      Text(
                        "${loggedInUser.email}",
                        style: const TextStyle(
                            color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 20),
                      ),
                      Text(
                        "${loggedInUser.phoneNum}",
                        style: const TextStyle(
                            color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 20),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: () async {
                              ScanResult result = await BarcodeScanner.scan();
                              setState(() {
                                qrResult = result.rawContent;
                                List<String> words = qrResult.split(":");
                                hostID = words[0];
                                eventName = words[1];
                                eventAddress = words[2];
                              });
                              final usersRef = firebaseFirestore
                                  .collection('users')
                                  .doc(user!.uid)
                                  .collection("history")
                                  .doc(qrResult);
                              final hostRef = firebaseFirestore
                                  .collection('users')
                                  .doc(hostID)
                                  .collection("events")
                                  .doc(qrResult)
                                  .collection("attendance")
                                  .doc(user!.uid);
                              usersRef.get().then((docSnapshot) => {
                                    hostRef.get().then((docSnapshot) => {
                                          if (docSnapshot.exists)
                                            {
                                              Fluttertoast.showToast(
                                                  msg:
                                                      "Error! Attendance has already scanned for this user!",
                                                  toastLength: Toast.LENGTH_LONG)
                                            }
                                          else
                                            {
                                              postAttendanceToFirestore(),
                                              postHistoryToFirestore(),
                                              Fluttertoast.showToast(
                                                  msg: "Attendance successfully scanned!",
                                                  toastLength: Toast.LENGTH_LONG)
                                            }
                                        }),
                                  });
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const <Widget>[
                                Icon(Icons.qr_code_2, size: 70),
                                Text('Scan QR')
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AttendanceHistory()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const <Widget>[
                                Icon(Icons.history, size: 70),
                                Text('History')
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
          ),
        ),
      ),
    );
  }

  Future<void> signOut(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });
    await FirebaseAuth.instance.signOut();
    Fluttertoast.showToast(msg: "Signed out successfully!");
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  postAttendanceToFirestore() async {
    DateTime convertedDateTime = DateTime.now();
    AttendanceModel attendanceModel = AttendanceModel();
    attendanceModel.firstName = loggedInUser.firstName;
    attendanceModel.lastName = loggedInUser.lastName;
    attendanceModel.email = loggedInUser.email;
    attendanceModel.phoneNum = loggedInUser.phoneNum;
    attendanceModel.timeStamp = convertedDateTime;
    await firebaseFirestore
        .collection("users")
        .doc(hostID)
        .collection("events")
        .doc(qrResult)
        .collection("attendance")
        .doc(user!.uid)
        .set(attendanceModel.toMap());
  }

  postHistoryToFirestore() async {
    DateTime convertedDateTime = DateTime.now();
    HistoryModel historyModel = HistoryModel();
    historyModel.eventName = eventName;
    historyModel.eventAddress = eventAddress;
    historyModel.timeStamp = convertedDateTime;
    await firebaseFirestore
        .collection("users")
        .doc(user!.uid)
        .collection("history")
        .doc(qrResult)
        .set(historyModel.toMap());
  }
}
