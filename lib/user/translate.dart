import 'package:flutter/material.dart';
import 'package:translator/translator.dart';


class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String translated = 'Translation';
  String selectedLanguageTo = 'ar';
  String selectedLanguageFrom = 'en';
  late TextEditingController textEditingController;

  Map<String, String> languageCodes = {
    'English (US)': 'en',
    'Arabic (PS)': 'ar',
    'French': 'fr',
    'German': 'de',
    'Spanish': 'es',
    'Hindi': 'hi',
    'Russian': 'ru',
    'Urdu': 'ur',
    'Japanese': 'ja',
    'Italian':'it',
    'Frisian': 'fy',
    'Greek': 'el',
    'Turkish': 'tr',
    'Korean': 'ko',
    'Kurdish': 'ku',
    'Latin': 'la',
  };

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
  }

  void updateTranslation(String text) async {
    if (text.isEmpty) {
      setState(() {
        translated = ''; 
      });
    } else {
      final translation =
          await text.translate(from: selectedLanguageFrom, to: selectedLanguageTo);
      setState(() {
        translated = translation.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.translate, color: Color.fromARGB(255, 39, 26, 99), size: 30,),
          title: const Text("Translate", style: TextStyle(fontFamily: 'Montserrat', fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 39, 26, 99),)),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.swap_horiz, color: Color.fromARGB(255, 39, 26, 99), size: 30,),
              onPressed: () {
                setState(() {
                  final temp = selectedLanguageFrom;
                  selectedLanguageFrom = selectedLanguageTo;
                  selectedLanguageTo = temp;
                  updateTranslation(textEditingController.text);
                });
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: DropdownButton<String>(
                        value: selectedLanguageFrom,
                        icon: const Icon(Icons.arrow_drop_down),
                        style: const TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                        underline: Container(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedLanguageFrom = newValue;
                              updateTranslation(textEditingController.text);
                            });
                          }
                        },
                        items: languageCodes.keys.map<DropdownMenuItem<String>>((String key) {
                          return DropdownMenuItem<String>(
                            value: languageCodes[key],
                            child: Text(
                              key,
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: DropdownButton<String>(
                        value: selectedLanguageTo,
                        icon: const Icon(Icons.arrow_drop_down),
                        style: const TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                        underline: Container(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedLanguageTo = newValue;
                              updateTranslation(textEditingController.text);
                            });
                          }
                        },
                        items: languageCodes.keys.map<DropdownMenuItem<String>>((String key) {
                          return DropdownMenuItem<String>(
                            value: languageCodes[key],
                            child: Text(
                              key,
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: textEditingController,
                    style: const TextStyle(fontSize: 20, color: Colors.black, fontFamily: 'Montserrat',fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: 'Enter text',
                      hintStyle: const TextStyle(color: Colors.grey, fontFamily: 'Montserrat', fontWeight: FontWeight.bold,),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: null,
                    onChanged: (text) {
                      updateTranslation(text);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Text(
                      translated,
                      style: const TextStyle(fontSize: 20, color: Color.fromARGB(255, 39, 26, 99), fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
