import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plan_list_demo_sqflite/models/plan_data.dart';
import 'package:plan_list_demo_sqflite/services/database_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.database;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SqfLiteDemo(),
    );
  }
}

class SqfLiteDemo extends StatefulWidget {
  const SqfLiteDemo({super.key});

  @override
  State<SqfLiteDemo> createState() => _SqfLiteDemoState();
}

class _SqfLiteDemoState extends State<SqfLiteDemo> {
  TextEditingController planDurationController = TextEditingController();
  TextEditingController planTypeController = TextEditingController();
  late Future<List<PlanItem>> planItems;
  @override
  void initState() {
    planItems = DatabaseService.plans();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, setState) {
                return SimpleDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: SizedBox(
                        height: 180,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: planDurationController,
                              decoration: InputDecoration(
                                  label: const Text('Plan Duration'),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: planTypeController,
                              decoration: InputDecoration(
                                  label: const Text('Plan Type'),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            ElevatedButton.icon(
                                onPressed: () async {
                                  await DatabaseService.insertPlan(
                                    PlanItem(
                                      planDuration: planDurationController.text,
                                      planType: planTypeController.text,
                                    ),
                                  );
                                  setState(() {});

                                  WidgetsBinding.instance
                                      .addPostFrameCallback((timeStamp) {
                                    Navigator.pop(context);
                                  });
                                },
                                icon: const Icon(Icons.save),
                                label: const Text('Save')),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              });
            },
          );
        },
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) => Container(
                      // height: 20,
                      // color: Colors.red,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(snapshot.data![index].planDuration),
                              Text(snapshot.data![index].planType)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await DatabaseService.updatePlan(PlanItem(
                                      id: snapshot.data![index].id,
                                      planDuration: 'planDuration',
                                      planType: 'planType'));
                                  setState(() {});
                                },
                                child: const Text('Edit'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  print(
                                      '==============>${snapshot.data![index].id!}<==============');

                                  await DatabaseService.deletePlan(
                                      snapshot.data![index].id!);
                                  snapshot.data!.removeAt(index);
                                  setState(() {});
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    MaterialButton(
                      onPressed: () async {
                        await DatabaseService.deleteAllPlans();
                        setState(() {});
                      },
                      child: const Text('DeleteAll Data'),
                    ),
                    MaterialButton(
                      onPressed: () async {
                        final dbFolder = await getDatabasesPath();
                        File source1 = File('$dbFolder/doggie_database.db');

                        Directory copyTo =
                            Directory("storage/emulated/0/Sqlite Backup");
                        if ((await copyTo.exists())) {
                          // print("Path exist");
                          var status = await Permission.storage.status;
                          if (!status.isGranted) {
                            await Permission.storage.request();
                          }
                        } else {
                          print("not exist");
                          if (await Permission.storage.request().isGranted) {
                            // Either the permission was already granted before or the user just granted it.
                            await copyTo.create();
                          } else {
                            print('Please give permission');
                          }
                        }

                        String newPath = "${copyTo.path}/doggie_database.db";
                        await source1.copy(newPath);

                        setState(() {
                          // message = 'Successfully Copied DB';
                        });
                      },
                      child: const Text('Backup Database'),
                    ),
                    MaterialButton(
                      onPressed: () async {},
                      child: const Text('Restore Database'),
                    ),
                  ],
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('There Is No Data'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        future: planItems,
      ),
    );
  }
}
