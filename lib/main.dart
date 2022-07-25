// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:offline_first/api/api_result.dart';
import 'package:offline_first/api/network_exceptions.dart';
import 'package:offline_first/data/book_order_repo.dart';
import 'package:offline_first/data/book_order_store.dart';
import 'package:offline_first/models/book_order.dart';
import 'package:offline_first/models/command.dart';
import 'package:offline_first/models/receiver_type.dart';

import 'package:offline_first/utils.dart';
import 'package:path_provider_android/path_provider_android.dart';

import 'data/bgd_repository.dart';
import 'data/bgd_task_store.dart';
import 'models/bgd_task.dart';
import 'models/order.dart';

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(CommandAdapter<BookOrder>(typeId: 1));
  Hive.registerAdapter(UploadStatusAdapter());
  Hive.registerAdapter(BookOrderAdapter());

  // Hive.registerAdapter(BgdTaskAdapter());
  // await Hive.openBox('tasks_a');
  // await Hive.openBox('tasks_b');
  await Hive.openBox<Command>('order');
  // await initializeService();
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: false,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: (service) {
        return false;
      },
    ),
  );
  // service.startService();
}

void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  Timer.periodic(Duration(seconds: 1), (timer) {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "My App Service",
        content: "Syncing${'.' * (timer.tick % 5)}",
      );
    }
  });

  service.on('stopService').listen((event) {
    print('stopping service...');
    service.stopSelf();
  });

  PathProviderAndroid.registerWith();
  await Hive.initFlutter();
  Hive.registerAdapter(BgdTaskAdapter());
  await Hive.openBox('tasks_a');
  await Hive.openBox('tasks_b');

  // await BgdRepository().postAndDequeueTask();
  // print('after first dequeue standalaone');

  BgdTaskStore().bgdStoreListenable.addListener(() async {
    if (!BgdTaskStore().isANotEmpty) {
      service.stopSelf();
    }
  });

  Connectivity().onConnectivityChanged.listen((event) async {
    await BgdRepository().postAndDequeueTask();
    print('After background service is executed');
    print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const OrderHomePage(),
    );
  }
}

class OrderHomePage extends StatefulWidget {
  const OrderHomePage({Key? key}) : super(key: key);

  @override
  State<OrderHomePage> createState() => _OrderHomePageState();
}

class _OrderHomePageState extends State<OrderHomePage> {
  final _bookOrderRepo = BookOrderRepo();
  late Future<ApiResult<List<Order>>> _orders;
  late List<Command> _commands;
  bool isUploading = false;
  bool isDeleting = false;
  BookOrder? order;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late StreamSubscription<InternetConnectionStatus> _internConnectSubscription;

  @override
  void initState() {
    super.initState();
    _orders = _bookOrderRepo.getOrders();
    _commands = _bookOrderRepo.getAllCommands();

    BookOrderStore().orderStoreListenable.addListener(() {
      _commands = _bookOrderRepo.getAllCommands();
      postOrder();
    });

    // _connectivitySubscription =
    //     Connectivity().onConnectivityChanged.listen((event) async {
    //   postOrder();
    // });

    _internConnectSubscription =
        InternetConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          postOrder();
          print('Data connection is available.');
          break;
        case InternetConnectionStatus.disconnected:
          print('You are disconnected from the internet.');
          break;
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _internConnectSubscription.cancel();
    super.dispose();
  }

