import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_laundry/app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  runApp(
    GetMaterialApp(
      title: 'Laundry Application',
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
