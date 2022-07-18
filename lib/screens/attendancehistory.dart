import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceHistory extends StatefulWidget {
  const AttendanceHistory({Key? key}) : super(key: key);

  @override
  State<AttendanceHistory> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  get timeStamp => DateFormat('dd MMMM yyyy hh:mm a');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 1,
          title: const Text("My Attendance"),
          centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/bg.png"), fit: BoxFit.fill),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
              child: StreamBuilder<QuerySnapshot>(
                  stream: firebaseFirestore
                      .collection("users")
                      .doc(user!.uid)
                      .collection("history")
                      .orderBy('timeStamp')
                      .snapshots(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView.separated(
                        padding: const EdgeInsets.all(10.0),
                        physics: const BouncingScrollPhysics(),
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot event = snapshot.data.docs[index];
                          return Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: index.isEven
                                      ? Colors.red.shade900.withOpacity(.5)
                                      : Colors.red.shade300.withOpacity(.5),
                                  blurRadius: 10.0,
                                  spreadRadius: 0.0,
                                  offset: const Offset(5.0, 5.0),
                                ),
                              ],
                            ),
                            child: Card(
                              child: ListTile(
                                leading: Icon(Icons.event,
                                    size: 30,
                                    color:
                                        index.isEven ? Colors.red.shade900 : Colors.red.shade300),
                                title: Text(event['eventName'] + "@" + event['eventAddress']),
                                subtitle: Text(
                                  timeStamp.format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        (event['timeStamp']).millisecondsSinceEpoch),
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                  }),
            ),
          ),
        ),
      ),
    );
  }
}
