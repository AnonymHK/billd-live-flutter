import 'dart:async';
import 'dart:math';

import 'package:billd_live_flutter/utils/index.dart';
import 'package:billd_live_flutter/api/live_api.dart';
import 'package:billd_live_flutter/api/srs_api.dart';
import 'package:billd_live_flutter/stores/app.dart';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:bruno/bruno.dart';
import 'package:get/get.dart' as get_x;

class WebRTCWidget extends StatefulWidget {
  const WebRTCWidget({super.key});

  @override
  createState() => RTCState();
}

enum LIVE_STATUS { nolive, living }

class RTCState extends State<WebRTCWidget> {
  RTCVideoRenderer? _localRenderer;
  RTCPeerConnection? _pc;
  bool showIcon = true;
  MediaStream? _stream;
  final Controller store = get_x.Get.put(Controller());

  var mode = [
    {'label': '后置', 'value': 'back'},
    {'label': '前置', 'value': 'front'},
    {'label': '屏幕', 'value': 'screen'},
  ];

  var modeIndex = 0;
  int countdown = 3;
  LIVE_STATUS liveStatus = LIVE_STATUS.nolive;

  @override
  initState() {
    print('initState-webrtc');
    super.initState();
  }

  handleOffer() async {
    // _pc!.addTransceiver(
    //   kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
    //   init: RTCRtpTransceiverInit(direction: TransceiverDirection.SendRecv),
    // );
    // _pc!.addTransceiver(
    //   kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
    //   init: RTCRtpTransceiverInit(direction: TransceiverDirection.SendRecv),
    // );
    try {
      var offer = await _pc!.createOffer({});
      await _pc!.setLocalDescription(offer);
      var liveRoomInfo = store.userInfo['live_rooms'][0];
      print('offer成功');
      String streamurl =
          '${liveRoomInfo['rtmp_url']}?token=${liveRoomInfo['key']}&type=2';
      var srsres = await SRSApi.getRtcV1Publish(
          api: '/rtc/v1/publish/',
          sdp: offer.sdp,
          streamurl: streamurl,
          tid: Random().nextDouble().toString().substring(2));
      if (srsres['data']['code'] == 400) {
        if (context.mounted) {
          BrnToast.show('推流错误', context);
        }
        return;
      }
      return srsres['data']['sdp'];
    } catch (e) {
      print(e);
      print('offer失败');
    }
  }

  handleAnswer(sdp) async {
    try {
      await _pc!.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
      print('设置远程描述成功');
    } catch (e) {
      print('设置远程描述失败');
      print(e);
    }
  }

  handleStream() async {
    var stream;
    try {
      if (mode[modeIndex]['value'] == 'front') {
        stream = await navigator.mediaDevices.getUserMedia({
          'video': {
            // 'mandatory': {
            //   'maxWidth': '1280', // 设置最大宽度
            //   'maxHeight': '720', // 设置最大高度
            // },
            'facingMode': 'user', // 指定前置摄像头
          },
          'audio': true,
          'facingMode': 'user', // 指定前置摄像头
        });
      } else if (mode[modeIndex]['value'] == 'back') {
        stream = await navigator.mediaDevices.getUserMedia({
          'video': {
            // 'mandatory': {
            //   'maxWidth': '1280', // 设置最大宽度
            //   'maxHeight': '720', // 设置最大高度
            // },
            'facingMode': 'environment', // 指定后置摄像头
          },
          'audio': true,
        });
      } else if (mode[modeIndex]['value'] == 'screen') {
        stream = await navigator.mediaDevices.getDisplayMedia({
          'video': true,
          'audio': true,
        });
      }
      if (stream != null) {
        stream.getTracks().forEach((track) async {
          await _pc?.addTrack(track, stream);
        });
        setState(() {
          _stream = stream;
          _localRenderer!.srcObject = stream;
        });
      }
    } catch (e) {
      print(e);
      if (context.mounted) {
        BrnToast.show('拒绝授权', context);
      }
    }
  }

