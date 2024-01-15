import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_noteapp/component/custometeformtextfield.dart';
import 'package:firebase_noteapp/note/view.dart';
import 'package:flutter/material.dart';

class EditNote extends StatefulWidget {
  final String noteDocId;
  final String categoryId;
  final String value;
  const EditNote(
      {Key? key,
      required this.noteDocId,
      required this.categoryId,
      required this.value})
      : super(key: key);

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  TextEditingController note = TextEditingController();
  bool isLoading = false;

  editNote() async {
    CollectionReference notes = FirebaseFirestore.instance
        .collection("categories")
        .doc(widget.categoryId)
        .collection("note");
    if (formState.currentState!.validate()) {
      try {
        isLoading = true;
        setState(() {});
        await notes
            .doc(widget.noteDocId)
            .update({"note": note.text}).catchError(
                (onError) => print("Failed Error is $onError"));
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NoteView(categoryId: widget.categoryId)));
      } catch (e) {
        isLoading = false;
        setState(() {});
        print("Error is : $e");
      }
    }
  }

  @override
  void initState() {
    note.text = widget.value;
    super.initState();
  }

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Note"),
      ),
      body: isLoading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: formState,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: CustomTextFormAdd(
                        hintText: "Enter Your note",
                        myController: note,
                        validator: (val) {
                          if (val == "") {
                            return "لايمكن ان يكون فارغ";
                          }
                        }),
                  ),
                  MaterialButton(
                    height: 40,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Colors.orange,
                    textColor: Colors.white,
                    onPressed: () {
                      editNote();
                    },
                    child: Text("Edit"),
                  )
                ],
              ),
            ),
    );
  }
}
