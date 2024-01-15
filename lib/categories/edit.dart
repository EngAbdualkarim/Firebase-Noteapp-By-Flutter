import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_noteapp/component/custometeformtextfield.dart';
import 'package:flutter/material.dart';

class EditCategory extends StatefulWidget {
  final String dicId;
  final String oldName;
  const EditCategory({Key? key, required this.dicId, required this.oldName})
      : super(key: key);

  @override
  State<EditCategory> createState() => _EditCategoryState();
}

class _EditCategoryState extends State<EditCategory> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  bool isLoading = false;

  CollectionReference categories =
      FirebaseFirestore.instance.collection("categories");

  editCtegory() async {
    if (formState.currentState!.validate()) {
      try {
        isLoading = true;
        setState(() {});
        await categories.doc(widget.dicId).update({"name": name.text});
        Navigator.of(context)
            .pushNamedAndRemoveUntil("homepage", (route) => false);
      } catch (e) {
        isLoading = false;
        setState(() {});
        print("Error is : $e");
      }
    }
  }

  @override
  void initState() {
    name.text = widget.oldName;
    super.initState();
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Category"),
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
                        hintText: "Enter name",
                        myController: name,
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
                      editCtegory();
                    },
                    child: Text("Save"),
                  )
                ],
              ),
            ),
    );
  }
}
