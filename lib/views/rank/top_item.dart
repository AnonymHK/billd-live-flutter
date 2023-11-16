import 'package:billd_live_flutter/main.dart';
import 'package:billd_live_flutter/views/room/room.dart';
import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';

const one = Color.fromRGBO(255, 103, 68, 1);
const two = Color.fromRGBO(68, 214, 255, 1);
const three = Color.fromRGBO(255, 178, 0, 1);

enum NumEnum { one, two, three }

final colorMap = {NumEnum.one: one, NumEnum.two: two, NumEnum.three: three};

class TopItem extends StatelessWidget {
  final NumEnum rankNum;
  final item;

  const TopItem({
    required this.rankNum,
    required this.item,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const width = 126.0;
    return GestureDetector(
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            width: width,
            height: width,
          ),
          Positioned(
              width: width,
              child: Column(
                children: [
                  Container(
                      transform: Matrix4.translationValues(0, -40, 0),
                      width: 80,
                      height: 80,
                      child: item['user_avatar'] == ''
                          ? Container(
                              decoration: const BoxDecoration(
                                color: themeColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40)),
                              ),
                            )
                          : CircleAvatar(
                              backgroundImage:
                                  NetworkImage(item['user_avatar']),
                            ))
                ],
              )),
          Positioned(
              width: width,
              child: Column(
                children: [
                  Container(
                    height: 20,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    transform: Matrix4.translationValues(0, 45, 0),
                    child: Text(
                      item['user_username'],
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: colorMap[rankNum]!,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )),
          Positioned(
              width: width,
              child: Column(
                children: [
                  Container(
                    transform: Matrix4.translationValues(0, 70, 0),
                    padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(color: colorMap[rankNum]!)),
                    child: rankNum == NumEnum.one
                        ? const Text(
                            '01',
                            style: TextStyle(
                                color: one, fontWeight: FontWeight.bold),
                          )
                        : rankNum == NumEnum.two
                            ? const Text(
                                '02',
                                style: TextStyle(
                                    color: two, fontWeight: FontWeight.bold),
                              )
                            : const Text(
                                '03',
                                style: TextStyle(
                                    color: three, fontWeight: FontWeight.bold),
                              ),
                  ),
                ],
              )),
          Positioned(
              width: width,
              child: Column(
                children: [
                  item['live'] != null
                      ? Container(
                          transform: Matrix4.translationValues(0, 98, 0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: themeColor),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                          width: 45,
                          child: Container(
                              transform: Matrix4.translationValues(0, -1, 0),
                              child: const Text(
                                '直播中',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: themeColor),
                              )),
                        )
                      : Container()
                ],
              )),
        ],
      ),
      onTap: () {
        if (item['live'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Room(
                hlsurl: item['hls_url'],
                avatar: item['user_avatar'],
                username: item['user_username'],
              ),
            ),
          );
        } else {
          BrnToast.show('当前房间未在直播', context);
        }
      },
    );
  }
}
