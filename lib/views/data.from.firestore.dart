import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart';
import 'package:quranirab/facebook/screens/Translation/translation.dart';
import 'package:quranirab/facebook/widgets/more_options_list.dart';
import 'package:quranirab/models/font.size.dart';
import 'package:quranirab/quiz_module/quiz.dart';
import 'package:quranirab/quiz_module/quiz.home.dart';
import 'package:quranirab/theme/theme_provider.dart';
import 'package:quranirab/widget/LanguagePopup.dart';
import 'package:quranirab/widget/TranslationPopup.dart';
import 'package:quranirab/widget/menu.dart';
import 'package:quranirab/widget/setting.popup.dart';
import 'package:quranirab/widget/responsive.dart' as w;

class DataFromFirestore extends StatefulWidget {
  const DataFromFirestore({Key? key}) : super(key: key);

  @override
  _DataFromFirestoreState createState() => _DataFromFirestoreState();
}

class _DataFromFirestoreState extends State<DataFromFirestore> {
  late AsyncMemoizer _memoizer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _memoizer = AsyncMemoizer();
    getData();
  }

  List _list = [];
  final CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('suras');

  Future<void> getData() => _memoizer.runOnce(() async {
        // Get docs from collection reference
        QuerySnapshot querySnapshot =
            await _collectionRef.orderBy('created_at').get();

        // Get data from docs and convert map to List
        final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
        setState(() {
          _list = allData;
        });
      });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontsize = Provider.of<FontSizeController>(context);
    return Scaffold(
      backgroundColor:
          themeProvider.isDarkMode ? const Color(0xff666666) : Colors.white,
      drawer: const Menu(),
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (context, value) {
          return [
            SliverAppBar(
              iconTheme: Theme.of(context).iconTheme,
              leading: IconButton(
                icon: const Icon(
                  Icons.menu,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: const CircleAvatar(
                backgroundImage: AssetImage('assets/quranirab.png'),
                radius: 18.0,
              ),
              centerTitle: false,
              floating: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.search,
                        size: 26.0,
                      )),
                ),
                const Padding(
                    padding: EdgeInsets.only(right: 20.0), child: LangPopup()),
                const Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: SettingPopup()),
              ],
            ),
          ];
        },
        body: Center(
          child: SingleChildScrollView(
            child: _list.isEmpty
                ? Text('Loading...')
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 5.0,
                            mainAxisSpacing: 5.0,
                          ),
                          children: _list
                              .map((data) => Card(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PageScreen(
                                                        data["id"],
                                                        data["start_line"],
                                                        data["ename"],
                                                        data["tname"])));
                                      },
                                      child: ListTile(
                                        title: Text(
                                          '${data["start_line"]} (${data["tname"]})',
                                          style: TextStyle(
                                              fontSize: fontsize.value,
                                              fontFamily: 'MeQuran2',
                                              color: Colors.white),
                                        ),
                                        subtitle: Text(
                                          '${data["ename"]}',
                                          style: TextStyle(
                                              fontSize: fontsize.value,
                                              fontFamily: 'MeQuran2',
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class PageScreen extends StatefulWidget {
  final String surah;
  final String surah_name;
  final String detail;
  final String name;

  const PageScreen(this.surah, this.surah_name, this.detail, this.name,
      {Key? key})
      : super(key: key);

  @override
  _PageScreenState createState() => _PageScreenState();
}

class _PageScreenState extends State<PageScreen> {
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  List _list = [];
  final CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('sura_relationships');

  Future<void> getData() async {
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await _collectionRef
        .where('sura_id', isEqualTo: widget.surah)
        .orderBy('created_at')
        .get();

    // Get data from docs and convert map to List
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    setState(() {
      _list = allData;
    });
  }

  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        centerTitle: true,
        title: Text(
          widget.surah_name,
          style: const TextStyle(fontFamily: 'MeQuran2', fontSize: 30),
        ),
      ),
      body: Center(
        child: Wrap(
          children: _list
              .map((data) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SurahScreen(
                                    data["medina_mushaf_page_id"],
                                    widget.surah,
                                    widget.name,
                                    widget.detail)));
                      },
                      child: Text(
                        'Page ${data["medina_mushaf_page_id"]}',
                        style: TextStyle(
                            fontSize: 40,
                            color: (isDark) ? Colors.white : Colors.black),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class SurahScreen extends StatefulWidget {
  final String id;
  final String surah;
  final String name;
  final String detail;

  const SurahScreen(this.id, this.surah, this.name, this.detail, {Key? key})
      : super(key: key);

  @override
  _SurahScreenState createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  final List _list = [];
  int? a = 0;
  String? b;

  bool visible = false;

  bool color = true;

  var scrollController = ScrollController();

  void initState() {
    // TODO: implement initState
    getData();
    getStartAyah();
    super.initState();
  }

  final CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('quran_texts');
  final CollectionReference _collectionRefs =
      FirebaseFirestore.instance.collection('medina_mushaf_pages');

  Future<void> getData() async {
    // Get docs from collection reference
    await _collectionRef
        .where('medina_mushaf_page_id', isEqualTo: widget.id)
        .where('sura_id', isEqualTo: widget.surah)
        .orderBy('created_at')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          _list.add(doc['text1']);
        });
      }
    });
    _list.any((e) => e.contains('b'));
  }

  Future<void> getStartAyah() async {
    // Get docs from collection reference
    await _collectionRefs
        .where('id', isEqualTo: widget.id)
        .where('sura_id', isEqualTo: widget.surah)
        .orderBy('created_at')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          a = int.parse(doc['aya']);
        });
        print(a);
      }
    });
  }

  bool isDark = false;
  var c = '';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontsize = Provider.of<FontSizeController>(context);
    return Scaffold(
      backgroundColor: (themeProvider.isDarkMode)
          ? const Color(0xff666666)
          : const Color(0xFFffffff),
      drawer: const Menu(),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, value) {
            return [
              SliverAppBar(
                iconTheme: Theme.of(context).iconTheme,
                leading: IconButton(
                  icon: const Icon(
                    Icons.menu,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                title: const CircleAvatar(
                  backgroundImage: AssetImage('assets/quranirab.png'),
                  radius: 18.0,
                ),
                centerTitle: false,
                floating: true,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.search,
                          size: 26.0,
                        )),
                  ),
                  const Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: LangPopup()),
                  const Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: SettingPopup()),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(120),
                  child: Column(
                    children: [
                      Row(children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.name,
                                  style: TextStyle(
                                    fontSize: fontsize.value - 2,
                                  ),
                                ),
                                Text(
                                  widget.detail,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: fontsize.value - 2,
                                  ),
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.keyboard_arrow_down),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                          height: 40,
                          child: VerticalDivider(
                            thickness: 2,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(
                          width: 320,
                          child: Row(
                            children: [
                              VerticalDivider(
                                thickness: 2,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 16),
                              Flexible(
                                child: Text(
                                  'Juz 1 / Hizb 1 - Page ${widget.id}',
                                  style: TextStyle(
                                    fontSize: fontsize.value - 2,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const Spacer(),
                        const Padding(
                          padding: EdgeInsets.only(left: 20, right: 8),
                          child: TransPopup(),
                        ),
                      ]),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                w.Responsive.isDesktop(context) ? 400.0 : 80),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: TabBar(
                              indicatorPadding: const EdgeInsets.all(8),
                              indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  // Creates border
                                  color: Theme.of(context).primaryColor),
                              tabs: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Tab(
                                    child: Text(
                                      'Translations',
                                      style: TextStyle(
                                          fontSize: fontsize.value - 2,
                                          color: themeProvider.isDarkMode
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Tab(
                                    child: Text(
                                      'Reading',
                                      style: TextStyle(
                                          fontSize: fontsize.value - 2,
                                          color: themeProvider.isDarkMode
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                )
                              ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: TabBarView(
                    children: [
                      TranslationPage(widget.surah, widget.id),
                      Container(
                        color: themeProvider.isDarkMode
                            ? const Color(0xff9A9A9A)
                            : const Color(0xffFFF5EC),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 3,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.33,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: (themeProvider.isDarkMode)
                                          ? const Color(0xffffffff)
                                          : const Color(0xffFFB55F)),
                                  color: (themeProvider.isDarkMode)
                                      ? const Color(0xff808ba1)
                                      : const Color(0xfffff3ca),
                                ),
                                child: MoreOptionsList(
                                  surah: 'Straight',
                                  nukKalimah: c,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 6,
                              child: _list.isNotEmpty
                                  ? Center(
                                      child: Container(
                                        color: themeProvider.isDarkMode
                                            ? const Color(0xff9A9A9A)
                                            : const Color(0xffFFF5EC),
                                        child: Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: RichText(
                                              textAlign: TextAlign.center,
                                              text: TextSpan(
                                                  children: _list
                                                      .map(
                                                        (e) => TextSpan(
                                                          recognizer:
                                                              TapGestureRecognizer()
                                                                ..onTap =
                                                                    () async {
                                                                  setState(() {
                                                                    visible =
                                                                        true;
                                                                  });
                                                                },
                                                          onEnter: (e) {
                                                            setState(() {
                                                              color = false;
                                                            });
                                                          },
                                                          onExit: (e) {
                                                            setState(() {
                                                              color = true;
                                                            });
                                                          },
                                                          text: e
                                                              .trim()
                                                              .replaceAll(
                                                                  'b', '\n'),
                                                          style: TextStyle(
                                                              fontSize: fontsize
                                                                  .value,
                                                              fontFamily:
                                                                  'MeQuran2',
                                                              color: color
                                                                  ? Colors.black
                                                                  : Colors
                                                                      .blue),
                                                        ),
                                                      )
                                                      .toList())),
                                        ),
                                      ),
                                    )
                                  : const Text('Loading...'),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                  color: (themeProvider.isDarkMode)
                      ? const Color(0xffffffff)
                      : const Color(0xffFFB55F))),
          color:
              themeProvider.isDarkMode ? const Color(0xff666666) : Colors.white,
        ),
        height: MediaQuery.of(context).size.height * 0.1,
        child: Align(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 18),
                    primary: (themeProvider.isDarkMode)
                        ? const Color(0xff808BA1)
                        : const Color(0xfffcd77a)),
                child: const Text(
                  'Previous Page',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
              const SizedBox(width: 25),
              ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 18),
                      primary: (themeProvider.isDarkMode)
                          ? const Color(0xff4C6A7A)
                          : const Color(0xffffeeb0)),
                  child: const Text(
                    'Beginning Surah',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  )),
              const SizedBox(width: 25),
              ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 18),
                      primary: (themeProvider.isDarkMode)
                          ? const Color(0xff808BA1)
                          : const Color(0xfffcd77a)),
                  child: const Text(
                    'Next Page',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  )),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 80.0),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  QuizHome(int.parse(widget.id))));
                    },
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 18),
                        primary: (themeProvider.isDarkMode)
                            ? const Color(0xff808BA1)
                            : const Color(0xfffcd77a)),
                    child: const Text(
                      'Quiz',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<double> checkFont() async {
    var a = fontData.size;
    return a;
  }
}
