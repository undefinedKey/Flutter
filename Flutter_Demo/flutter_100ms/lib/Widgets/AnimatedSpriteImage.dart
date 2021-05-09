import 'dart:async';

import 'package:flutter/widgets.dart';

class AnimatedSpriteImageWidget extends StatefulWidget {
  //传入image的参数
  final Image image;
  //传入图片尺寸
  final Size spriteSize;
  //当前播放的画面处在哪一帧
  final int startIndex;
  //动画结束帧
  final int endIndex;
  //播放的时间
  final int playTimes;
  //动画持续时常
  final Duration duration;



  AnimatedSpriteImageWidget(
      {
        this.image,
        this.spriteSize,
        this.duration,
        Key key,
        this.startIndex = 0,
        this.endIndex = 0,
        this.playTimes = 0
      }
      ) : super(key: key);


  @override
  _AnimatedSpriteImageWidgetState createState() => _AnimatedSpriteImageWidgetState();
}

class _AnimatedSpriteImageWidgetState extends State<AnimatedSpriteImageWidget> {
  //记录当前播放到哪一帧
  int currentIndex = 0;
  //记录当前动画播放到第几次
  int currentTimes = 0;
  int playTimes = 0;
  @override
  void initState() {
    currentIndex = widget.startIndex;

    //定时器
    Timer.periodic(widget.duration, (timer) {
      //逻辑（待学习）
        if(currentTimes <= widget.playTimes){
          setState(() {
            if(currentIndex >= widget.endIndex){
              if(widget.playTimes != 0)currentTimes++;
              if(currentTimes<widget.playTimes||widget.playTimes==0)currentIndex=widget.startIndex;
              else currentIndex = widget.endIndex;
            }
            else currentIndex++;
          });
        }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.playTimes != playTimes){
      playTimes = widget.playTimes;
      currentTimes = 0;
    }
    return Container(
      //Size 类型可传widget.xxx.width和height
      width: widget.spriteSize.width,
      height: widget.spriteSize.height,
      child: Stack(
        children: [
          Positioned(
              left: -widget.spriteSize.width*currentIndex,
              top: 0,
              child: widget.image,
          )
        ],
      ),
    );
  }
}
