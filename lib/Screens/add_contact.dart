import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'package:contact/Model/contacts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';


class AddContact extends StatefulWidget {
  @override
  _AddContactState createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  DatabaseReference _databaseReference =
  FirebaseDatabase.instance.reference();

  String _firstName= '';
  String _lastName= '';
  String _phone= '';
  String _email= '';
  String _address= '';
  String _photoUrl="empty";
  
  saveContact(BuildContext context) async{
    if(_firstName.isNotEmpty && _lastName.isNotEmpty && _phone.isNotEmpty && _email.isNotEmpty && _address.isNotEmpty){
      Contacts contacts=Contacts(this._firstName, this._lastName, this._phone, this._email, this._address, this._photoUrl);

      await _databaseReference.push().set(contacts.toJson());
      navigateToLastScreen(context);
    }
    else{
      showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Field Required"),
            content: Text("All fields are required"),
            actions: <Widget>[
              FlatButton(
                child: Text("Close"),
                 onPressed: (){
                  Navigator.of(context).pop();
                }),
              ],
            );
          }
        );
      }
    }
  
    Future pickImage() async {
     File file=await ImagePicker.pickImage(
       source: ImageSource.gallery,
       maxHeight: 200.0,
       maxWidth: 200.0,
     );
     String filename= basename(file.path);
     uploadImage(file,filename);
    }
    void uploadImage(File file,String filename) async {

        StorageReference storageReference=
        FirebaseStorage.instance.ref().child(filename);
        storageReference.putFile(file).onComplete.then((firebaseFile) async {
          var downloadUrl=await firebaseFile.ref.getDownloadURL();
          setState(() {
            _photoUrl = downloadUrl;
          });
        });
      }
    
  navigateToLastScreen(context){
      Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Contact"),
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top : 10.0),
                child: GestureDetector(
                  onTap: (){
                    this.pickImage();
                  },
                  child: Center(
                    child: Container(
                      width: 180.0,
                      height: 180.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: _photoUrl == "empty"
                           ?AssetImage("logo.png")
                           :NetworkImage(_photoUrl),
                        )
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                  margin: EdgeInsets.only(top: 40.0),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (value){
                      setState(() {
                        _firstName=value;
                       });
                    },
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(width: 1,color: Colors.black),
                          ),
                    ),
                  ),
              ),
              Container(
                  margin: EdgeInsets.only(top: 20.0),
                  child: TextField(
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (value){
                      setState(() {
                        _lastName=value;
                       });
                    },
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(width: 1,color: Colors.black),
                          ),
                    ),
                  ),
              ),
              Container(
                  margin: EdgeInsets.only(top: 20.0),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value){
                      setState(() {
                        _phone=value;
                       });
                    },
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(width: 1,color: Colors.black),
                          ),
                    ),
                   
                  ),
              ),
              Container(
                  margin: EdgeInsets.only(top: 20.0),
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value){
                      setState(() {
                        _email=value;
                       });
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(width: 1,color: Colors.black),
                          ),
                    ),
                  ),
              ),
              Container(
                  margin: EdgeInsets.only(top: 20.0),
                  child: TextField(
                    onChanged: (value){
                      setState(() {
                        _address=value;
                       });
                    },
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(width: 1,color: Colors.black),
                          ),
                    ),
                  ),
              ),
              //save
              Container(
                padding: EdgeInsets.all(40.0),
                child: RaisedButton(
                  padding: EdgeInsets.fromLTRB(50, 20, 50, 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  onPressed: (){
                    saveContact(context);
                  },
                  color: Colors.red,
                  child: Text(
                    "SAVE",
                  style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.white
                    
                  ),),
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}