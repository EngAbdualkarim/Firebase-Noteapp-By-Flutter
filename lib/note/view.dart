import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_noteapp/auth/login.dart';
import 'package:firebase_noteapp/categories/edit.dart';
import 'package:firebase_noteapp/note/add.dart';
import 'package:firebase_noteapp/note/edit.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class NoteView extends StatefulWidget {
  final String categoryId;
  const NoteView({Key? key, required this.categoryId}) : super(key: key);

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  List<QueryDocumentSnapshot> data = [];
  bool isLoading = true;

  getData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("categories")
        .doc(widget.categoryId)
        .collection("note")
        .get();
    data.addAll(querySnapshot.docs);
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange,
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddNote(docId: widget.categoryId)));
          },
          child: Icon(Icons.add),
        ),
        appBar: AppBar(
          title: Text('Note'),
          actions: [
            IconButton(
                onPressed: () async {
                  GoogleSignIn googleSignin = GoogleSignIn();
                  googleSignin.disconnect();
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil("login", (route) => false);
                },
                icon: Icon(Icons.exit_to_app))
          ],
        ),
        body: WillPopScope(
          onWillPop: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil("homepage", (route) => false);
            return Future.value(false);
          },
          child: isLoading == true
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : GridView.builder(
                  itemCount: data.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisExtent: 160),
                  itemBuilder: (context, i) {
                    return InkWell(
                      onLongPress: () {
                        AwesomeDialog(
                            context: context,
                            dialogType: DialogType.warning,
                            animType: AnimType.rightSlide,
                            title: 'Message',
                            desc: 'اختر ماذا تريد عملة',
                            btnCancelText: 'حذف',
                            btnOkText: "تعديل",
                            btnOkOnPress: () async {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => EditNote(
                                      noteDocId: data[i].id,
                                      categoryId: widget.categoryId,
                                      value: data[i]['note'])));
                            },
                            btnCancelOnPress: () async {
                              await FirebaseFirestore.instance
                                  .collection("categories")
                                  .doc(widget.categoryId)
                                  .collection("note")
                                  .doc(data[i].id)
                                  .delete();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      NoteView(categoryId: widget.categoryId)));

                              //Delete Image for Note
                              if (data[i]['note'] != "none") {
                                await FirebaseStorage.instance
                                    .refFromURL(data[i]['url'])
                                    .delete();
                              }
                              print("Ok");
                            }).show();
                      },
                      child: Card(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Column(children: [
                            Text("${data[i]['note']}"),
                            SizedBox(
                              height: 10,
                            ),
                            if (data[i]['note'] != "none")
                              Image.network(
                                data[i]['url'],
                                height: 80,
                              ),
                          ]),
                        ),
                      ),
                    );
                  },
                ),
        ));
  }
}
