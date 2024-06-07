// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_final_fields, prefer_const_literals_to_create_immutables, use_super_parameters

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:triumph2/provider/theme.dart';
import 'package:triumph2/provider/mailprovider.dart';

class InboxAdmin extends StatefulWidget {
  @override
  _InboxAdmin createState() => _InboxAdmin();
}

class _InboxAdmin extends State<InboxAdmin> {
  late List<MailItem> _filteredmailss;
  late String _selectedFilter;
  late String _searchQuery;

  @override
  void initState() {
    super.initState();
    _selectedFilter = 'All';
    _searchQuery = '';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData themeData = themeProvider.getCurrentTheme();
    final Color textColor = themeData.textTheme.bodyLarge!.color!;
    themeProvider.enableDarkMode ? Colors.white : Colors.black;
    final Color chipBackgroundColor = themeProvider.enableDarkMode
        ? Colors.grey.shade700
        : Colors.grey.shade300;
    final Color chipSelectedColor = themeProvider.enableDarkMode
        ? Colors.red.shade800
        : Colors.red.shade400;
    final Color chipLabelColor =
        themeProvider.enableDarkMode ? Colors.white : Colors.black;
    final Color bottomNavBarColor =
        themeProvider.enableDarkMode ? Colors.grey.shade900 : Colors.white;
    final Color cardColor =
        themeProvider.enableDarkMode ? Colors.grey.shade800 : Colors.white;
    final mailProvider = Provider.of<MailProvider>(context);
    _filteredmailss = _getFilteredMails(mailProvider.mailss);
    final pendingMails = _filteredmailss
        .where((mail) => mail.status == MailStatus.pending)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            themeProvider.enableDarkMode ? Colors.grey.shade900 : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.red,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Image.asset(
          'assets/logo.png',
          width: 250,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              themeProvider.enableDarkMode = !themeProvider.enableDarkMode;
            },
            icon: Icon(
              themeProvider.enableDarkMode
                  ? Icons.wb_sunny
                  : Icons.nightlight_round,
              color:
                  themeProvider.enableDarkMode ? Colors.yellow : Colors.black,
            ),
          ),
        ],
      ),
      body: Container(
        height: 5000,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: themeProvider.enableDarkMode
                ? [Colors.grey.shade800, Colors.red.shade800]
                : [Colors.red.shade200, Colors.red.shade400],
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 120.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending Mails',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    _buildExpansionPanelList(
                        pendingMails, textColor, cardColor, mailProvider),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: textColor),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: textColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: textColor),
                      ),
                    ),
                    style: TextStyle(color: textColor),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  SizedBox(height: 15),
                  Wrap(
                    spacing: 8.0,
                    children: [
                      _buildFilterChip('All', chipLabelColor,
                          chipBackgroundColor, chipSelectedColor),
                      _buildFilterChip('Personal', chipLabelColor,
                          chipBackgroundColor, chipSelectedColor),
                      _buildFilterChip('Work', chipLabelColor,
                          chipBackgroundColor, chipSelectedColor),
                      _buildFilterChip('Others', chipLabelColor,
                          chipBackgroundColor, chipSelectedColor),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: bottomNavBarColor,
        selectedItemColor: Colors.red,
        unselectedItemColor: textColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.archive),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_document),
            label: 'Create Mail',
          ),
        ],
        onTap: (int index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/homeadmin');
          }
          if (index == 2) {
            Navigator.pushNamed(context, '/create');
          }
        },
      ),
    );
  }

  List<MailItem> _getFilteredMails(List<MailItem> mailss) {
    return mailss.where((mails) {
      final matchesFilter =
          _selectedFilter == 'All' || mails.kategori == _selectedFilter;
      final matchesSearch =
          mails.nama.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  Widget _buildExpansionPanelList(List<MailItem> mailsList, Color textColor,
      Color cardColor, MailProvider mailProvider) {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          mailProvider.toggleMailExpansion(mailsList[index].nama);
        });
      },
      children: mailsList.map<ExpansionPanel>((MailItem mail) {
        return ExpansionPanel(
          backgroundColor: cardColor,
          headerBuilder: (BuildContext context, bool isExpanded) {
            return Container(
              color: cardColor,
              child: ListTile(
                title: Text(
                  mail.nama,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: mail.status == MailStatus.pending
                              ? Colors.grey
                              : mail.status == MailStatus.approved
                                  ? Colors.green
                                  : Colors.red,
                          size: 12,
                        ),
                        SizedBox(width: 5),
                        Text(
                          mail.status == MailStatus.pending
                              ? 'Pending'
                              : mail.status == MailStatus.approved
                                  ? 'Approved'
                                  : 'Not Approved',
                          style: TextStyle(color: textColor),
                        ),
                      ],
                    ),
                    Text(
                      'Isi: ${mail.isi}',
                      style: TextStyle(color: textColor),
                    ),
                    Text(
                      'Kategori: ${mail.kategori}',
                      style: TextStyle(color: textColor),
                    ),
                    if (mail.status == MailStatus.notApproved &&
                        mail.alasan != null)
                      Text(
                        'Alasan: ${mail.alasan}',
                        style: TextStyle(color: Colors.red),
                      ),
                    if (mail.status == MailStatus.notApproved &&
                        mail.alasan == null)
                      Text(
                        'Surat tidak disetujui tanpa alasan.',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (mail.status == MailStatus.pending)
                      IconButton(
                        icon: Icon(
                          Icons.check,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          mailProvider.changeMailStatus(
                              mail.nama, MailStatus.approved);
                        },
                      ),
                    if (mail.status == MailStatus.pending)
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          _showNotApprovedDialog(context, mail, mailProvider);
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        _showDeleteConfirmationDialog(
                            context, mail.nama, mailProvider);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          body: Container(
            color: cardColor,
            child: Column(
              children: [
                _buildMailImage(mail),
              ],
            ),
          ),
          isExpanded: mail.isExpanded,
        );
      }).toList(),
    );
  }

  Widget _buildMailImage(MailItem mail) {
    if (mail.imagePath != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
        child: Image.file(
          File(mail.imagePath!),
          height: 500,
          width: 500,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
        child: Image.asset(
          'assets/surat1.png',
          height: 500,
          width: 500,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  void _showNotApprovedDialog(
      BuildContext context, MailItem mail, MailProvider mailProvider) {
    TextEditingController _alasanController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alasan Tidak Disetujui'),
          content: TextField(
            controller: _alasanController,
            decoration: InputDecoration(labelText: 'Alasan'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Simpan'),
              onPressed: () {
                String alasan = _alasanController.text;
                mailProvider.changeMailStatus(mail.nama, MailStatus.notApproved,
                    alasan: alasan);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  FilterChip _buildFilterChip(String label, Color chipLabelColor,
      Color chipBackgroundColor, Color chipSelectedColor) {
    return FilterChip(
      label: Text(label),
      labelStyle: TextStyle(color: chipLabelColor),
      backgroundColor: chipBackgroundColor,
      selectedColor: chipSelectedColor,
      selected: _selectedFilter == label,
      onSelected: (isSelected) {
        setState(() {
          _selectedFilter = label;
        });
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, String nama, MailProvider mailProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi'),
          content: Text('Apakah Anda yakin ingin menghapus surat ini?'),
          actions: <Widget>[
            TextButton(
              child: Text('Tidak'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ya'),
              onPressed: () {
                mailProvider.deleteMail(nama);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}