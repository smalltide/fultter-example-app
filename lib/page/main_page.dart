
import 'package:flutter/material.dart';
// 页面
import 'package:zmz_app/page/home/home_page.dart';
import 'package:zmz_app/page/treasure/treasure_page.dart';
import 'package:zmz_app/page/customer/customer_page.dart';
import 'package:zmz_app/page/news/news_page.dart';
// 请求
import 'package:zmz_app/api/my_xhr.dart';
// 更新App操作
import 'package:zmz_app/unit/update_app.dart';
// 功能
import 'package:zmz_app/unit/common/center_nav.dart';

class MainPage extends StatefulWidget {
  final String title;
  MainPage({Key key, this.title}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

// 可以 with AutomaticKeepAliveClientMixin
// 然后重写 bool get wantKeepAlive => true
// 但是：body中并没有使用PageView或TabBarView 会使 wantKeepAlive无效果
class _MainPageState extends State<MainPage> {

  int _selectedIndex = 0;

  // 并不是 GlobalKey 类型
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  // 暂时先利用 cache 处理 IndexedStack 页面全部初始化问题
  List _indexedStackCache = <int>[0];

  // 初始化 请求的baseURL
  void setBaseUrl () {
    MyXhr myXhr = new MyXhr();
    // myXhr.$option(baseUrl: 'http://10.93.157.7:2333');
    myXhr.$option(baseUrl: 'https://223b312f.ngrok.io');
  }

  // bottomNavigationBar 点击事件
  void _tapBottomBar (index) {
    // Unhandled exception: setState() called after dispose()
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedIndex = index;
      if (_indexedStackCache.indexOf(index) == -1) {
        _indexedStackCache.add(index);
      }
    });
  }
  
  void checkAppVersion() {
    UpdateApp _updateApp = new UpdateApp();
    // 可以在第一次打开APP时执行"版本更新"的网络请求
    _updateApp.getApkLocalInfo().then((directory) {
      String _version = directory['version'];
      // 比较服务器的版本号跟当前的版本号，来判断要不要升级APP应用程序
      if (_updateApp.checkVersionLowerOf(_version)) {
        String _appPath = directory['url'];
        // 弹出dalog询问是否升级
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('提示'),
              content: Text('有优化更新，赶紧体验一下吧。'),
              actions: [
                RaisedButton(
                  textColor: Colors.white,
                  child: Text('取消'),
                  onPressed: () {
                    Navigator.maybePop(context);
                  },
                ),
                RaisedButton(
                  textColor: Colors.white,
                  child: Text('确定'),
                  onPressed: () {
                    // 下载 并 安装新版本
                    _updateApp.executeDownload(_appPath);
                    Navigator.maybePop(context);
                  },
                )
              ]
            );
          }
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // 设置基础URL信息
    setBaseUrl();
    checkAppVersion();
  }
   static const double offset = 15.0; // offset为正时，表示往下偏移；offset为负时，表示往上偏移

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: new BottomNavigationBar( // 底部导航
        type: BottomNavigationBarType.fixed, // 如果有4个bar那么必须要设置type，可能是BUG
        backgroundColor: Colors.white,
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('首页')),
          new BottomNavigationBarItem(icon: Icon(Icons.payment), title: Text('财富')),
          new BottomNavigationBarItem(icon: Icon(null), title: Text('')), // 空BottomNav
          new BottomNavigationBarItem(icon: Icon(Icons.book), title: Text('资讯')),
          new BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('我的')),
        ],
        currentIndex: _selectedIndex,
        fixedColor: Colors.blue,
        onTap: _tapBottomBar,
      ),
      // IndexedStack 显示第index个child，其它child在页面上是不可见的
      // 但是 每个人page会在IndexedStack初始化的时候都会调用接口
      body: new IndexedStack(
        index: _selectedIndex,
        // child: _distributeHome(),
        children: <Widget>[
          new HomePage(),
          // 暂时先利用 cache 处理 IndexedStack 页面全部初始化问题
          (_indexedStackCache.indexOf(1) != -1) ? new TreasurePage() : Container(),
          Container(), // 空BottomNav对应页面
          (_indexedStackCache.indexOf(3) != -1) ? new NewsPage() : Container(),
          (_indexedStackCache.indexOf(4) != -1) ? new CustomerPage() : Container(),
        ],
      ),
      floatingActionButton: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Colors.transparent
          ),
          borderRadius: BorderRadius.all(Radius.circular(55)),
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0, -1),
              blurRadius: 0.1,
              spreadRadius: 0
            )
          ]
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: Icon(Icons.add, color: Colors.white,),
          onPressed: (){
          },
        ),
      ),
      // const 很重要，不然每次点击BottomNav就会被重写一次
      floatingActionButtonLocation: const CenterNav()
    );
  }
}
