import 'dart:async';
import 'dart:math';

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_100ms/Widgets/AnimatedSpriteImage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //通过屏幕的物理宽高除以屏幕的dPR（基础像素的比例）
  //来得到真实屏幕的Size
  //飞机
  Size screenSize = window.physicalSize / window.devicePixelRatio;
  double playerLeft = 0;
  double playerTop = 0;
  double playerWidth = 66;
  double playerHeight = 82;

  //子弹
  Size bulletSize = Size(20, 20);
  List bulletsData = [];

  //游戏状态      0未开始
  int gameStatus = 0;
  int gameSeconds = 0;

  //计数器初始化
  Timer updateTimer;

  //动画序号
  int playerStartIndex = 0;
  int playerEndIndex = 1;
  //player的播放次数
  int playerPlayTimes = 0;

  //刷新机制
  //渲染画布
  // （渲染画布在flutter其实已经有了，就是我们的Widget build，我们只需要在刷新时通知画布更新就可以了）
  //事件系统

  @override
  void initState() {
    gameStart();
    super.initState();
  }

  gameStart() {
    bulletsData = [];

    gameStatus = 1;
    gameSeconds = 0;
    //初始化状态
    playerStartIndex = 0;
    playerEndIndex = 1;
    playerPlayTimes = 0;

    //让他出现在屏幕中间
    playerLeft = screenSize.width / 2 - playerWidth / 2;
    playerTop = screenSize.height / 2 - playerHeight / 2;
    //60帧刷新
    updateTimer = Timer.periodic(Duration(milliseconds: 20), (timer) {

      //1000/20=50
      //tick，触发次数
      if(timer.tick%50==0){
        //每秒+1
        gameSeconds += 1;
        addGroupBullets();
      }

      if (gameStatus == 1) loop();
    });

    //添加一个子弹
    //addBullet();
    //添加一组
    addGroupBullets();
  }

  loop() {
    for (int i = 0; i < bulletsData.length; i++) {
      var bulletItem = bulletsData[i];

      //取值
      double angle = bulletItem["angle"];
      //这里用的是添加进来时判断的类型
      double speed = bulletItem["speed"];

      double bulletX = bulletItem["x"] - cos(angle) * speed;
      double bulletY = bulletItem["y"] - sin(angle) * speed;
      bulletItem["x"] = bulletX;
      bulletItem["y"] = bulletY;

      //子弹自杀
      if (isNotInScreen(bulletX, bulletY)) {
        bulletsData.remove(i);
      }

      //击中飞机
      if (isHitPlayer(bulletX, bulletY)) {
        gameOver();
      }
    }
    //playerLeft --;
    setState(() {});
  }

  gameOver() {
    //初始化计时器
    if(updateTimer.isActive)updateTimer.cancel();

    gameStatus = 0;

    playerStartIndex = 2;
    playerEndIndex = 4;
    playerPlayTimes = 1;

    setState(() {

    });
  }

  //子弹离屏自杀判断
  bool isNotInScreen(double x, double y) {
    if (x < -bulletSize.width ||
        x > screenSize.width ||
        y < -bulletSize.height ||
        y > screenSize.height) {
      return true;
    } else
      return false;
  }

  //判断碰撞
  bool isHitPlayer(double x, double y) {
    double _x =
        ((x + bulletSize.width / 2) - (playerLeft + playerWidth / 2)).abs();
    double _y =
        ((y + bulletSize.height / 2) - (playerTop + playerHeight / 2)).abs();

    double distance = sqrt(_x * _x + _y * _y);

    if (distance <= 20) {
      return true;
    } else
      return false;
  }

  //子弹
  addBullet() {
    double bulletX;
    double bulletY;
    bulletX = 0;
    bulletY = 0;

    //随机子弹出发
    if (Random().nextBool()) {
      bulletX = Random().nextDouble() * (screenSize.width + bulletSize.width) -
          bulletSize.width;
      bulletY = Random().nextBool() ? -bulletSize.height : screenSize.height;
    } else {
      bulletX = Random().nextBool() ? -bulletSize.width : screenSize.width;
      bulletY =
          Random().nextDouble() * (screenSize.height + bulletSize.height) -
              bulletSize.height;
    }

    bulletsData.add({
      "x": bulletX,
      "y": bulletY,
      //speed添加时判断类型
      "speed": 1+gameSeconds/10+Random().nextDouble()*3,
      //atan2算法
      "angle": atan2(
          ((bulletY + bulletSize.height / 2) - (playerTop + playerTop / 2)),
          (bulletX + bulletSize.width / 2) - (playerLeft + playerWidth / 2))
    });
  }

  //添加一组子弹
  addGroupBullets() {
    int groupCount = 5;
    for (int i1 = 0; i1 < groupCount; i1++) {
      addBullet();
    }
  }

  getBulletsWidget() {
    List<Widget> all = [];
    for (int i = 0; i < bulletsData.length; i++) {
      var bulletItem = bulletsData[i];
      all.add(Positioned(
        left: bulletItem["x"],
        top: bulletItem["y"],
        child: Image.asset(
          "assets/images/bullet.png",
          width: bulletSize.width,
          height: bulletSize.height,
        ),
      ));
    }
    return all;
  }

  gameTitleUI(){
    if(gameStatus==0)return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/gameover.png",width: 300,),
          ElevatedButton(onPressed: (){
                gameStart();
          }, child: Text("淦，重新挑战"))
        ],
      )
    );else return Container();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('100S'),
      ),
      //GestureDetector
      body: GestureDetector(
        onPanUpdate: (DragUpdateDetails details) {
          playerLeft += details.delta.dx;
          playerTop += details.delta.dy;
        },
        child: Container(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Text("$gameSeconds秒",style: TextStyle(color: Colors.cyan,fontSize: 40.0),),
              ),
              Positioned(
                left: playerLeft,
                top: playerTop,
                child: AnimatedSpriteImageWidget(
                    duration: Duration(milliseconds: 300),
                    spriteSize: Size(66, 82),
                    startIndex: playerStartIndex,
                    endIndex: playerEndIndex,
                    playTimes: playerPlayTimes,
                    image: Image.asset("assets/images/player.png")),
              ),
              Stack(
                children: getBulletsWidget(),
              ),
              gameTitleUI()
            ],
          ),
        ),
      ),
    );
    ;
  }
}
