import 'package:billd_live_flutter/components/BackListener/index.dart';
import 'package:billd_live_flutter/utils/index.dart';
import 'package:flutter/material.dart';

class Rank extends StatelessWidget {
  const Rank({super.key});

  @override
  Widget build(BuildContext context) {
    return const RankBody();
  }
}

class RankBody extends StatefulWidget {
  const RankBody({super.key});

  @override
  State<StatefulWidget> createState() => RankBodyState();
}

class RankBodyState extends State<RankBody> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text('rank');
  }
}
