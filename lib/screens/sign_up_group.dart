import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maps_tracer/screens/sign_up_user.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SignUpGroup extends StatefulWidget {
  @override
  _SignUpGroupState createState() => _SignUpGroupState();
}

class _SignUpGroupState extends State<SignUpGroup> {
  TextEditingController groupName;
  TextEditingController groupPassword;
  TextEditingController confirmGroupPassword;
  bool isProgress = false;
  final CollectionReference _groupsCollectionReference = Firestore.instance.collection('groups');

  signUpGroup(String groupName, String groupPassword) async{
    QuerySnapshot querySnapshot = await _groupsCollectionReference.getDocuments();
    int counter = 0;
    for(DocumentSnapshot doc in querySnapshot.documents){
      if(doc.data['group_name'] == groupName){
        print('group exists');
        break;
      }else{
        counter++;
      }
    }
    if(counter == querySnapshot.documents.length){
      print('oooooooooooooo');
      setState(() {
        isProgress = true;
      });
      await _groupsCollectionReference.document(groupName).setData({
        'group_name':groupName,
        'group_password':groupPassword
      });
      setState(() {
        isProgress = false;
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
        return SignUpUser(groupName);
      }));
    }
  }

  validateFields() async {
    if (groupName.text.trim().isEmpty) {
      print('enter group name');
    } else {
      if (groupPassword.text.trim().isEmpty) {
        print('enter password');
      } else {
        if (groupPassword.text != confirmGroupPassword.text) {
          print('password doesnot match');
        } else {
          signUpGroup(groupName.text, groupPassword.text);
        }
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    groupName = TextEditingController();
    groupPassword = TextEditingController();
    confirmGroupPassword = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isProgress,
      child: Scaffold(
        appBar: AppBar(
          title: Container(
              width: MediaQuery.of(context).size.width,
              child: Text(
                'Map Tracer',
                style: TextStyle(fontSize: 26.0, color: Colors.white),
                textAlign: TextAlign.center,
              )),
          backgroundColor: Colors.lightBlue,
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'SIGN UP GROUP',
                style: TextStyle(fontSize: 30.0, color: Colors.lightBlue),
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                height: 50,
                child: TextFormField(
                  controller: groupName,
                  decoration: new InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      hintText: "Group Name",
                      hintStyle: TextStyle(
                        color: Colors.lightBlue,
                      )),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.lightBlue,
                  ),
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Container(
                height: 50,
                child: TextFormField(
                  controller: groupPassword,
                  obscureText: true,
                  decoration: new InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      hintText: "Group Password",
                      hintStyle: TextStyle(
                        color: Colors.lightBlue,
                      )),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.lightBlue,
                  ),
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Container(
                height: 50,
                child: TextFormField(
                  controller: confirmGroupPassword,
                  obscureText: true,
                  decoration: new InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      hintText: "Confirm Group Password",
                      hintStyle: TextStyle(
                        color: Colors.lightBlue,
                      )),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.lightBlue,
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.lightBlue,
                ),
                child: FlatButton(
                  onPressed: () {
                    validateFields();
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
