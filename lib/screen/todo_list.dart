
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:intl/intl.dart';
import 'package:todoey/helpers/database_helper.dart';
import 'package:todoey/models/task_model.dart';
import 'package:todoey/screen/add_task_screen.dart';

class ToDoList extends StatefulWidget {
  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  Future<List<Task>> _taskList;
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    _upDateTaskList();
  }

  _upDateTaskList() {
    setState(() {
    _taskList = DataBaseHelper.instnce.getTaskList();
    });
  }

  double getPercentCompleted(int first, int second) {
    if (first == 0 && second == 0) {
      return 0;
    } else {
      return first / second;
    }
  }

  Widget _buildTask(Task task) {
    return ListTile(
      title: Text(
        task.title,
        style: GoogleFonts.montserrat(
          fontSize: 16.0,
          decoration: task.status == 1
              ? TextDecoration.lineThrough
              : TextDecoration.none,
        ),
      ),
      subtitle: Text(
        '${_dateFormatter.format(task.date)} | ${task.priority}',
        style: GoogleFonts.montserrat(
          fontSize: 13.0,
          decoration: task.status == 1
              ? TextDecoration.lineThrough
              : TextDecoration.none,
        ),
      ),
      leading: GestureDetector(
        onTap: () {
          task.status == 0 ? task.status = 1 : task.status = 0;
          DataBaseHelper.instnce.updateTask(task);
          _upDateTaskList();
        },
        child: Container(
          height: 21.0,
          width: 21.0,
          margin: EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: task.status == 0 ? Colors.white : Colors.red[400],
            border: Border.all(
              width: 1.0,
              color: task.status == 0 ? Colors.black26 : Colors.red.withOpacity(0.3),
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Center(
            child: task.status == 0
                ? SizedBox.shrink()
                : Icon(
              Icons.check,
              size: 17.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
      trailing: IconButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddTaskScreen(
                  updateTaskList: _upDateTaskList,
                  task: task,
                ),
              ));
        },
        icon: Icon(
          Icons.edit,
          size: 20.0,
          color: Colors.red,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(
                updateTaskList: _upDateTaskList,
              ),
            ),
          );
        },
      ),
      body: FutureBuilder(
        future: _taskList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final int completedTaskCount = snapshot.data
              .where((Task task) => task.status == 1)
              .toList()
              .length;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 40),
            itemCount: 1 + snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(bottom: 30.0),
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        child: Image(
                          height: 40.0,
                          width: 40.0,
                          fit: BoxFit.contain,
                          image: Svg('lib/image/to_do_list_icon.svg'),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 28.0,
                            width: 28.0,
                            child: CircularProgressIndicator(
                              value: getPercentCompleted(
                                  completedTaskCount,
                                  snapshot.data.length),
                              strokeWidth: 2,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation(Colors.red.withOpacity(0.6)),
                            ),
                          ),
                          SizedBox(width: 25,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'My Tasks',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40.0,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  '$completedTaskCount of ${snapshot.data.length}',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                ),
                                Divider(
                                  thickness: 1,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
              return _buildTask(snapshot.data[index - 1]);
            },
          );
        },
      ),
    );
  }
}
