
import 'package:workmanager/workmanager.dart';

const taskName = "firstTask";
void callbackDispatcher(){
  Workmanager().executeTask((taskName, inputData){
    switch(taskName){
      case 'firstTask':
        sendGreeting();
        break;
    }
    return Future.value(true);
  });
}

sendGreeting(){
  print('HIIIIIIIIIIIIIIIIIII');
  print('HIIIIIIIIIIIIIIIIIII');
  print('HIIIIIIIIIIIIIIIIIII');
  print('HIIIIIIIIIIIIIIIIIII');
  print('HIIIIIIIIIIIIIIIIIII');
  print('HIIIIIIIIIIIIIIIIIII');
  print('HIIIIIIIIIIIIIIIIIII');
  print('HIIIIIIIIIIIIIIIIIII');
  print('HIIIIIIIIIIIIIIIIIII');
  print('HIIIIIIIIIIIIIIIIIII');
  print('HIIIIIIIIIIIIIIIIIII');
  print('HIIIIIIIIIIIIIIIIIII');
  print('HIIIIIIIIIIIIIIIIIII');
  print('HIIIIIIIIIIIIIIIIIII');
  print('HIIIIIIIIIIIIIIIIIII');
  print('HIIIIIIIIIIIIIIIIIII');
}