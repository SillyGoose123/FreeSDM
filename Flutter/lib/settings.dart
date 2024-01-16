import 'dart:async';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class Settings {
  late final String name;
  var port = 8000;

  Settings({required this.name});

  Future<Settings> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(name)) {
      var settings = Settings(name: name);
      settings.createByStandard();
      return settings;
    }

    var data = prefs.getStringList(name)!;
    port = int.parse(data[0]);

    return this;
  }

  void createByStandard() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey("Standard")) {
      createStandard();
    }

    prefs.setStringList(name, prefs.getStringList("Standard")!);
  }

  void createStandard() async {
    Settings settings = Settings(name: "Standard");
    settings.port = 8000;
    settings.saveData();
  }

  void saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(name, [port.toString()]);
  }

  void loadStandard() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("Standard")) {
      createStandard();
    }

    var data = prefs.getStringList("Standard")!;
    port = int.parse(data[0]);
  }

  void delete() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(name);
  }
}