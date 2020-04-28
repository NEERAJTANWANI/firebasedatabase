import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:contact/Model/contacts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';


class EditContact extends StatefulWidget {
  final String id;
  EditContact(this.id);
  @override
  _EditContactState createState() => _EditContactState(this.id);
}

class _EditContactState extends State<EditContact> {
  String id;
  _EditContactState(this.id);

  String _firstName = '';
  String _lastName = '';
  String _phone = '';
  String _address = '';
  String _email = '';
  String _photoUrl;

    //handlr text editing controller

    TextEditingController _fnController = TextEditingController();
    TextEditingController _lnController = TextEditingController();
    TextEditingController _poController = TextEditingController();
    TextEditingController _emController = TextEditingController();
    TextEditingController _adController = TextEditingController();
    
    bool isLoading = true;

    DatabaseReference _databaseReference= FirebaseDatabase.instance.reference();

    @override
    void initState(){
      super.initState();
      //get contact from firebase
      this.getContact(id);

    }
    getContact(id) async {
      Contacts _contacts;
      _databaseReference.child(id).onValue.listen((event){

          _contacts=Contacts.fromSnapshot(event.snapshot);
          
          _fnController.text = _contacts.firstName;
          _lnController.text = _contacts.lastName;
          _poController.text = _contacts.phone;
          _emController.text = _contacts.email;
          _adController.text = _contacts.address;
          
          setState(() {
          _firstName=_contacts.firstName;
          _lastName=_contacts.lastName;
          _phone=_contacts.phone;
          _email=_contacts.email;
          _address=_contacts.address;
          _photoUrl =_contacts.photoUrl;          
          isLoading=false;
          });
          
      });

    }


    //update contact
    updateContact(BuildContext context) async {
      if(_firstName.isNotEmpty &&
         _lastName.isNotEmpty &&
         _email.isNotEmpty &&
         _phone.isNotEmpty &&
         _address.isNotEmpty 
         ){
           Contacts contacts =Contacts.withId(this.id,this._firstName, this._lastName, this._phone, this._email, this._address, this._photoUrl); 
           await _databaseReference.child(id).set(contacts.toJson());
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

    //pickImage
      Future pickImage() async {
     File file=await ImagePicker.pickImage(
       source: ImageSource.gallery,
       maxHeight: 200.0,
       maxWidth: 200.0,
     );
     String filename= basename(file.path);
     uploadImage(file,filename);
    }
  

    //uploadImage
  
    void uploadImage(File file,String filename) async {

        StorageReference storageReference=
          FirebaseStorage.instance.ref().child(filename);
            //upload image 
        storageReference.putFile(file).onComplete.then((firebaseFile) async {
          var _downloadUrl=await firebaseFile.ref.getDownloadURL();
          setState(() {
            _photoUrl=_downloadUrl;
          });
        });
      }
  

  navigateToLastScreen(BuildContext context){
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Contact"),
      ),
      body: Container(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: EdgeInsets.all(20.0),
                child: ListView(
                  children: <Widget>[
                    //image view
                    Container(
                        margin: EdgeInsets.only(top: 20.0),
                        child: GestureDetector(
                          onTap: () {
                            this.pickImage();
                          },
                          child: Center(
                            child: Container(
                                width: 100.0,
                                height: 100.0,
                                decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                      fit: BoxFit.cover,
                                      image:
                                          _photoUrl=="null"
                                          ? AssetImage("logo.png")
                                          : NetworkImage(_photoUrl),
                                        ),
                                      ),
                                    ),
                          ),
                        ),
                        ),
                    //
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _firstName = value;
                          });
                        },
                        controller: _fnController,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ),
                    ),
                    //
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _lastName = value;
                          });
                        },
                        controller: _lnController,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ),
                    ),
                    //
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _phone = value;
                          });
                        },
                        controller: _poController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ),
                    ),
                    //
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _email = value;
                          });
                        },
                        controller: _emController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ),
                    ),
                    //
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _address = value;
                          });
                        },
                        controller: _adController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ),
                    ),
                    // update button
                    Container(
                      padding: EdgeInsets.only(top: 20.0),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        padding: EdgeInsets.fromLTRB(100.0, 20.0, 100.0, 20.0),
                        onPressed: () {
                          updateContact(context);
                        },
                        color: Colors.red,
                        child: Text(
                          "Update",
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

}