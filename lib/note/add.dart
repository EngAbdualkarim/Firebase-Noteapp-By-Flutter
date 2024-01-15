import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_noteapp/component/custometeformtextfield.dart';
import 'package:firebase_noteapp/note/view.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../component/custombutton.dart';

class AddNote extends StatefulWidget {
  final String docId;
  const AddNote({Key? key, required this.docId}) : super(key: key);

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  TextEditingController note = TextEditingController();
  bool isLoading = false;

  File? file;
  String? url;

  getImageAndUpload() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageCamera =
        await picker.pickImage(source: ImageSource.camera);
    if (imageCamera != null) {
      file = File(imageCamera!.path);
      var imageName = basename(imageCamera!.path);
      var refStorage = FirebaseStorage.instance.ref("images").child(imageName);
      await refStorage.putFile(file!);
      url = await refStorage.getDownloadURL();
    }
    setState(() {});
  }

  addNote(context) async {
    CollectionReference notes = FirebaseFirestore.instance
        .collection("categories")
        .doc(widget.docId)
        .collection("note");
    if (formState.currentState!.validate()) {
      try {
        isLoading = true;
        setState(() {});
        DocumentReference response = await notes
            .add({"note": note.text, "url": url ?? "none"}).catchError(
                (onError) => print("Failed Error is $onError"));
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NoteView(categoryId: widget.docId)));
      } catch (e) {
        isLoading = false;
        setState(() {});
        print("Error is : $e");
      }
    }
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
        title: Text("Add Note"),
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
                  CustomButtonUpload(
                    title: 'Upload Image',
                    onPressed: () async {
                      await getImageAndUpload();
                    },
                    isSelected: url == null ? false : true,
                  ),
                  MaterialButton(
                    height: 40,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Colors.orange,
                    textColor: Colors.white,
                    onPressed: () {
                      addNote(context);
                    },
                    child: Text("Add"),
                  )
                ],
              ),
            ),
    );
  }
}
