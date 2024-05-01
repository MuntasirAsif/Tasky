import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tasky/Model/task.dart';
import 'package:tasky/Utils/text_style.dart';
import '../Utils/colors.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String ? _newTaskContent;
  late double _deviceHeight;
  late double _deviceWidth;
  Box ? _box;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _deviceHeight * 0.15,
        backgroundColor: titleBgColor,
        title: Text(
          'Tasky',
          style: titleStyle,
        ),
      ),
      body: _taskView(),
      floatingActionButton: _addTaskButton(),
    );
  }

  Widget _taskList() {
    List tasks =_box!.values.toList();
    return ListView.builder(itemCount:tasks.length,itemBuilder: (BuildContext context, int index){
      var task = Task.fromMap(tasks[index]);
      return ListTile(
        title: Text(
          task.content,
          style: task.isDone?taskDoneTitleStyle:taskTitleStyle,
        ),
        subtitle: Text(task.timestamp.toString()),
        trailing: task.isDone?Icon(
          Icons.check_box_outlined,
          color: completerTaskIconColor,
        ):const Icon(Icons.check_box_outline_blank),
        onTap: (){
            setState(() {
              task.isDone = !task.isDone;
              _box?.putAt(index, task.toMap());
            });
        },
        onLongPress: (){
          _box?.delete(index);
          setState(() {

          });
        },
      );
    });
  }

  Widget _taskView(){
    return FutureBuilder(future: Hive.openBox('tasks'),
        builder: (BuildContext context, AsyncSnapshot snapshot){
      if(snapshot.hasData){
        _box = snapshot.data;
        return _taskList();
      }else{
        return const Center(child: CircularProgressIndicator());
      }
    });
  }
  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: _addTaskPopup,
      child: const Icon(Icons.add),
    );
  }
  void _addTaskPopup() {
    showDialog(context: context, builder: (BuildContext context){
      return  AlertDialog(
        title: Text('Add New Task',style: popupTitleStyle,),
        content: TextField(
          onSubmitted: (value){
            if(_newTaskContent!=null){
              var task =Task(content: _newTaskContent!, timestamp: DateTime.now(), isDone: false);
              _box?.add(task.toMap());
              setState(() {
                _newTaskContent = null;
                Navigator.pop(context);
              });
            }
          },
          onChanged: (value){
            setState(() {
              _newTaskContent =value;
            });
          },
        ),
      );
    });
  }
}
