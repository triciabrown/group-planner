import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupCalendarPage extends StatefulWidget {
  final String groupId;

  const GroupCalendarPage({Key? key, required this.groupId}) : super(key: key);

  @override
  _GroupCalendarPageState createState() => _GroupCalendarPageState();
}

class _GroupCalendarPageState extends State<GroupCalendarPage> {
  late Map<DateTime, List<String>> _events;
  late CalendarFormat _calendarFormat;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _events = {};
    _calendarFormat = CalendarFormat.month;
    _fetchGroupEvents();
  }

  // Fetch events from Firestore and add them to the calendar
  Future<void> _fetchGroupEvents() async {
    final eventsCollection = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('events');

    final snapshot = await eventsCollection.get();

    setState(() {
      for (var doc in snapshot.docs) {
        DateTime date = (doc['date'] as Timestamp).toDate();
        String eventTitle = doc['title'] as String;

        if (_events[date] == null) {
          _events[date] = [];
        }
        _events[date]!.add(eventTitle);
      }
    });
  }

  // Function to show events on selected day
  List<String> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orangeAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: _getEventsForDay(_selectedDay).length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_getEventsForDay(_selectedDay)[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