  void postOrder() {
    setState(() {
      isUploading = true;
    });
    _bookOrderRepo.runCommands().then((value) {
      _orders = _bookOrderRepo.getOrders();
      setState(() {
        isUploading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: FutureBuilder(
              future: _orders,
              builder:
                  (context, AsyncSnapshot<ApiResult<List<Order>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasData) {
                  return snapshot.data!.when(
                    success: (orders) {
                      if (orders.isEmpty) {
                        return Center(
                          child: Text('No orders'),
                        );
                      }
                      return ListView.builder(
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return Dismissible(
                            child: _buildOrderItem(
                              order.customerName,
                              order.bookId,
                              context,
                            ),
                            background: Container(color: Colors.red),
                            key: ValueKey(order.id),
                            onDismissed: (direction) async {
                              await _bookOrderRepo.deleteOrders(order.id);
                              // _orders = _bookOrderRepo.getOrders();
                              // setState(() {});
                            },
                          );
                        },
                        itemCount: orders.length,
                      );
                    },
                    failure: (error) {
                      return Center(
                          child:
                              Text(NetworkExceptions.getErrorMessage(error)));
                    },
                  );
                } else {
                  return Center(
                    child: Text('No orders'),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: _commands.isEmpty
                ? Center(
                    child: Text('No pending orders'),
                  )
                : ValueListenableBuilder(
                    valueListenable: BookOrderStore().orderStoreListenable,
                    builder: (context, _, __) {
                      print('In valuelistenable');
                      return ListView.builder(
                        itemBuilder: (context, index) {
                          final order = _commands[index].data as BookOrder;
                          return _buildOrderItem(
                              order.customerName, order.bookId, context);
                        },
                        itemCount: _commands.length,
                      );
                    }),
          )
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            child: isUploading
                ? CircularProgressIndicator(
                    color: Colors.white,
                  )
                : Icon(Icons.add),
            onPressed: () async {
              final result = await showDialog<BookOrder>(
                context: context,
                builder: (context) => _buildOrderTextField(context),
              );
              if (result != null) {
                setState(() {
                  isUploading = true;
                });
                await _bookOrderRepo.storeCommand(
                    data: result, receiverType: ReceiverType.createOrder);
                setState(() {
                  isUploading = false;
                });
              }
            },
          ),
          SizedBox(width: 20),
          FloatingActionButton(
            child: Icon(Icons.refresh),
            onPressed: () async {
              // await _bgdRepository.clearAll();
              _orders = _bookOrderRepo.getOrders();
              _commands = _bookOrderRepo.getAllCommands();
              setState(() {});
            },
          ),
          SizedBox(width: 20),
          FloatingActionButton(
            child: Icon(Icons.close),
            onPressed: () async {
              await BookOrderStore().deleteAllCommands();
              setState(() {});
            },
          ),
          SizedBox(width: 20),
          FloatingActionButton(
            child: isDeleting
                ? CircularProgressIndicator(
                    color: Colors.white,
                  )
                : Icon(Icons.delete),
            onPressed: () async {
              setState(() {
                isDeleting = true;
              });
              final result = await _bookOrderRepo.getOrders();
              if (result is Success &&
                  (result as Success<List<Order>>).data.isNotEmpty) {
                for (var element in result.data) {
                  await _bookOrderRepo.deleteOrders(element.id);
                }
                _orders = _bookOrderRepo.getOrders();
              }
              setState(() {
                isDeleting = false;
              });
            },
          )
        ],
      ),
    );
  }

  AlertDialog _buildOrderTextField(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Order'),
      content: TextField(
        autofocus: true,
        decoration: InputDecoration(
            labelText: 'Customer Name', border: OutlineInputBorder()),
        onChanged: (value) {
          order = BookOrder(
            customerName: value,
            bookId: Random().nextInt(4) + 3,
          );
        },
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, null),
        ),
        TextButton(
          child: const Text('Add'),
          onPressed: () => Navigator.of(context).pop(order),
        ),
      ],
    );
  }

  Widget _buildOrderItem(
      String customerName, int bookId, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: EdgeInsets.symmetric(horizontal: 10),
      color: Colors.lightBlue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customerName,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Name",
                style: Theme.of(context)
                    .textTheme
                    .caption
                    ?.copyWith(color: Colors.white),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bookId.toString(),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Book ID",
                style: Theme.of(context)
                    .textTheme
                    .caption
                    ?.copyWith(color: Colors.white),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class BgdTaskHomePage extends StatefulWidget {
  const BgdTaskHomePage({Key? key}) : super(key: key);

  @override
  State<BgdTaskHomePage> createState() => _BgdTaskHomePageState();
}

class _BgdTaskHomePageState extends State<BgdTaskHomePage>
    with WidgetsBindingObserver {
  final _bgdRepository = BgdRepository();
  late Future<List<BgdTask>> _tasksA;
  late Future<List<BgdTask>> _tasksB;
  bool isUploading = false;
  BgdTask? task;

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    FlutterBackgroundService().invoke('stopService');
    WidgetsBinding.instance!.addObserver(this);
    _tasksA = _bgdRepository.getAllTasksA();
    _tasksB = _bgdRepository.getAllTasksB();

    BgdTaskStore().bgdStoreListenable.addListener(() {
      uploadTask();
    });

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((event) async {
      uploadTask();
    });
  }

  void uploadTask() {
    setState(() {
      isUploading = true;
    });
    _bgdRepository.postAndDequeueTask().then((value) => setState(() {
          isUploading = false;
        }));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      return;
    }
    if (state == AppLifecycleState.paused && BgdTaskStore().isANotEmpty) {
      FlutterBackgroundService().startService().then(
          (value) => FlutterBackgroundService().invoke("setAsForeground"));
    }
    if (state == AppLifecycleState.resumed &&
        await FlutterBackgroundService().isRunning()) {
      print('in resumed');
      FlutterBackgroundService().invoke('stopService');
      uploadTask();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _tasksA = _bgdRepository.getAllTasksA();
    _tasksB = _bgdRepository.getAllTasksB();
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: FutureBuilder(
                future: _tasksA,
                builder: (context, AsyncSnapshot<List<BgdTask>> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return Center(
                        child: Text('No tasks'),
                      );
                    }
                    return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final data = snapshot.data![index];
                          return Container(
                            margin: EdgeInsets.all(4),
                            padding: EdgeInsets.all(20),
                            width: double.infinity,
                            color: parseColor(data.hexCode),
                            child: Text(
                              data.title,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 36),
                            ),
                          );
                        });
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ),
          Expanded(
            child: FutureBuilder(
                future: _tasksB,
                builder: (context, AsyncSnapshot<List<BgdTask>> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return Center(
                        child: Text('No tasks'),
                      );
                    }
                    return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final data = snapshot.data![index];
                          return Container(
                            padding: EdgeInsets.all(20),
                            margin: EdgeInsets.all(4),
                            width: double.infinity,
                            color: parseColor(data.hexCode),
                            child: Text(
                              data.title,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 36),
                            ),
                          );
                        });
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          )
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            child: isUploading
                ? CircularProgressIndicator(
                    color: Colors.white,
                  )
                : Icon(Icons.add),
            onPressed: () async {
              final result = await showDialog<BgdTask>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Add task'),
                  content: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                        labelText: 'Title', border: OutlineInputBorder()),
                    onChanged: (value) {
                      task = BgdTask(
                          title: value,
                          hexCode: 'ADD8E6',
                          id: DateTime.now().toString() + '-' + value);
                    },
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context, null),
                    ),
                    TextButton(
                      child: const Text('Add'),
                      onPressed: () => Navigator.of(context).pop(task),
                    ),
                  ],
                ),
              );
              if (result != null) {
                setState(() {
                  isUploading = true;
                });
                await _bgdRepository.queueTask(result);
                setState(() {
                  isUploading = false;
                });
              }
            },
          ),
          SizedBox(width: 20),
          FloatingActionButton(
            child: Icon(Icons.close),
            onPressed: () async {
              await _bgdRepository.clearAll();
              setState(() {});
            },
          )
        ],
      ),
    );
  }
}
