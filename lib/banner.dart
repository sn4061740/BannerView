import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef void OnBannerClickListener<D>(int index, D itemData);
typedef Widget BuildShowView<D>(int index, D itemData);

const IntegerMax = 0x7fffffff;

class BannerView<T> extends StatefulWidget {
  final OnBannerClickListener<T> onBannerClickListener;

  //延迟多少秒进入下一页
  final int delayTime; //秒
  //滑动需要秒数
  final int scrollTime; //毫秒
  final double height;
  final List<T> data;
  final BuildShowView<T> buildShowView;

  BannerView(
      {Key key,
      @required this.data,
      @required this.buildShowView,
      this.onBannerClickListener,
      this.delayTime = 3,
      this.scrollTime = 200,
      this.height = 200.0})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => new BannerViewState();
}

class BannerViewState extends State<BannerView> {
//  double.infinity
  final pageController = new PageController(initialPage: IntegerMax ~/ 2);
  Timer timer;

  BannerViewState() {
//    print(widget.delayTime);
  }

  @override
  void initState() {
    super.initState();
    resetTimer();
  }

  resetTimer() {
    clearTimer();
    timer = new Timer.periodic(new Duration(seconds: widget.delayTime),
        (Timer timer) {
      if (pageController.positions.isNotEmpty) {
        var i = pageController.page.toInt() + 1;
        pageController.animateToPage(i == 3 ? 0 : i,
            duration: new Duration(milliseconds: widget.scrollTime),
            curve: Curves.linear);
      }
    });
  }

  clearTimer() {
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQueryData.fromWindow(ui.window).size.width;
    return new SizedBox(
        height: widget.height,
        child: widget.data.length == 0
            ? null
            : new GestureDetector(
                onTap: () {
//            print(pageController.page);
//            print(pageController.page.round());
                  widget.onBannerClickListener(
                      pageController.page.round() % widget.data.length,
                      widget.data[
                          pageController.page.round() % widget.data.length]);
                },
                onTapDown: (details) {
//            print('onTapDown');
                  clearTimer();
                },
                onTapUp: (details) {
//            print('onTapUp');
                  resetTimer();
                },
                onTapCancel: () {
                  resetTimer();
                },
                child: new PageView.builder(
                  controller: pageController,
                  physics: const PageScrollPhysics(
                      parent: const ClampingScrollPhysics()),
                  itemBuilder: (BuildContext context, int index) {
                    return widget.buildShowView(
                        index, widget.data[index % widget.data.length]);
                  },
                  itemCount: IntegerMax,
                ),
              ));
  }

  @override
  void dispose() {
    clearTimer();
    super.dispose();
  }
}
