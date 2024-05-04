import 'dart:convert';

import 'package:cachdatabase/localdb/dbprovider.dart';
import 'package:cachdatabase/module/extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'datamodel/user_model.dart';

abstract class DataState{}
class Loading extends DataState{}
class Loaded extends DataState{
  final List<User> users;

  Loaded(this.users);
}
class Failed extends DataState{
  final String error;
  Failed(this.error);
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DataState state = Loading();

  void loadData()async{
    try{
      setState(() {
        state = Loading();
      });
      final res = await http.get(Uri.parse('https://dummyjson.com/users'), headers: {});
      debugPrint('server loaded');
      final Map<String, dynamic> mp = json.decode(utf8.decode(res.bodyBytes));
      if (mp.containsKey('users')){
        final rows = (mp['users'] as List<dynamic>).map((e) => User.fromJson((e as Map<String, dynamic>).toLower())).toList();
        setState(()=>state = Loaded(rows));
        DBProvider.db.addUsers(rows);
      }
      else{
        setState(() {
          state = Failed('users key not found');
        });
      }
    }
    catch(e){
      try{
        final rows = await DBProvider.db.loadUsers();
        setState((){
          state = Loaded(rows);
        }); 
      }
      catch(f){
        setState(() {          
          state = Failed('error getting data: $e - $f');
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache Data'),
        leading: IconButton(
          icon: const Icon(Icons.replay_outlined),
          onPressed: loadData, 
        ),
      ),
      body: state is Loading
        ? const Center(
            child: CupertinoActivityIndicator(),
          )
        : state is Failed
          ? Center(
              child: Text((state as Failed).error),
            ) 
          : ListView.separated(
              itemCount: (state as Loaded).users.length,
              itemBuilder: (_, idx){
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage((state as Loaded).users[idx].image ?? 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/User-avatar.svg/2048px-User-avatar.svg.png'),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 25,
                      child: Text('${(state as Loaded).users[idx].id}'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: Text('${(state as Loaded).users[idx].firstName} ${(state as Loaded).users[idx].lastName}'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('${(state as Loaded).users[idx].phone}'),
                    ),
                  ],
                );
              },
              separatorBuilder: (_, idx)=>const Divider(),
            ),
    );
  }
}