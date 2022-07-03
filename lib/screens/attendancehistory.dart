import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AttendanceHistory extends StatefulWidget {
  const AttendanceHistory({Key? key}) : super(key: key);

  @override
  State<AttendanceHistory> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("My Attendance"),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: firebaseFirestore
              .collection("users")
              .doc(user!.uid)
              .collection("history")
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
                return ListView.separated(
                  padding: EdgeInsets.all(10.0),
                  physics: BouncingScrollPhysics(),
                  separatorBuilder: (context, index) => SizedBox(height: 10),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot event = snapshot.data.docs[index];
                    return Container(
                      decoration: new BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: index.isEven? Colors.red.shade900.withOpacity(.5):Colors.red.shade300.withOpacity(.5),
                                blurRadius: 10.0,
                                spreadRadius: 0.0,
                                offset: Offset(5.0, 5.0,
                                )
                            ),
                          ]
                      ),
                      child: Card(
                        child: ListTile(
                          leading: Icon(Icons.event, size: 30, color: index.isEven? Colors.red.shade900:Colors.red.shade300),
                          title: Text(
                              event['eventName'] + ", " + event['eventAddress']),
                          subtitle: Text(event['timeStamp']),

                        ),

                      ),
                    );
                  },
                );
              }
      ),
    );
  }
}
