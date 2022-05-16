import 'package:fluttertoast/fluttertoast.dart';
import 'package:ridetripper/components/Skeleton.dart';
import 'package:ridetripper/database/contacts_db.dart';
import 'package:ridetripper/model/contactModel.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:ridetripper/pages/Emergency.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';

class PhoneContactList extends StatefulWidget {
  const PhoneContactList({Key? key}) : super(key: key);

  @override
  _PhoneContactListState createState() => _PhoneContactListState();
}

class _PhoneContactListState extends State<PhoneContactList> {
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  TextEditingController searchController = new TextEditingController();
  late Permission permission;
  List<String> recipents = [];
  String message = "This is a test message!";
  List<ContactModel> selectedContact = [];
  PermissionStatus permissionStatus = PermissionStatus.denied;
  final Telephony telephony = Telephony.instance;
  List<ContactModel> dbContacts = [];
  bool _isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listenPermission();
    searchController.addListener(() {
      filterContacts();
    });
  }

  listenPermission() async {
    final status = await Permission.contacts.status;
    setState(() {
      permissionStatus = status;
    });

    switch (status) {
      case PermissionStatus.denied:
        requestPermission();
        break;
      case PermissionStatus.granted:
        getAllContact();
        break;
      default:
        Navigator.pop(context);
    }
  }

  requestPermission() async {
    final status = await Permission.contacts.request();
    setState(() {
      permissionStatus = status;
    });
  }

  getAllContact() async {
    List<Contact> _contacts = await ContactsService.getContacts();
    List<ContactModel> _dbContacts = await ContactsDatabase.instance.readAllContacts();
    setState(() {
      contacts = _contacts;
      dbContacts = _dbContacts;
      _isLoading = false;
    });
  }

  filterContacts() {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = searchController.text.toLowerCase();
        String contactName = contact.displayName!.toLowerCase();

        return contactName.contains(searchTerm);
      });
      setState(() {
        contactsFiltered = _contacts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Contact List"),
      ),
      body: _isLoading? Skeleton3(): Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                    labelText: 'Search',
                    border: new OutlineInputBorder(
                      borderSide: new BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).primaryColor,
                    )),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: isSearching == true
                      ? contactsFiltered.length
                      : contacts.length,
                  itemBuilder: (context, index) {
                    Contact contact = isSearching == true
                        ? contactsFiltered[index]
                        : contacts[index];
                    bool isSelected = selectedContact
                        .map((e) => e.contactName)
                        .contains(contact.displayName);
                    return ContactList(contact, isSelected);
                  }),
            ),
            Container(
              height: 45,
              child: ElevatedButton(
                  child: Text(
                    "Select Contacts",
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () async {
                    bool? permissionsGranted =
                        await telephony.requestPhoneAndSmsPermissions;

                    if (permissionsGranted!) {
                      
                      for (ContactModel contactModel in selectedContact) {
                        int index = dbContacts.indexWhere((element) =>
                            element.phoneNumber == contactModel.phoneNumber);

                        print(index);
                        if (index == -1) {
                          await ContactsDatabase.instance.create(contactModel);
                        } else {
                          print("Already Added");
                        }
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EmergencyPage()),
                      );
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }

  Widget ContactList(Contact contact, bool isSelected) {
    return ListTile(
      title: Text(contact.displayName!),
      subtitle: Text(contact.phones!.elementAt(0).value!),
      selected: isSelected,
      leading: (contact.avatar != null && contact.avatar!.length > 0)
          ? CircleAvatar(
              backgroundImage: MemoryImage(contact.avatar!),
            )
          : CircleAvatar(
              child: Text(contact.initials()),
            ),
      trailing:
          isSelected ? Icon(Icons.check, color: Colors.blue, size: 26) : null,
      onTap: () {
        if (dbContacts.length < 5) {
          isSelected = selectedContact
              .map((e) => e.contactName)
              .contains(contact.displayName);

          print(isSelected);
          setState(() {
            isSelected
                ? selectedContact.removeWhere(
                    (element) => element.contactName == contact.displayName)
                : selectedContact.add(ContactModel(
                    contactName: contact.displayName!,
                    phoneNumber: contact.phones!.elementAt(0).value!,
                    initials: contact.initials()));
          });
        } else {
          Fluttertoast.showToast(
              msg: "Maximum 5 contacts can be added",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      },
    );
  }
}
