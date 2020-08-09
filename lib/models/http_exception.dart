import 'package:flutter/material.dart';

class HttpException {
  String message;

  HttpException(this.message);

  @override
  String toString() {
    return message;
  }
}
