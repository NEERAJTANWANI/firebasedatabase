import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'edit_contact.dart';
import 'package:contact/Model/contacts.dart';
import 'package:url_launcher/url_launcher.dart';


class ViewContact extends StatefulWidget {
  final String id;
  ViewContact(this.id);
  @override
  _ViewContactState createState() => _ViewContactState(this.id);
}

class _ViewContactState extends State<ViewContact> {
  String id;
  _ViewContactState(this.id);
  Contacts _contacts;
  bool isLoading=true;
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();
  
  getContact(id) async {
    _databaseReference.child(id).onValue.listen((Event event){
      setState((){
        _contacts=Contacts.fromSnapshot(event.snapshot);
        isLoading=false;  
      });
    });
  }
  
  @override
  void initState(){
    super.initState();
    this.getContact(id);
  }

  callAction(String number) async {
    String url ='tel:$number';
    if (await canLaunch(url)) {
        await launch(url);
      }
     else{
       throw 'Could not call $number';
     } 

    }

  smsAction(String number) async {
    String url ='sms:$number';
    if (await canLaunch(url)) {
        await launch(url);
      }
     else{
       throw 'Could not message to $number';
     } 

    }

  deleteContact(){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("Delete ?"),
          content: Text("Delete Contact"),
          actions: <Widget>[
            FlatButton(
              child: Text("CANCEL"),
              onPressed: (){
                Navigator.of(context).pop();
                },
              ),
              FlatButton(
              child: Text("DELETE"),
              onPressed: () async {
                Navigator.of(context).pop();
                await _databaseReference.child(id).remove();
                navigateToLastScreen();
                },
              ),
          ],
        );
      }
    );
  }
  navigateToEditScreen(id){
    Navigator.push(context,MaterialPageRoute(
      builder: (context){
        return EditContact(id);
        //add id
      }
    ));
  }

  navigateToLastScreen(){
      Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // wrap screen in WillPopScreen widget
    return Scaffold(
      appBar: AppBar(
        title: Text("View Contact"),
      ),
      body: Container(
        child: isLoading
              ? Center(
                child: CircularProgressIndicator(),
                  )
              : ListView(
                children: <Widget>[
                  // header text container
                  Container(
                      width: 1.0,
                      height: 400.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: _contacts.photoUrl == "empty"
                          ? AssetImage("logo.png")
                          : NetworkImage(_contacts.photoUrl),
                         )
                      ),
                    ),
                  //name
                  Card(
                    elevation: 2.0,
                    child: Container(
                        margin: EdgeInsets.all(20.0),
                        width: double.maxFinite,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.perm_identity),
                            Container(
                              width: 10.0,
                            ),
                            Text(
                              "${_contacts.firstName} ${_contacts.lastName}",
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ],
                        )),
                  ),
                  // phone
                  Card(
                    elevation: 2.0,
                    child: Container(
                        margin: EdgeInsets.all(20.0),
                        width: double.maxFinite,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.phone),
                            Container(
                              width: 10.0,
                            ),
                            Text(
                              _contacts.phone,
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ],
                        )),
                  ),
                  // email
                  Card(
                    elevation: 2.0,
                    child: Container(
                        margin: EdgeInsets.all(20.0),
                        width: double.maxFinite,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.email),
                            Container(
                              width: 10.0,
                            ),
                            Text(
                              _contacts.email,
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ],
                        )),
                  ),
                  // address
                  Card(
                    elevation: 2.0,
                    child: Container(
                        margin: EdgeInsets.all(20.0),
                        width: double.maxFinite,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.home),
                            Container(
                              width: 10.0,
                            ),
                            Text(
                              _contacts.address,
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ],
                        )),
                  ),
                  // call and sms
                  Card(
                    elevation: 2.0,
                    child: Container(
                        margin: EdgeInsets.all(20.0),
                        width: double.maxFinite,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            IconButton(
                              iconSize: 30.0,
                              icon: Icon(Icons.phone),
                              color: Colors.red,
                              onPressed: () {
                                callAction(_contacts.phone);
                              },
                            ),
                            IconButton(
                              iconSize: 30.0,
                              icon: Icon(Icons.message),
                              color: Colors.red,
                              onPressed: () {
                                smsAction(_contacts.phone);
                              },
                            )
                          ],
                        )),
                  ),
                  // edit and delete
                  Card(
                    elevation: 2.0,
                    child: Container(
                        margin: EdgeInsets.all(20.0),
                        width: double.maxFinite,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            IconButton(
                              iconSize: 30.0,
                              icon: Icon(Icons.edit),
                              color: Colors.red,
                              onPressed: () {
                                navigateToEditScreen(id);
                              },
                            ),
                            IconButton(
                              iconSize: 30.0,
                              icon: Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () {
                                deleteContact();
                              },
                            )
                          ],
                        )),
                  )
                ],
              ),
      ),
    );
  }

}