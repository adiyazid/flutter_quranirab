import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:quranirab/models/break.index.model.dart';
import 'package:quranirab/models/word.detail.dart';
import 'package:quranirab/provider/ayah.number.provider.dart';
import 'package:quranirab/provider/language.provider.dart';
import 'package:quranirab/views/auth/landing.page.dart';

class Slice2 extends StatefulWidget {
  const Slice2({Key? key}) : super(key: key);

  @override
  _Slice2State createState() => _Slice2State();
}

class _Slice2State extends State<Slice2> {
  CollectionReference quranText =
      FirebaseFirestore.instance.collection('quran_texts');
  CollectionReference rawText =
      FirebaseFirestore.instance.collection('raw_quran_texts');
  CollectionReference sliceData =
      FirebaseFirestore.instance.collection('medina_mushaf_pages');
  CollectionReference wordText = FirebaseFirestore.instance.collection('words');
  CollectionReference wordRelationship =
      FirebaseFirestore.instance.collection('word_relationships');
  CollectionReference wordCategory =
      FirebaseFirestore.instance.collection('word_categories');
  final List _list = [];

  var total = 0;
  var totalSlice = 10;
  List _slice = [];
  final List _break = [];
  bool loading = true;
  var word = [];
  final category = [];
  var totalLine = 0;
  int? nums = 0;
  final _ayaNumber = [];
  final _ayaPosition = [];
  List<bool> select = [];
  List<int> _breakIndex = <int>[];
  int? length;
  BreakIndex? _index;
  GlobalKey key = GlobalKey();

