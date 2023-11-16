import 'dart:async';

import 'package:billd_live_flutter/main.dart';
import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

handleRequestPermissions() async {
  var camerastatus = await Permission.camera.status;
  if (camerastatus.isDenied) {
    print('没有camera权限');
    await Permission.camera.request();
  }
  var microphonestatus = await Permission.microphone.status;
  if (microphonestatus.isDenied) {
    print('没有microphone权限');
    await Permission.microphone.request();
  }
  var manageExternalStoragestatus =
      await Permission.manageExternalStorage.status;
  if (manageExternalStoragestatus.isDenied) {
    print('没有manageExternalStorage权限');
    await Permission.manageExternalStorage.request();
  }
  var mediaLibrarystatus = await Permission.mediaLibrary.status;
  if (mediaLibrarystatus.isDenied) {
    print('没有mediaLibrary权限');
    await Permission.mediaLibrary.request();
  }
  var ignoreBatteryOptimizationsstatus =
      await Permission.ignoreBatteryOptimizations.status;
  if (ignoreBatteryOptimizationsstatus.isDenied) {
    print('没有ignoreBatteryOptimizations权限');
    await Permission.ignoreBatteryOptimizations.request();
  }
}

Future<bool> billdModal(context,
    {String? title = '提示',
    String? cancel = '取消',
    String? confirm = '确认',
    String? message = '是否退出billd直播？'}) {
  Completer<bool> completer = Completer<bool>();
  BrnDialogManager.showConfirmDialog(context,
      title: title,
      cancel: cancel!,
      confirm: confirm!,
      message: message, onConfirm: () {
    completer.complete(true);
    Navigator.pop(context, true);
  }, onCancel: () {
    completer.complete(false);
    Navigator.pop(context, false);
  });
  // 返回Future对象
  return completer.future;
}

fullLoading() {
  return Scaffold(
    body: SafeArea(
      child: Container(
          alignment: Alignment.center,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const CircularProgressIndicator(
              color: themeColor,
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 15, 0, 0),
              child: const Text('加载中...'),
            )
          ])),
    ),
  );
}
