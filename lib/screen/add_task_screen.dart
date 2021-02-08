import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todoey/helpers/database_helper.dart';
import 'package:todoey/models/task_model.dart';
import 'package:slider_button/slider_button.dart';

class AddTaskScreen extends StatefulWidget {
  final Task task;
  final Function updateTaskList;

  AddTaskScreen({this.updateTaskList, this.task});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formkey = GlobalKey<FormState>();
  String _title = '';
  String _priority;
  DateTime _date = DateTime.now();
  TextEditingController _dateController = TextEditingController();
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  final List<String> _priorities = ['low', 'medium', 'high'];

  _handleDatePicker() async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
    }
    _dateController.text = _dateFormatter.format(_date);
  }

  _submit() {
    if (_formkey.currentState.validate()) {
      _formkey.currentState.save();
      print('$_title , $_date , $_priority');

      // insert the task to Database
      Task task = Task(title: _title, date: _date, priority: _priority);
      if (widget.task == null) {
        task.status = 0;
        DataBaseHelper.instnce.insertTask(task);
      } else {
        // update the task in the Database
        task.id = widget.task.id;
        task.status = widget.task.status;
        DataBaseHelper.instnce.updateTask(task);
      }

      widget.updateTaskList();
      Navigator.pop(context);
    }
  }

  _delete() {
    DataBaseHelper.instnce.deleteTask(widget.task.id);
    widget.updateTaskList();
    Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.task != null) {
      _title = widget.task.title;
      _date = widget.task.date;
      _priority = widget.task.priority;
    }
    _dateController.text = _dateFormatter.format(_date);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Theme(
        data: new ThemeData(
          primaryColor: Colors.red[200],
          primaryColorDark: Colors.red,
        ),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding:
                  const EdgeInsets.symmetric(vertical: 80.0, horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.red.withOpacity(0.3),
                              size: 22,
                            ),
                          ),
                          widget.task != null? GestureDetector(
                            onTap: _delete,
                            child: Container(
                              height: 30,
                              width: 30,
                              child: Center(
                                child: Icon(CupertinoIcons.delete,color: Colors.black,size: 22,),
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4)
                              ),

                            ),
                          ):SizedBox.shrink(),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Text(
                          'Add Task',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 38.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Form(
                        key: _formkey,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15.0),
                              child: TextFormField(
                                cursorColor: Colors.red,
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 16.0,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Title',
                                  labelStyle: TextStyle(
                                    fontSize: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                ),
                                validator: (input) => input.trim().isEmpty
                                    ? "Please enter a task title"
                                    : null,
                                onSaved: (input) {
                                  _title = input;
                                },
                                initialValue: _title,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15.0),
                              child: TextFormField(
                                controller: _dateController,
                                readOnly: true,
                                cursorColor: Colors.red,
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 16.0,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Date',
                                  labelStyle: TextStyle(
                                    fontSize: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                ),
                                onTap: _handleDatePicker,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15.0),
                              child: DropdownButtonFormField(
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.red,
                                ),
                                iconEnabledColor: Colors.red,
                                iconSize: 22.00,
                                isDense: true,
                                value: _priority,
                                items: _priorities.map((String priority) {
                                  return DropdownMenuItem(
                                    value: priority,
                                    child: Text(
                                      priority,
                                      style: GoogleFonts.montserrat(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  );
                                }).toList(),
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Priority',
                                  labelStyle: TextStyle(
                                    fontSize: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                ),
                                validator: (input) => _priority == null
                                    ? "Please select a priority level"
                                    : null,
                                onChanged: (value) {
                                  setState(() {
                                    _priority = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                  // widget.task != null
                  //     ? Container(
                  //   padding: EdgeInsets.symmetric(vertical: 15.0),
                  //   width: double.infinity,
                  //   height: 50.0,
                  //   child: FlatButton(
                  //     onPressed: _delete,
                  //     child: Text(
                  //       'Delete',
                  //       style: GoogleFonts.montserrat(
                  //           fontWeight: FontWeight.w500,
                  //           fontSize: 22.0,
                  //           color: Colors.white),
                  //     ),
                  //   ),
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(10.0),
                  //     color: Colors.red[500],
                  //   ),
                  // )
                  //     : SizedBox.shrink(),
                  Center(
                    child: SliderButton(
                      height: 55,
                      buttonSize: 50,
                      action: _submit,
                      label: Text(
                        widget.task == null
                            ? 'Slide to add Task'
                            : 'Slide to update Task',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 17),
                        textAlign: TextAlign.center,
                      ),
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.red,
                      ),
                      backgroundColor: Colors.red[500].withOpacity(0.2),
                      boxShadow: BoxShadow(
                        color: Colors.red[500].withOpacity(0.4),
                        blurRadius: 4,
                      ),
                      baseColor: Colors.red,
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
