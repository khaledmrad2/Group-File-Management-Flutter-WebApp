import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ia/GroupPage.dart';
import 'package:ia/LoginPage.dart';
import 'package:ia/ReportPage.dart';
import 'package:ia/constant.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final SharedPreferences prefs;

  HomePage(this.prefs);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> files = [];
  List<Map<String, dynamic>> groups =
      []; // Initialize an empty list to store groups

  @override
  void initState() {
    super.initState();
    fetchData();
    _fetchGroupsFromBackend(); // Call the function to fetch groups when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Home Page',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: InkWell(
                onTap: () {
                  _showCreateGroupDialog(context);
                },
                child: const Row(
                  children: [
                    Icon(Icons.create_outlined, color: Colors.white),
                    Text(
                      "Create Group",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18),
                    ),
                  ],
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: InkWell(
                onTap: () {
                  _userReports();
                },
                child: const Row(
                  children: [
                    Icon(Icons.report_gmailerrorred_outlined,
                        color: Colors.white),
                    Text(
                      "My Reports",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18),
                    ),
                  ],
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: InkWell(
                onTap: () {
                  _logout(context);
                },
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    Text(
                      "Logout",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18),
                    ),
                  ],
                )),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Text(
                'My Files',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        leading: const Icon(Icons.file_copy),
                        title: Text(file['media'][0]['name']),
                        onTap: () {
                          openFile(file['media'][0]['original_url']);
                        },
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        delete_file(file['id'].toString());
                      },
                      child: const Icon(
                        Icons.delete_outlined,
                        size: 30,
                        color: Colors.red,
                      ),
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Lottie.asset(
              'assets/images/b.json',
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(30.0),
                child: Card(
                  elevation: 2,
                  child: Text(
                    'Your Groups',
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.normal,
                        color: Colors.black54),
                  ),
                ),
              ),
              // Display the list of groups
              Expanded(
                child: ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GroupPage(
                                      widget.prefs,
                                      group['group_name'],
                                      group['id'].toString(),
                                    )),
                          );
                        },
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(15.0),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  group['group_name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 3.0,
                                      ),
                                      onPressed: () {
                                        _showUsersDialog(group['id'], context);
                                      },
                                      child: const Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(Icons.add),
                                          ),
                                          Text("Add Users To Group"),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 3.0,
                                      ),
                                      onPressed: () {
                                        displayUsersInMyGroupDialog(
                                            group['id'], context);
                                        // _delete_group(group['id'], context);
                                      },
                                      child: const Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.remove,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                          Text(
                                            "Remove Users from Group",
                                            style: TextStyle(
                                                color: Colors.blueGrey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 3.0,
                                      ),
                                      onPressed: () {
                                        _delete_group(group['id'], context);
                                      },
                                      child: const Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.delete_outlined,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                          Text(
                                            "Delete the Group",
                                            style: TextStyle(
                                                color: Colors.redAccent),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
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
          _pickFile();
        },
        child: const Icon(
          Icons.upload,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    // Use the file_picker package to pick a file
    final result = await FilePicker.platform
        .pickFiles(type: FileType.any, allowMultiple: false);

    if (result != null && result.files.isNotEmpty) {
      final fileBytes = result.files.first.bytes;
      final fileName = result.files.first.name;
      uploadFile(fileBytes, fileName);
      if (result != null) {
        print("not null");
      } else {
        print("null");
      }
    }
  }

  Future<void> uploadFile(var b, var n) async {
    // Replace the URL with your backend endpoint
    final url = Uri.parse(MainURL + AddfileURL);

    // Create a multipart request
    var request = http.MultipartRequest('POST', url);

    // Attach the file to the request
    request.files.add(http.MultipartFile.fromBytes('file', b, filename: n));
    request.headers['Authorization'] =
        'Bearer ${widget.prefs.getString('token')}';

    // Send the request
    var response = await request.send();

    // Handle the response
    if (response.statusCode == 200) {
      print('File uploaded successfully');
      showSnackbar(context, "file uploaded successfully");
      fetchData();
      setState(() {});
    } else {
      print('File upload failed');
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

  Future<void> fetchData() async {
    final url = Uri.parse(MainURL + my_filesURL);

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": 'Bearer ${widget.prefs.getString('token')}'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = json.decode(response.body);

        if (data != null &&
            data['message'] == "success" &&
            data['files'] != null) {
          setState(() {
            files = List<Map<String, dynamic>>.from(data['files']);
          });
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

  Future<void> _showCreateGroupDialog(BuildContext contextt) async {
    String groupName = '';

    return showDialog(
      context: contextt,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Group'),
          content: TextField(
            onChanged: (value) {
              groupName = value;
            },
            decoration: const InputDecoration(
              hintText: 'Enter Group Name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (groupName.isNotEmpty) {
                  // Call your create_group function here with the groupName
                  createGroup(groupName, contextt);
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  showSnackbar(context, "Group name Shouldn't  be empty !");
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2), // Adjust the duration as needed
        action: SnackBarAction(
          label: 'Close',
          onPressed: () {
            // Perform some action when the user presses the "Close" action
          },
        ),
      ),
    );
  }

  Future<void> createGroup(String groupName, context) async {
    final response = await http.post(
      Uri.parse(MainURL + CreateGroupURL),
      headers: {"Authorization": 'Bearer ${widget.prefs.getString('token')}'},
      body: {
        'name': groupName,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      showSnackbar(context, "Group Added Successfully!");
      setState(() {
        _fetchGroupsFromBackend();
      });
      // Future.delayed(Duration(seconds: 2))
      //     .then((value) => {Navigator.pop(context)});
    } else {
      showSnackbar(context, "Connection Error !");
    }
  }

  Future<void> _fetchGroupsFromBackend() async {
    final url = Uri.parse(MainURL + displayUserGroupsURL);
    try {
      final response = await http.get(
        url,
        headers: {"Authorization": 'Bearer ${widget.prefs.getString('token')}'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic responseData = json.decode(response.body);

        if (responseData != null && responseData.containsKey('data')) {
          final List<dynamic> data = responseData['data'];
          setState(() {
            groups = List<Map<String, dynamic>>.from(data);
            groups = groups.reversed.toList();
          });
        } else {
          // Handle the case where 'data' key is missing in the response
          print('Failed to load groups: Data key is missing in the response');
        }
      } else {
        // If the server did not return a 200 OK response, throw an exception.
        throw Exception('Failed to load groups: ${response.statusCode}');
      }
    } catch (e) {
      // Handle other exceptions
      print('Error: $e');
    }
  }

  void showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text("Attention")),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Center(
                  child: Text(
                "OK",
                style: TextStyle(color: Colors.black),
              )),
            ),
          ],
        );
      },
    );
  }

  Future<void> _delete_group(id, context) async {
    final response = await http.post(
      Uri.parse(MainURL + deleteUserGroupsURL),
      headers: {"Authorization": 'Bearer ${widget.prefs.getString('token')}'},
      body: {
        'group_id': id.toString(),
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      showSnackbar(context, "Group Deleted Successfully!");
      setState(() {
        _fetchGroupsFromBackend();
      });
    } else {
      showAlertDialog(context, "You Are Not Allowed to delete this Group");
    }
  }

  void _logout(context) {
    widget.prefs.clear();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(widget.prefs)),
    );
  }

  Future<void> addUsertoGroup(user_id, group_id, context) async {
    final response = await http.post(
      Uri.parse(MainURL + addUsertoGroupURL),
      headers: {"Authorization": 'Bearer ${widget.prefs.getString('token')}'},
      body: {
        'user_id': user_id.toString(),
        'group_id': group_id.toString(),
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context);
      showSnackbar(context, "User Added Successfully!");
    } else {
      showAlertDialog(context, "You Are Not the Owner of this Group");
    }
  }

  Future<void> _showUsersDialog(group_id, context) async {
    final response = await http.post(
      Uri.parse(MainURL + displayUsersURL),
      headers: {"Authorization": 'Bearer ${widget.prefs.getString('token')}'},
      body: {
        'group_id': group_id.toString(),
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      Map<String, dynamic> r = json.decode(response.body);

      // Extract the user data from the "data" key
      List<Map<String, dynamic>> userData =
          List<Map<String, dynamic>>.from(r['data']);

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(
                child: Text("Users", style: TextStyle(color: Colors.black))),
            content: Container(
              width: 400,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white,
              ),
              child: ListView.separated(
                itemCount: userData.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    height: 1,
                  );
                },
                itemBuilder: (context, index) {
                  final user = userData[index];
                  return ListTile(
                    title: ElevatedButton(
                      onPressed: () {
                        addUsertoGroup(user['id'], group_id, context);
                      },
                      child: Center(
                        child: Text(
                          user['name'],
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
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
                child: const Center(
                  child: Text("OK", style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          );
        },
      );
    } else {
      showAlertDialog(context, "You Are Not Allowed to delete this Group");
    }
  }

  Future<void> displayUsersInMyGroupDialog(group_id, context) async {
    final response = await http.post(
      Uri.parse(MainURL + displayUsersInMyGroupURL),
      headers: {"Authorization": 'Bearer ${widget.prefs.getString('token')}'},
      body: {
        'group_id': group_id.toString(),
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      Map<String, dynamic> r = json.decode(response.body);

      // Extract the user data from the "data" key
      List<Map<String, dynamic>> userData =
          List<Map<String, dynamic>>.from(r['data']);

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(
                child:
                    Text("Group Users", style: TextStyle(color: Colors.black))),
            content: Container(
              width: 400,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white,
              ),
              child: ListView.separated(
                itemCount: userData.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    height: 1,
                  );
                },
                itemBuilder: (context, index) {
                  final user = userData[index];
                  return ListTile(
                    title: ElevatedButton(
                      onPressed: () {
                        _delete_user_group(group_id, user['id'], context);
                      },
                      child: Center(
                        child: Text(user['name'],
                            style: const TextStyle(
                                color: Colors.black, fontSize: 20)),
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
                child: const Center(
                  child: Text("OK", style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          );
        },
      );
    } else {
      showAlertDialog(
          context, "You Are Not Allowed to Remove Users from this Group");
    }
  }

  Future<void> _delete_user_group(group_id, user_id, context) async {
    final response = await http.post(
      Uri.parse(MainURL + deleteUserfromGroupURL),
      headers: {"Authorization": 'Bearer ${widget.prefs.getString('token')}'},
      body: {
        'user_id': user_id.toString(),
        'group_id': group_id.toString(),
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context);
      showSnackbar(context, "User Removed Successfully!");
    } else {
      showAlertDialog(context, "You Are Not the Owner of this Group");
    }
  }

  Future<void> _userReports() async {
    final url = Uri.parse(MainURL + user_reportURL);
    try {
      final response = await http.get(
        url,
        headers: {"Authorization": 'Bearer ${widget.prefs.getString('token')}'},
      );
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responseData = json.decode(response.body);
        List<Map<String, dynamic>> reportsData =
            List<Map<String, dynamic>>.from(responseData['data']);

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportsScreen(reportsData),
            ));
      } else {
        // Handle the error
        print('Failed to fetch files: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> delete_file(String file_id) async {
    final response = await http.delete(
      Uri.parse(MainURL + "user/delete_file/${file_id}"),
      headers: {"Authorization": 'Bearer ${widget.prefs.getString('token')}'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      showSnackbar(context, "file deleted Successfully");
      setState(() {
        fetchData();
      });
    } else {
      Navigator.pop(context);
      showSnackbar(context, "Can't delete file because it is in use");
    }
  }
}
