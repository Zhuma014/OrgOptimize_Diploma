// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:urven/app.dart';
import 'package:urven/utils/lu.dart';


void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: LU.localizationsDelegates,
      supportedLocales: LU.supportedLocales,
      locale: LU.defaultLocale,
      home:UrvenApp(),
    ),
  );
}