  @override
  void initState() {
    getData();
    readJsonData();
    Future.delayed(Duration(milliseconds: 3000), cancelLoad);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !loading
        ? Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => DummyPage()),
                      (route) => false),
                  icon: Icon(Icons.arrow_back_ios)),
              title: Consumer<AyaProvider>(builder: (context, number, child) {
                return Text('Page ${number.page}');
              }),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
                child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: _breakIndex.isNotEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (int index = 0;
                              index < _breakIndex.length;
                              index++)
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (int i = 0 + index != 0
                                          ? _breakIndex[index - 1]
                                          : 0;
                                      i < _breakIndex[index];
                                      i++)
                                    checkAya(_slice[i]['end'])
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Consumer<AyaProvider>(builder:
                                                  (context, aya, child) {
                                                return InkWell(
                                                    onTap: () {
                                                      nums = 0;
                                                      Provider.of<AyaProvider>(
                                                              context,
                                                              listen: false)
                                                          .getCategoryName(
                                                              _slice[i]
                                                                  ['word_id'],
                                                              Provider.of<LangProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .langId);
                                                      showPopover(
                                                        backgroundColor:
                                                            Colors.orangeAccent,
                                                        context: context,
                                                        transitionDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    200),
                                                        bodyBuilder: (context) =>
                                                            const ListItems(),
                                                        onPop: () {
                                                          Provider.of<AyaProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .clear();
                                                        },
                                                        direction:
                                                            PopoverDirection
                                                                .bottom,
                                                        width: 450,
                                                        height: 400,
                                                        arrowHeight: 15,
                                                        arrowWidth: 30,
                                                      );
                                                    },
                                                    child: Text(
                                                        _list
                                                            .join()
                                                            .split('')
                                                            .getRange(
                                                                _slice[i][
                                                                        'start'] -
                                                                    1,
                                                                _slice[i]
                                                                    ['end'])
                                                            .join(),
                                                        textDirection:
                                                            TextDirection.rtl,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'MeQuran2',
                                                          fontSize: 20,
                                                          color: aya.getColor(
                                                              _slice[i]
                                                                  ['word_id']),
                                                          // aya.getBoolean(_slice[i]['start'] - 1)
                                                          //     ? aya.getColor(_slice[i]['word_id'])
                                                          //     : Colors.black)),
                                                        )));
                                              }),
                                              _list.join().split('').length -
                                                          _slice[i]['end'] <
                                                      3
                                                  ? Text(
                                                      " ${_list.join().split('').length - _slice[i]['end'] < 3 ? _ayaNumber.last : ""}",
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'MeQuran2',
                                                          fontSize: 20,
                                                          color: Colors.black),
                                                    )
                                                  : Container()
                                            ],
                                          )
                                        : Row(
                                            children: [
                                              Consumer<AyaProvider>(builder:
                                                  (context, aya, child) {
                                                return InkWell(
                                                  child: Text(
                                                    _list
                                                        .join()
                                                        .split('')
                                                        .getRange(
                                                            _slice[i]['start'] -
                                                                1,
                                                            _slice[i]['end'])
                                                        .join(),
                                                    style: TextStyle(
                                                        fontFamily: 'MeQuran2',
                                                        fontSize: 20,
                                                        color: aya.getColor(
                                                            _slice[i]
                                                                ['word_id'])),
                                                  ),
                                                  onTap: () {
                                                    nums = 0;
                                                    Provider.of<AyaProvider>(
                                                            context,
                                                            listen: false)
                                                        .getCategoryName(
                                                            _slice[i]
                                                                ['word_id'],
                                                            Provider.of<LangProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .langId);
                                                    showPopover(
                                                      backgroundColor:
                                                          Colors.orangeAccent,
                                                      context: context,
                                                      transitionDuration:
                                                          const Duration(
                                                              milliseconds:
                                                                  200),
                                                      bodyBuilder: (context) =>
                                                          const ListItems(),
                                                      onPop: () {
                                                        Provider.of<AyaProvider>(
                                                                context,
                                                                listen: false)
                                                            .clear();
                                                      },
                                                      direction:
                                                          PopoverDirection
                                                              .bottom,
                                                      width: 450,
                                                      height: 400,
                                                      arrowHeight: 15,
                                                      arrowWidth: 30,
                                                    );
                                                  },
                                                );
                                              }),
                                              Text(
                                                "${_ayaNumber[nums! - 1]} ",
                                                style: TextStyle(
                                                    fontFamily: 'MeQuran2',
                                                    fontSize: 20,
                                                    color: Colors.black),
                                              )
                                            ],
                                          ),
                                ],
                              ),
                            ),
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Spacer(),
                              ElevatedButton(
                                  onPressed: () {
                                    Provider.of<AyaProvider>(context,
                                            listen: false)
                                        .previousPage();
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Slice2()),
                                        (route) => false);
                                  },
                                  child: Text('Previous page')),
                              Spacer(),
                              Consumer<AyaProvider>(
                                  builder: (context, number, child) {
                                return Text(
                                  'Page ${number.page}',
                                  style: TextStyle(fontSize: 30),
                                );
                              }),
                              Spacer(),
                              ElevatedButton(
                                  onPressed: () {
                                    Provider.of<AyaProvider>(context,
                                            listen: false)
                                        .nextPage();
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Slice2()),
                                        (route) => false);
                                  },
                                  child: Text('Next page')),
                              Spacer(),
                            ],
                          ),
                        ],
                      )
                    : Container(),
              ),
            )))
        : Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Future<void> getData() async {
    String page = '${Provider.of<AyaProvider>(context, listen: false).page}';

    ///todo: get aya
    var prev = 0;

    // List<int> indexBreak = [];
    await FirebaseFirestore.instance
        .collection('quran_texts')
        .orderBy('created_at')
        .where('medina_mushaf_page_id', isEqualTo: page)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        String text = doc["text1"];
        setState(() {
          for (int i = 0; i < doc["text"].split('').length; i++) {
            if (doc["text"].split('')[i].contains('ﳁ')) {
              _list.add('${doc["text"].substring(0, i)}');
              _ayaNumber.add(doc["text"].substring(i));
              _ayaPosition.add(prev + i - 1);
              prev = prev + i;
            }
          }
          for (int i = 0; i < text.split('').length; i++) {
            if (text.split('')[i] == '﴿') {
              _break.add(
                  '${text.split('').getRange(0, i).join()} ${text.split('').getRange(i + 3, text.split('').length).join().trim()}');
            }
          }
        });
      }
      for (int i = 0;
          i < _list.join().replaceAll('', '').split('').length;
          i++) {
        select.add(false);
      }
      // //todo:check line per pages
      // for (int i = 0; i < _break.length; i++) {
      //   var bool = _break[i].contains('b');
      //   if (bool == true) {
      //     totalLine++;
      //   }
      // }
      //todo:check breakpoint index
      // for (int i = 0; i < _break.join().trim().split('').length; i++) {
      //   if (_break.join().trim().split('')[i] == 'b') {
      //     indexBreak.add(i);
      //   }}
      // for (int i = 0; i < _break.join().split('').length; i++) {
      //   if (_break.join().split('')[i] == 'b') {
      //     indexBreak.add(i);
      //   }
      // }
      // print(indexBreak);
      // setState(() {
      //   length = indexBreak.length;
      // });
    });

    ///load list of boolean
    Provider.of<AyaProvider>(context, listen: false).loadList(select);

    ///getTotalSlice
    await sliceData
        .where('id', isEqualTo: page)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          _slice = json.decode(doc["slicing_data"]);
        });
      }
      setState(() {
        total = _slice.last["end"];
      });
    });
    for (int i = 0; i < _slice.length; i++) {
      if (_slice[i != _slice.length - 1 ? i + 1 : i]['start'] -
              _slice[i]['end'] ==
          1) {
        print('data fix');
      } else {
        var a = _slice[i != _slice.length - 1 ? i + 1 : i]['start'] -
            _slice[i]['end'];
        setState(() {
          _slice.setAll(i, [
            {
              'start': _slice[i]['start'],
              'end': i != _slice.length - 1
                  ? _slice[i]['end'] + a - 1
                  : _slice[i]['end'],
              'word_id': _slice[i]['word_id']
            }
          ]);
        });
      }
    }

    ///todo:split slice data that contain breakpoint index
    // var indexB = 0;
    // var i = 0;
    //
    // for (var element in _slice) {
    //   if (indexBreak[i] >= element['start'] &&
    //       indexBreak[i] <= element['end']) {
    //     _breakIndex.add(indexB);
    //     i++;
    //   } else {
    //     if (indexBreak[i] >= _slice.last['end'] &&
    //         _breakIndex.length != indexBreak.length) {
    //       _breakIndex.add(_slice.length);
    //     }
    //     indexB++;
    //   }
    // }
    print(_breakIndex);
  }

  Future<void> getText(element) async {
    await wordText
        .where('id', isEqualTo: element.toString())
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          word.add(doc["text"].trim());
        });
      }
    });
  }

  void cancelLoad() {
    setState(() {
      loading = false;
    });
  }

  checkAya(index) {
    var total = _list.length - 1;
    var lengthAya1 = _list[0].split(' ').length;
    var a = _ayaPosition.contains(index - 1);
    var b = _ayaPosition.contains(index);
    var c = _ayaPosition.contains(index + 1);
    // print(index);
    // print(_list.join().split('').length);
    if (!a) {
      return true;
    }
    if (!a && !b) {
      return true;
    }
    if (!a && !b && !c) {
      return true;
    }
    if (nums! < total && index > lengthAya1) {
      nums = nums! + 1;
    }
    return false;
  }

  ///todo: insert break line data entry
  Future<BreakIndex> readJsonData() async {
    String page = '${Provider.of<AyaProvider>(context, listen: false).page}';
    String jsonData = await rootBundle.loadString("break_index/break.json");
    _index = BreakIndex.fromJson(json.decode(jsonData));
    if (page == '1') {
      _breakIndex = _index?.page1 ?? <int>[];
    }
    if (page == '2') {
      _breakIndex = _index?.page2 ?? <int>[];
    }
    if (page == '440') {
      _breakIndex = _index?.page440 ?? <int>[];
    }
    return _index!;
  }
}

