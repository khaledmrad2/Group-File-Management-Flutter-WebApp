import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ia/constant.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupPage extends StatefulWidget {
  SharedPreferences prefs;
  String group_name;
  String group_id;

  GroupPage(this.prefs, this.group_name, this.group_id);

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  List<Map<String, dynamic>> files = [];
  List<Map<String, dynamic>> myfiles = [];
  List<Map<String, dynamic>> selectedFileIds = [];
  bool isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    fetchgroupfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          "${widget.group_name} Group",
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white, // Change this color to your desired color
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: () {
              setState(() {
                isSelectionMode = !isSelectionMode;
                if (!isSelectionMode) {
                  selectedFileIds.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Lottie.asset(
              'assets/images/d.json',
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(40.0),
                child: Text(
                  'Group Files',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.normal),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        4, // You can adjust the number of columns as needed
                  ),
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    final media = file['media'][0];
                    final status = file['status'];
                    return buildFileCard(file, media, status);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          isSelectionMode ? showConfirmationDialog() : fetchmyfiles();
          setState(() {});
        },
        child: isSelectionMode
            ? const Icon(
                Icons.done_all_outlined,
                color: Colors.white,
              )
            : const Icon(
                Icons.file_copy_rounded,
                color: Colors.white,
              ),
      ),
    );
  }

  void checkInFile(int fileId, int fileVersion, int x) async {
    final response = await http.post(
      Uri.parse(MainURL + check_inURL),
      headers: {"Authorization": 'Bearer ${widget.prefs.getString('token')}'},
      body: {
        "file_id": fileId.toString(),
        "version": fileVersion.toString(),
      },
    );
    print(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      x == 1 ? showSnackbar(context, "file checked in Successfully") : null;
      setState(() {
        fetchgroupfiles();
      });
    } else {
      showSnackbar(context, "Connection Error");
    }
  }

  void Check_outFile(int fileId) async {
    final response = await http.post(
      Uri.parse("${MainURL}user/check_out/$fileId"),
      headers: {"Authorization": 'Bearer ${widget.prefs.getString('token')}'},
    );
    print(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      showSnackbar(context, "file checked out Successfully");
      setState(() {
        fetchgroupfiles();
      });
    } else {
      showSnackbar(context, "Connection Error");
    }
  }

  Future<void> editFile(int fileId) async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.any, allowMultiple: false);

    if (result != null && result.files.isNotEmpty) {
      final fileBytes = result.files.first.bytes;
      final fileName = result.files.first.name;
      final url = Uri.parse(MainURL + Edit_fileURL);

      var request = http.MultipartRequest('POST', url);

      // Attach the file to the request
      request.files.add(
          http.MultipartFile.fromBytes('file', fileBytes!, filename: fileName));
      request.headers['Authorization'] =
          'Bearer ${widget.prefs.getString('token')}';
      request.fields['file_id'] = fileId.toString();

      // Send the request
      var response = await request.send();

      // Handle the response
      if (response.statusCode == 200) {
        print('File Edited successfully');
        showSnackbar(context, "File Edited successfully");
        setState(() {
          fetchgroupfiles();
        });
      } else {
        print('File upload failed');
      }
    }
  }

  Future<void> deleteFile(String fileId) async {
    final response = await http.post(
      Uri.parse(MainURL + DeleteFileFromGroupUserURL),
      headers: {"Authorization": 'Bearer ${widget.prefs.getString('token')}'},
      body: {
        "file_id": fileId.toString(),
        "group_id": widget.group_id.toString(),
      },
    );
    print(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      showSnackbar(
          context, "file Deleted from ${widget.group_name} Group Successfully");
      setState(() {
        fetchgroupfiles();
      });
    } else {
      showSnackbar(context, "Connection Error");
    }
  }

  Future<void> fetchmyfiles() async {
    final url = Uri.parse(MainURL + my_filesURL);
    try {
      final response = await http.get(
        url,
        headers: {"Authorization": 'Bearer ${widget.prefs.getString('token')}'},
      );
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = json.decode(response.body);
        if (data != null &&
            data['message'] == "success" &&
            data['files'] != null) {
          setState(() {
            myfiles = List<Map<String, dynamic>>.from(data['files']);
          });
          _showFilesDialog();
        } else {
          // Handle the error
          print('Failed to fetch files');
        }
      } else {
        // Handle the error
        print('Failed to fetch files: ${response.statusCode}');
      }
    } catch (e) {
      // Handle other exceptions
      print('Error: $e');
    }
  }

  void _showFilesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("My Files"),
          content: SizedBox(
            width: 400,
            height: 300,
            child: ListView.builder(
              itemCount: myfiles.length,
              itemBuilder: (context, index) {
                final file = myfiles[index];
                final media = file['media'][0];
                return Card(
                  child: ListTile(
                    title: Column(
                      children: [
                        Text(
                          media['name'],
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 2,
                                ),
                                onPressed: () {
                                  openFile(file['media'][0]['original_url']);
                                },
                                child: const Text("Open"),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 2,
                                ),
                                onPressed: () {
                                  uploadFileToGroup(file['id']);
                                },
                                child: const Text("Upload to Group"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void uploadFileToGroup(int fileId) async {
    final response = await http.post(
      Uri.parse(MainURL + AddFileToGroupUserURL),
      headers: {"Authorization": 'Bearer ${widget.prefs.getString('token')}'},
      body: {
        "file_id": fileId.toString(),
        "group_id": widget.group_id.toString(),
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context);
      showSnackbar(
          context, "file uploaded to ${widget.group_name} Group Successfully");
      setState(() {
        fetchgroupfiles();
      });
    } else {
      showSnackbar(context, "Connection Error");
    }
  }

  void openFile(String fileUrl) async {
    final encodedUrl = Uri.encodeFull(fileUrl);

    if (await canLaunch(encodedUrl)) {
      await launch(encodedUrl);
    } else {
      print('Could not launch $encodedUrl');
    }
  }

  Future<void> fetchgroupfiles() async {
    final url =
        Uri.parse("${MainURL}user/group_files/${widget.group_id.toString()}");
    try {
      final response = await http.get(
        url,
        headers: {"Authorization": 'Bearer ${widget.prefs.getString('token')}'},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> fetchedFiles = responseData['files'];
        setState(() {
          files = List<Map<String, dynamic>>.from(fetchedFiles);
        });
      } else {
        // Handle the error
        print('Failed to fetch files: ${response.statusCode}');
      }
    } catch (e) {
      // Handle other exceptions
      print('Error: $e');
    }
  }

  Widget buildFileCard(Map<String, dynamic> file, dynamic media, int status) {
    final userId = file['user_id'];
    final blockingUserId = file['blocking_user_id'];
    final version = file['version'];
    final isOwner = userId.toString() == widget.prefs.getString('user_id');
    final isMyBlock =
        blockingUserId.toString() == widget.prefs.getString('user_id');

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 50),
      child: Card(
        elevation: 10,
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      media['name'],
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () {
                        openFile(file['media'][0]['original_url']);
                      },
                      child: const Icon(Icons.file_copy_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Inside buildFileCard function
                if (isSelectionMode && status == 1)
                  Checkbox(
                    value: selectedFileIds
                        .any((item) => item['file_id'] == file['id']),
                    onChanged: (value) {
                      setState(() {
                        if (value != null) {
                          if (value) {
                            selectedFileIds.add(
                                {"file_id": file['id'], "version": version});
                          } else {
                            selectedFileIds.removeWhere(
                                (item) => item['file_id'] == file['id']);
                          }
                        }
                      });
                    },
                  )
                else if (status == 1)
                  Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                        ),
                        onPressed: () {
                          checkInFile(file['id'], file['version'], 1);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Check In",
                              style: TextStyle(color: Colors.green),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.lock_outline,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                if (status == 0 && isMyBlock)
                  Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                        ),
                        onPressed: () {
                          editFile(file['id']);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Edit File",
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.edit_outlined,
                              color: Colors.blueAccent,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                if (status == 0 && isMyBlock)
                  Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                        ),
                        onPressed: () {
                          Check_outFile(file['id']);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Check out",
                              style: TextStyle(color: Colors.teal),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.lock_open_outlined,
                              color: Colors.teal,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                if (isOwner && !isSelectionMode)
                  Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                        ),
                        onPressed: () {
                          deleteFile(file['id'].toString());
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Delete File",
                              style: TextStyle(color: Colors.red),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                  ),
                  onPressed: () {
                    file_report(file['id'].toString(), context);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "File Report",
                        style: TextStyle(color: Colors.amber),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.report_problem_outlined,
                        color: Colors.amber,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Selection"),
          content: const Text("Do you want Check in the selected files?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              // Inside showConfirmationDialog function
              onPressed: () {
                markFilesWithStatus1(selectedFileIds);
                Navigator.pop(context);
                Future.delayed(const Duration(seconds: 1))
                    .then((value) => setState(() {
                          isSelectionMode = false;
                          selectedFileIds
                              .clear(); // Clear the selected files after marking
                        }));
              },

              child: const Text(
                "OK",
              ),
            ),
          ],
        );
      },
    );
  }

  void markFilesWithStatus1(List<Map<String, dynamic>> selectedFileIds) async {
    List<Map<String, String>> stringFileIds = selectedFileIds
        .map((map) => {
              "file_id": map['file_id'].toString(),
              "version": map['version'].toString(),
            })
        .toList();

    String requestBody = jsonEncode({"files_id": stringFileIds});
    print(requestBody);

    final response = await http.post(
      Uri.parse(MainURL + bulk_check_inURL),
      headers: {
        "Authorization": 'Bearer ${widget.prefs.getString('token')}',
        "Content-Type": "application/json", // Add this line
      },
      body: requestBody, // Use the requestBody directly here
    );

    print(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      showSnackbar(context, "Files marked successfully");
      setState(() {
        fetchgroupfiles();
      });
    } else {
      showSnackbar(context, "Connection Error");
    }
  }

  Future<void> file_report(String fileId, context) async {
    final url = Uri.parse("${MainURL}user/file_report/$fileId");
    try {
      final response = await http.get(
        url,
        headers: {"Authorization": 'Bearer ${widget.prefs.getString('token')}'},
      );
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = json.decode(response.body)['data'];
        final List<Map<String, dynamic>> fileReportData =
            List<Map<String, dynamic>>.from(data);

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Text(
                      'File Reports ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: fileReportData.length,
                      itemBuilder: (context, index) {
                        final report = fileReportData[index];
                        return ListTile(
                          title: Row(
                            children: [
                              Icon(
                                getOperationIcon(report['operation']),
                                size: 30,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${report['operation']} by ${report['user']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            'Date: ${removeTrailingZ(report['date'])}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        // Handle the error
      }
    } catch (e) {
      // Handle other exceptions
      print('Error: $e');
    }
  }

  String removeTrailingZ(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    String formattedDateTime =
        "${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} "
        "${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)}";
    return formattedDateTime;
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  IconData getOperationIcon(String operation) {
    switch (operation) {
      case 'check-in':
        return Icons.arrow_downward;
      case 'check-out':
        return Icons.arrow_upward;
      case 'upload':
        return Icons.cloud_upload;
      case 'edit':
        return Icons.edit;
      default:
        return Icons.info;
    }
  }
}
