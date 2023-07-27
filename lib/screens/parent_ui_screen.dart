
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../rsocket-engine/risolate_service/main_isolate_engine.dart';
import '/component_widgets/bottom_nav_bar.dart';
import '/component_widgets/top_stories_bar.dart';
import '/screens/windows/window_screen.dart';

class ParentUiScreen extends StatefulWidget {
  const ParentUiScreen({super.key});

  @override
  State<ParentUiScreen> createState() => _ParentUiScreenState();
}

class _ParentUiScreenState extends State<ParentUiScreen>
    with TickerProviderStateMixin {
  final PageStorageBucket _pageStorageBucket = PageStorageBucket();
  bool topBarViewable = true;
  late final AnimationController _topBarAnimationController;
  late final AnimationController _bootmNavBarAnimationController;
  int viewIndex = 0;

  @override
  void initState() {
    super.initState();
    _topBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
      reverseDuration: const Duration(milliseconds: 300),
    );
    _bootmNavBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _topBarAnimationController.addStatusListener((status) {
      Color statusBarColor = (status == AnimationStatus.dismissed)
          ? const Color.fromRGBO(174, 138, 255, 1.0) // TOP BAR COLOR
          : const Color.fromRGBO(193, 172, 229, 1.0); // BODY COLOR
      changeStatusBarColor(statusBarColor);
    });
    _topBarAnimationController.forward();
    _bootmNavBarAnimationController.forward();
  }


  @override
  void dispose() {
    _topBarAnimationController.dispose();
    _bootmNavBarAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MainIsolateEngine.engine.generalPortStream.listen((event) {
      if(event is String && event == 'CONNECTION_LOST'){
        if(mounted){
          if(!(ModalRoute.of(context)!.isCurrent)){

          }
          showModalBottomSheet(context: context, builder: (ctx){
            return Container(height: 150,
            color: Colors.white,
              child: const Center(
                child: Text('Rsocket Connection Error!'),
              ),
            );
          });
        }
      }
    });
  }
  
  void changeStatusBarColor(Color color) {
    if (mounted) {
      SystemUiOverlayStyle style = SystemUiOverlayStyle(
          statusBarColor: color,
          systemStatusBarContrastEnforced:
              false //or set color with: Color(0xFF0000FF)
          );
      SystemChrome.setSystemUIOverlayStyle(style);
    }
  }

  void showTopBar(int index) {
    if (topBarViewable && index != 0) {
      _topBarAnimationController.reverse();
      topBarViewable = false;
    } else if (!topBarViewable && index == 0) {
      _topBarAnimationController.forward();
      topBarViewable = true;
    }
  }

  /*  Indexing
      0 :   feeds
      1 :   search
      2 :   add post
      3 :   notifications
      4 :   user
   */

  void updateWindowView(int index) {
    showTopBar(index);
    setState(() {
      viewIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageStorage(
      bucket: _pageStorageBucket,
      child: LayoutBuilder(
        // Fetch Screen Size At App Startup.
        builder: (ctx, cons) {
          return Stack(
            key: const Key('stack_view'),
            children: [
              Window(
                cons: cons,
                viewIndex: viewIndex,
                key: const Key('window'),
              ),
              PositionedTransition(
                rect: RelativeRectTween(
                  begin: RelativeRect.fromLTRB(0, -90, 0, cons.maxHeight),
                  end: RelativeRect.fromLTRB(0, 0, 0, cons.maxHeight - 90),
                ).animate(CurvedAnimation(
                  parent: _topBarAnimationController,
                  curve: Curves.fastLinearToSlowEaseIn,
                )),
                child: const TopStoriesContainer(),
              ),
              PositionedTransition(
                key: const Key('nav_bar'),
                rect: RelativeRectTween(
                  begin: RelativeRect.fromLTRB(0, cons.maxHeight, 0, -80),
                  end: RelativeRect.fromLTRB(0, cons.maxHeight - 80, 0, 0),
                ).animate(CurvedAnimation(
                  parent: _bootmNavBarAnimationController,
                  curve: Curves.fastLinearToSlowEaseIn,
                )),
                child: BottomNavBar(
                  updateCurrentView: updateWindowView,
                  key: const Key('bottom_nav_bar'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }


}