class ListItems extends StatelessWidget {
  const ListItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Consumer<AyaProvider>(builder: (context, aya, child) {
          List<WordDetail> word = aya.getWordTypeList() ?? <WordDetail>[];
          List<WordDetail> name = aya.getWordNameList() ?? <WordDetail>[];
          for (var item in name) {
            for (var element in word) {
              if (element.id == item.id) {
                item.type = element.type;
              }
            }
          }
          return ListView.builder(
            itemCount: name.length,
            itemBuilder: (BuildContext context, int index) {
              return word.isNotEmpty
                  ? Row(
                      children: [
                        if (name[index].type != 'label')
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadiusDirectional.circular(8),
                                color: Colors.amber[300],
                              ),
                              child: Center(
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "${name[index].name} ${name[index].type}",
                                      style: TextStyle(fontFamily: 'MeQuran2'),
                                      textAlign: TextAlign.center,
                                    )),
                              ),
                            ),
                          ),
                        Spacer(),
                        index == 0
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadiusDirectional.circular(8),
                                    color: Colors.amber[300],
                                  ),
                                  height: 50,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'نوع الكلمة',
                                        textAlign: TextAlign.center,
                                        style:
                                            TextStyle(fontFamily: 'MeQuran2'),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        if (name[index].type == 'label')
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadiusDirectional.circular(8),
                                color: Colors.amber[300],
                              ),
                              child: Center(
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "${name[index].name}",
                                      style: TextStyle(fontFamily: 'MeQuran2'),
                                      textAlign: TextAlign.center,
                                    )),
                              ),
                            ),
                          )
                      ],
                    )
                  : CircularProgressIndicator();
            },
          );
        }),
      ),
    );
  }
}
