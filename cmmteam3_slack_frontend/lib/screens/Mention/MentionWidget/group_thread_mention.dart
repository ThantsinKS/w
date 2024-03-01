import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_frontend/constants.dart';
import 'package:flutter_frontend/progression.dart';
import 'package:flutter_frontend/services/mentionlistsService/mention_lists_service.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class GroupThreads extends StatefulWidget {
  const GroupThreads({super.key});

  @override
  State<GroupThreads> createState() => _GroupThreadState();
}

class _GroupThreadState extends State<GroupThreads> {
  MentionListsService mentionListsService = MentionListsService();

  late Future<void> _refreshFuture;

  @override
  void initState() {
    super.initState();
    _refreshFuture = _fetchData();
  }
  Future<void> _fetchData() async {
    await mentionListsService.mentionList();
  }
  Future<void> _refresh() async {
    setState(() {
      _refreshFuture = _fetchData();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
         child: FutureBuilder(
            future: mentionListsService.mentionList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ProgressionBar(
                  imageName: 'loading.json',height: 200,
                  size: 200,
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error : ${snapshot.error}'),
                );
              } else if (snapshot.data!.groupThread == null ||
                  snapshot.data!.groupThread!.isEmpty) {
                return const ProgressionBar(imageName: 'dataSending.json',height: 200,
                  size: 200,);
              } else {
                return LiquidPullToRefresh(
                  onRefresh: _refresh,
                  color: Colors.blue.shade100,
                  animSpeedFactor: 100,
                  showChildOpacityTransition: true,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.groupThread!.length,
                          itemBuilder: (context, index) {
                           String dateFormat = snapshot.data!.groupThread![index].createdAt.toString();
                            DateTime dateTime = DateTime.parse(dateFormat);
                            String time = DateFormat('yyyy-MM-dd').format(dateTime);
                            String name = snapshot.data!.groupThread![index].name.toString();
                            String groupthreadmsg = snapshot.data!.groupThread![index].groupthreadmsg.toString();
                            String channelName = snapshot.data!.groupThread![index].channelName.toString();
                            return Card(
                              color: Colors.blueGrey,
                              child: ListTile(
                                leading: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.brown.shade400,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border(
                                      top: BorderSide(color: Colors.white),
                                      bottom: BorderSide(color: Colors.white),
                                    )
                                  ),
                                  
                                  child: Center(child: Text(name.characters.first.toUpperCase(),
                                  style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.white),)),
                                ),
                                title: Text(groupthreadmsg,style: TextStyle(color: Colors.white),),
                                subtitle: Text(time,style: TextStyle(color: Colors.white),),
                                trailing: Text(channelName,style: TextStyle(color: Colors.white,fontSize: 15),),
                                   
                                 
                                
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}