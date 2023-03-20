import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:android_package_manager/android_package_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {

  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  void initState() {
    super.initState();
    AndroidPackageManager().getInstalledApplications().then(
      (value) => setState(
        () => _applicationInfoList = value,
      ),
    );
  }

  void _testSourceInstallInfo(String packageName) async {
    final pm = AndroidPackageManager();
    final sourceInfo = await pm.getApplicationEnabledSetting(packageName: packageName);
    print('package name : ${packageName} enabledSEtting : $sourceInfo!');
  }

  @override
  Widget build(BuildContext context) {

    final appInfo = _applicationInfoList;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Android Package Manager Demo",),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0, vertical: 32.0,
        ),
        itemBuilder: (_, index,) {
          final info = appInfo![index];

          if (info.packageName!.contains('com.telkomsel')) {
            _testSourceInstallInfo(info.packageName!);
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
              ),
              child: Card(
                child: ListTile(
                  leading: SizedBox.square(
                    dimension: 48.0,
                    child: FutureBuilder<Uint8List?>(
                      future: info.getAppIcon(),
                      builder: (context, snapshot,) {
                        if (snapshot.hasData) {
                          final iconBytes = snapshot.data!;
                          return Image.memory(
                            iconBytes,
                            fit: BoxFit.fill,
                          );
                        }
                        if (snapshot.hasError) {
                          return const Icon(Icons.error, color: Colors.red,);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  title: Text(info.name ?? "No Name",),
                  subtitle: Text(info.packageName ?? "-",),
                ),
              ),
            );
          } else {
            return Container();
          }

        },
        itemCount: appInfo?.length ?? 0,
      ),
    );
  }

  List<ApplicationInfo>? _applicationInfoList;
}