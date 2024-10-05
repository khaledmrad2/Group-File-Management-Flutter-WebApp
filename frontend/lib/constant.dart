import 'package:flutter/material.dart';

String MainURL = "http://127.0.0.1:8000/api/", LoginURL = "user_login";
Map<String, String> SendHeaders = {"Accept": "application/json"};
// Map<String, String> SendHeaders2 = {"Authorization": 'Bearer ${user.token}'};
String registerURL = "register";
String AddfileURL = "user/add_file";
String my_filesURL = "user/my_files";
String CreateGroupURL = "user/addGroupUser";
String displayUserGroupsURL = "user/displayUserGroups";
String deleteUserGroupsURL = "user/deleteFromUserGroup";
String displayUsersURL = "displayUsers";
String addUsertoGroupURL = "user/ownerAddsUsersToGroup";
String deleteUserfromGroupURL = "user/ownerDeletedUsersFromGroup";
String displayUsersInMyGroupURL = "user/displayUsersInMyGroup";
String AddFileToGroupUserURL = "user/addFileToGroupUser";
String DeleteFileFromGroupUserURL = "user/deleteFileFromGroupUser";
String check_inURL = "user/check_in";
String Edit_fileURL = "user/edit_file";
String bulk_check_inURL = "user/bulk_check_in";
String user_reportURL = "user/user_report";

void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2), // Adjust the duration as needed
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          // Perform some action when the user presses the "Close" action
        },
      ),
    ),
  );
}
