import 'package:flutter/material.dart';
import 'dart:math';
import '../models/contact.dart';
import '../styles/app_styles.dart';
import '../db/db_helper.dart';
import 'contact_form.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final DBHelper _dbHelper = DBHelper();
  List<Contact> _contacts = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    final contacts = await _dbHelper.getContacts();
    setState(() {
      _contacts = contacts;
    });
  }

  void _addContact() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactForm(
          onSave: (name, phone, email) async {
            await _dbHelper.insertContact(
              Contact(name: name, phone: phone, email: email),
            );
            await loadContacts();
          },
        ),
      ),
    );
  }

  void _editContact(Contact contact) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactForm(
          contact: contact,
          onSave: (name, phone, email) async {
            await _dbHelper.updateContact(
              contact.copyWith(name: name, phone: phone, email: email),
            );
            await loadContacts();
          },
        ),
      ),
    );
  }

  Future<void> _deleteContactConfirm(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar contacto'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este contacto?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _dbHelper.deleteContact(id);
      await loadContacts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Contactos'),
        backgroundColor: AppStyles.primaryColor,
      ),
      body: _contacts.isEmpty
          ? const Center(
              child: Text(
                "No hay contactos. Agrega uno usando el botón +",
                style: AppStyles.emptyText,
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.9,
              ),
              itemCount: _contacts.length + 1,
              itemBuilder: (context, index) {
                // index 0 reserved for the 'Add contact' tile
                if (index == 0) {
                  final color = AppStyles.addColor;
                  return GestureDetector(
                    onTap: _addContact,
                    child: Card(
                      color: color,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Spacer(),
                            const Icon(
                              Icons.add,
                              size: 28,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Agregar',
                              style: AppStyles.contactTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            const SizedBox(height: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '',
                                    style: AppStyles.contactContent,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '',
                                    style: AppStyles.contactContent,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final contact = _contacts[index - 1];
                final color = (contact.id != null && (contact.id! % 2) == 1)
                    ? AppStyles.cardColors[0]
                    : AppStyles.cardColors[1];
                return GestureDetector(
                  onTap: () => _editContact(contact),
                  child: Card(
                    color: color,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.name,
                            style: AppStyles.contactTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  contact.phone,
                                  style: AppStyles.contactContent,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  contact.email ?? '',
                                  style: AppStyles.contactContent,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete),
                              color: AppStyles.deleteColor,
                              onPressed: () =>
                                  _deleteContactConfirm(contact.id!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      // FloatingActionButton removed: 'Agregar' tile is now the first grid item
    );
  }
}
