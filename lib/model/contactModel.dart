final String tableContacts = 'contacts';

class ContactsField {
  static final String id = '_id';
  static final String contactName = 'contact_name';
  static final String phoneNumber = 'phone_no';
  static final String initials = 'initials';
}

class ContactModel {
  final int? id;
  final String contactName;
  final String phoneNumber;
  final String initials;

  const ContactModel(
      {this.id,
      required this.contactName,
      required this.phoneNumber,
      required this.initials});

  Map<String, Object?> toJson() => {
        ContactsField.id: id,
        ContactsField.contactName: contactName,
        ContactsField.phoneNumber: phoneNumber,
        ContactsField.initials: initials
      };

  ContactModel copy({int? id, String? contactName, String? phoneNumber, String? initials}) =>
      ContactModel(
          id: id ?? this.id,
          contactName: contactName ?? this.contactName,
          phoneNumber: phoneNumber ?? this.phoneNumber,
          initials: initials ?? this.initials
          );

  static ContactModel fromJson(Map<String, Object?> json) => ContactModel(
      id: json[ContactsField.id] as int?,
      contactName: json[ContactsField.contactName] as String,
      phoneNumber: json[ContactsField.phoneNumber] as String,
      initials: json[ContactsField.initials] as String
      );
}
