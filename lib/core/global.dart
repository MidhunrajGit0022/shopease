import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const baseUrl = "https://fakestoreapi.com";

void pr(data) {
  log("------>$data");
}

TextStyle customisedStyle(Color color, FontWeight fontWeight, double fontSize) {
  return GoogleFonts.poppins(
    textStyle: TextStyle(
      fontWeight: fontWeight,
      color: color,
      fontSize: fontSize,
    ),
  );
}
