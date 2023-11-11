import 'package:billd_live_flutter/api/request.dart';

class LiveRoomApi {
  static getLiveRoomList() async {
    var res = await HttpRequest.get('/live_room/list', params: {});
    return res;
  }
}
