import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  late final List<Phrase> phrases;
  final prefs = await SharedPreferences.getInstance();
  final s = prefs.getString("phrases");
  if (s == null) {
    phrases = [];
  } else {
    final json = jsonDecode(s);
    phrases = json.map<Phrase>((json) => Phrase.fromJson(json)).toList();
  }
  runApp(
    MyApp(
      phrases: phrases,
    ),
  );
}

class MyApp extends StatelessWidget {
  final List<Phrase> phrases;
  MyApp({Key? key, required this.phrases}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Phraser',
        phrases: phrases,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title, required this.phrases})
      : super(key: key);

  final String title;
  final List<Phrase> phrases;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Phrase {
  String title;
  String content;

  Phrase(this.title, this.content);

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "content": content,
    };
  }

  factory Phrase.fromJson(Map<String, dynamic> json) {
    return Phrase(json["title"], json["content"]);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Phrase> phrases;
  TextEditingController title = TextEditingController(),
      content = TextEditingController();

  void _savePhrases() async {
    final jsonPhrases = phrases.map((phrase) => phrase.toJson()).toList();
    final jsonStr = jsonEncode(jsonPhrases);

    final prefs = await SharedPreferences.getInstance();
    prefs.setString("phrases", jsonStr);
  }

  void _showSheet(int index) {
    if (phrases.length == index) {
      // Wenn eine neue 'phrase' erstellt werden soll
      title.text = "";
      content.text = "";
    } else {
      // Wenn eine schon existierende bearbeitet werden soll
      title.text = phrases[index].title;
      content.text = phrases[index].content;
    }
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: title,
                focusNode: FocusNode()..requestFocus(),
                decoration: const InputDecoration(
                  helperText: "title",
                ),
                textInputAction: TextInputAction.next,
              ),
              TextField(
                controller: content,
                decoration: const InputDecoration(
                  helperText: "content",
                ),
              ),
              TextButton(
                child: const Text("Save"),
                onPressed: () {
                  if (phrases.length == index) {
                    setState(() {
                      phrases.add(
                        Phrase(title.text, content.text),
                      );
                    });
                  } else {
                    setState(() {
                      phrases[index].title = title.text;
                      phrases[index].content = content.text;
                    });
                  }
                  _savePhrases();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: phrases.isEmpty
          ? const Center(
              child: Text("No phrases"),
            )
          : ListView.builder(
              itemCount: phrases.length,
              itemBuilder: (context, index) {
                final phrase = phrases[index];
                return ListTile(
                  title: Text(phrase.title),
                  subtitle: Text(
                    phrase.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    _showSheet(index);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showSheet(phrases.length);
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void initState() {
    super.initState();
    phrases = widget.phrases;
  }
}
