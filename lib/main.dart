import 'package:flutter/material.dart';
import 'package:infinte_scroll/app_string.dart';
import 'package:infinte_scroll/product_model.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinite Scroll',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  List<Color> itemColors;
  bool reversed = false;
  double alignment = 0;

  final scrollDirection = Axis.horizontal;
  AutoScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text(
          "Infinite Scroll",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) => Column(
          children: <Widget>[
            positionsView,
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: list(orientation),
            ),
          ],
        ),
      ),
    );
  }

  Widget list(Orientation orientation) => ScrollablePositionedList.builder(
        itemCount: AppString.tabsAndProductsList.length,
        itemBuilder: (context, index) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                AppString.tabsAndProductsList[index].tabTitle,
                style: TextStyle(
                    color: Colors.pinkAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ),
            widgetItem(index, orientation),
          ],
        ),
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        reverse: reversed,
        scrollDirection: orientation == Orientation.portrait
            ? Axis.vertical
            : Axis.horizontal,
      );

  Widget get positionsView => ValueListenableBuilder<Iterable<ItemPosition>>(
        valueListenable: itemPositionsListener.itemPositions,
        builder: (context, positions, child) {
          int min;
          if (positions.isNotEmpty) {
            min = positions
                .where((ItemPosition position) => position.itemTrailingEdge > 0)
                .reduce((ItemPosition min, ItemPosition position) =>
                    position.itemTrailingEdge < min.itemTrailingEdge
                        ? position
                        : min)
                .index;
            _scrollToIndex(min);
          }
          return Container(
            height: 52,
            child: ListView.builder(
              scrollDirection: scrollDirection,
              controller: controller,
              itemBuilder: (c, i) {
                int index = AppString.tabsAndProductsList
                    .indexOf(AppString.tabsAndProductsList[i]);
                return AutoScrollTag(
                  key: ValueKey(index),
                  controller: controller,
                  index: index,
                  child: InkWell(
                    onTap: () {
                      _scrollToIndex(index);
                      itemScrollController.jumpTo(index: index);
                    },
                    splashColor: Colors.pinkAccent,
                    child: Column(
                      children: [
                        AnimatedContainer(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.3,
                          duration: Duration(milliseconds: 100),
                          child: Center(
                            child: Text(
                              '${AppString.tabsAndProductsList[index].tabTitle}',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: TextStyle(
                                  color: index == min
                                      ? Colors.pinkAccent
                                      : Colors.grey,
                                  fontSize: 17,
                                  fontWeight: index == min
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          height: 2,
                          width: MediaQuery.of(context).size.width * 0.3,
                          decoration: BoxDecoration(
                            color:
                                index == min ? Colors.pinkAccent : Colors.white,
                          ),
                          duration: Duration(milliseconds: 100),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: AppString.tabsAndProductsList.length,
            ),
            width: MediaQuery.of(context).size.width,
          );
        },
      );

  Future _scrollToIndex(int index) async {
    await controller.scrollToIndex(index,
        duration: Duration(milliseconds: 100),
        preferPosition: AutoScrollPosition.middle);
  }

  Widget widgetItem(int i, Orientation orientation) {
    List<ProductModel> list = AppString.tabsAndProductsList[i].listProduct;
    return Column(
        children: list.map((e) {
      return ListTile(
        title: Text(
          e.title,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "from Rs. " + e.price.toString(),
          style: TextStyle(color: Colors.black),
        ),
        trailing: Container(
          width: 50,
          height: 50,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              e.imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }).toList());
  }
}
