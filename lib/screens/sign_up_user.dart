import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maps_tracer/screens/home.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SignUpUser extends StatefulWidget {
  String groupName;
  SignUpUser(this.groupName);
  @override
  _SignUpUserState createState() => _SignUpUserState();
}

class _SignUpUserState extends State<SignUpUser> {
  TextEditingController userName;
  TextEditingController userPassword;
  TextEditingController confirmUserPassword;
  bool isProgress = false;
  CollectionReference _usersCollectionReference;

  signUpUser(String userName, String userPassword) async{
    String userType = 'user';
    _usersCollectionReference = Firestore.instance.collection('groups').document(widget.groupName).collection('user');
    QuerySnapshot querySnapshot = await _usersCollectionReference.getDocuments();
    int counter = 0;
    for(DocumentSnapshot doc in querySnapshot.documents){
      if(doc.data['user_name'] == userName){
        print('user exists');
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
      if(querySnapshot.documents.length == 0){
        userType = 'admin';
      }else{
        userType = 'user';
      }

      await _usersCollectionReference.document(userName).setData({
        'user_name':userName,
        'user_password':userPassword,
        'user_type':userType
      });
      setState(() {
        isProgress = false;
      });
//      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//      sharedPreferences.setString('user_name', userName);
//      sharedPreferences.setString('group_name', widget.groupName);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
        return Home(_usersCollectionReference,userName);
      }));
    }
  }
  signInUser(String userName, String userPassword) async{
    setState(() {
      isProgress = true;
    });
    _usersCollectionReference = Firestore.instance.collection('groups').document(widget.groupName).collection('user');
    QuerySnapshot querySnapshot = await _usersCollectionReference.getDocuments();
    int counter = 0;
    for(DocumentSnapshot doc in querySnapshot.documents){
      if(doc.data['user_name'] == userName && doc.data['user_password'] == userPassword){
//        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//        sharedPreferences.setString('user_name', userName);
//        sharedPreferences.setString('group_name', widget.groupName);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
          return Home(_usersCollectionReference,userName);
        }));
      }else{
        counter++;
      }
    }
    setState(() {
      isProgress = false;
    });
    if(counter == querySnapshot.documents.length){
      print('invalid username or password');
    }
  }

  validateFields(int type) async {
    if (userName.text.trim().isEmpty) {
      print('enter user name');
    } else {
      if (userPassword.text.trim().isEmpty) {
        print('enter password');
      } else {
        if(type == 1){
          signInUser(userName.text, userPassword.text);
        }else {
          if (userPassword.text != confirmUserPassword.text) {
            print('password doesnot match');
          } else {
            signUpUser(userName.text, userPassword.text);
          }
        }
      }
    }
  }

  isUserSignedIn() async{
    setState(() {
      isProgress = true;
    });
//    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//    print(sharedPreferences.getString('user_name'));
//    if(sharedPreferences.getString('user_name') != null && sharedPreferences.getString('group_name') == widget.groupName){
//      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
//        return Home(Firestore.instance.collection('groups').document(widget.groupName).collection('user'),sharedPreferences.getString('user_name'));
//      }));
//    }
    setState(() {
      isProgress = false;
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userName = TextEditingController();
    userPassword = TextEditingController();
    confirmUserPassword = TextEditingController();
    isUserSignedIn();

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
        body:
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'SIGN UP USER',
                style: TextStyle(fontSize: 30.0, color: Colors.lightBlue),
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                height: 50,
                child: TextFormField(
                  controller: userName,
                  decoration: new InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      hintText: "User Name",
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
                  controller: userPassword,
                  obscureText: true,
                  decoration: new InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      hintText: "User Password",hintStyle: TextStyle(color: Colors.lightBlue,)),
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
                  controller: confirmUserPassword,
                  obscureText: true,
                  decoration: new InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      hintText: "Confirm User Password",hintStyle: TextStyle(color: Colors.lightBlue,)),
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
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: Colors.lightBlue,),
                child: FlatButton(
                  onPressed: () {
                    validateFields(1);
                  },
                  child: Text('Sign In',style: TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.bold),),
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: Colors.lightBlue,),
                child: FlatButton(
                  onPressed: () {
                    validateFields(2);
                  },
                  child: Text('Sign Up',style: TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.bold),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