  Future<bool> startForegroundService() async {
    const androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: 'Title of the notification',
      notificationText: 'Text of the notification',
      notificationImportance: AndroidNotificationImportance.Default,
      notificationIcon: AndroidResource(
          name: 'background_icon',
          defType: 'drawable'), // Default is ic_launcher from folder mipmap
    );
    await FlutterBackground.initialize(androidConfig: androidConfig);
    return FlutterBackground.enableBackgroundExecution();
  }

  handleCloseLive() async {
    if (_pc != null) {
      _pc!.close();
      _pc = null;
    }
    if (_stream != null) {
      _stream!.dispose();
      _stream = null;
    }
    if (_localRenderer != null) {
      _localRenderer!.srcObject = null;
      _localRenderer!.dispose();
      _localRenderer = null;
    }
    await LiveApi.getCloseLive();
  }

  handleInit() async {
    await startForegroundService();
    _localRenderer = RTCVideoRenderer();
    await _localRenderer!.initialize();
    if (_pc != null) {
      await _pc!.close();
    }
    var res = await LiveApi.getIsLive();
    if (res['data'].length == 0) {
      _pc = await createPeerConnection({
        // 'iceServers': [
        //   {
        //     'urls': 'turn:hsslive.cn:3478',
        //     'username': 'hss',
        //     'credential': '123456',
        //   },
        //   // {
        //   //   'urls': 'stun:stun.l.google.com:19302',
        //   // },
        // ]
        // 'sdpSemantics': "unified-plan" //加不加好像都可以
      });
      await handleStream();
      var sdp = await handleOffer();
      if (sdp != null) {
        handleAnswer(sdp);
      } else {
        if (context.mounted) {
          BrnToast.show('offer错误', context);
        }
      }
    } else {
      if (context.mounted) {
        BrnDialogManager.showConfirmDialog(context,
            title: "提示",
            cancel: '取消',
            confirm: '确定',
            message: "当前正在直播，是否先断开直播？", onConfirm: () async {
          await LiveApi.getCloseLive();
          if (context.mounted) {
            BrnToast.show('断开直播成功', context);
            Navigator.pop(context, true);
          }
        }, onCancel: () {
          Navigator.pop(context, false);
        });
      }
    }
  }

  @override
  void dispose() {
    // 移除监听订阅
    super.dispose();
    handleCloseLive();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double height =
        size.height - kBottomNavigationBarHeight - store.safeHeight.value;

    return Column(
      children: [
        SizedBox(
          height: height - 100,
          width: size.width,
          child: _localRenderer != null
              ? RTCVideoView(
                  _localRenderer!,
                  // mirror: true,
                )
              : null,
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            children: <Widget>[
              const SizedBox(
                width: 5,
              ),
              const Text("直播方式："),
              BrnRadioButton(
                radioIndex: 0,
                isSelected: modeIndex == 0,
                child: const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    "前置摄像头",
                  ),
                ),
                onValueChangedAtIndex: (index, value) {
                  setState(() {
                    modeIndex = index;
                  });
                },
              ),
              const SizedBox(
                width: 20,
              ),
              BrnRadioButton(
                radioIndex: 1,
                isSelected: modeIndex == 1,
                child: const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    "后置摄像头",
                  ),
                ),
                onValueChangedAtIndex: (index, value) {
                  setState(() {
                    modeIndex = index;
                  });
                },
              ),
              const SizedBox(
                width: 20,
              ),
              BrnRadioButton(
                radioIndex: 2,
                isSelected: modeIndex == 2,
                child: const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    "屏幕",
                  ),
                ),
                onValueChangedAtIndex: (index, value) {
                  setState(() {
                    modeIndex = index;
                  });
                },
              ),
            ],
          ),
        ),
        BrnBigGhostButton(
          title: '开始直播$countdown',
          onTap: () async {
            BrnDialogManager.showConfirmDialog(context,
                title: '提示',
                cancel: '取消',
                confirm: '确认',
                message: '是否开播', onConfirm: () async {
              Navigator.pop(context, true);
              BrnLoadingDialog.show(context, content: '$countdown');
              Timer.periodic(const Duration(seconds: 1), (timer) {
                // BrnLoadingDialog.dismiss(context);
                // BrnLoadingDialog.show(context, content: '$countdown');
                setState(() {
                  countdown -= 1;
                });
                if (countdown <= 0) {
                  timer.cancel();
                }
              });
              await LiveApi.getCloseLive();
              await Future.delayed(const Duration(seconds: 3), () {
                BrnLoadingDialog.dismiss(context);
                if (context.mounted) {
                  BrnToast.show('直播！', context);
                }
              });
              handleInit();
            }, onCancel: () {
              Navigator.pop(context, false);
            });
          },
        ),
        BrnBigGhostButton(
          bgColor: const Color.fromRGBO(244, 67, 54, 0.2),
          titleColor: const Color.fromRGBO(244, 67, 54, 1),
          title: '关闭直播',
          onTap: () {
            BrnDialogManager.showConfirmDialog(context,
                barrierDismissible: false,
                title: '提示',
                message: '确定关闭直播？',
                cancel: '取消',
                confirm: '确定',
                onCancel: () => {Navigator.pop(context)},
                onConfirm: () {
                  setState(() {
                    BrnToast.show('关闭直播成功', context);
                    handleCloseLive();
                    Navigator.pop(context);
                  });
                });
          },
        ),
      ],
    );
  }
}

class Live extends StatelessWidget {
  const Live({super.key});

  @override
  Widget build(BuildContext context) {
    handleRequestPermissions();
    return const SafeArea(
        child: Scaffold(
      body: WebRTCWidget(),
    ));
  }
}
