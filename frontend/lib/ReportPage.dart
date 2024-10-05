import 'package:flutter/material.dart';

class UserReportList extends StatelessWidget {
  final List<Map<String, dynamic>> reports;

  const UserReportList(this.reports, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: reports.length,
      itemBuilder: (BuildContext context, int index) {
        return UserReportItem(reports[index]);
      },
    );
  }
}

class UserReportItem extends StatelessWidget {
  final Map<String, dynamic> report;

  const UserReportItem(this.report, {super.key});

  String removeTrailingZ(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    String formattedDateTime =
        "${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} "
        "${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)}";
    return formattedDateTime;
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(75, 10, 75, 10),
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.build,
                    color: Colors.blue, // Change to your desired color
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Operation: ${report['operation']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue, // Change to your desired color
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.black, // Change to your desired color
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Date: ${removeTrailingZ(report['date'])}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Display file name and created_at
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.file_copy,
                    color: Colors.green, // Change to your desired color
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'File Name: ${report['file']['media'][0]['name']}',
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.green), // Change to your desired color
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Colors.orange, // Change to your desired color
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Created At: ${removeTrailingZ(report['file']['created_at'])}',
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.orange), // Change to your desired color
                  ),
                ],
              ),
              // Add more fields as needed
            ],
          ),
        ),
      ),
    );
  }
}

class ReportsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> reports;

  const ReportsScreen(this.reports, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Your Reports',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 30),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: reports.length,
        itemBuilder: (BuildContext context, int index) {
          return UserReportItem(reports[index]);
        },
      ),
    );
  }
}
