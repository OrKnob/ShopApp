import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _userId;
  DateTime _expireTime;
  String _userToken;
  Timer expireTimer;
  SharedPreferences preferences;
  bool doLogout = false;

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return _userId;
  }

  String get token {
    if (_userToken != null &&
        _expireTime.isAfter(DateTime.now()) &&
        _expireTime != null) {
      return _userToken;
    }
    return null;
  }

  Future<void> _authenticate(
      String email, String password, String urlPart) async {
    doLogout = false;
    String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlPart?key=AIzaSyBfpF84KuCVhsUbIJ-bpCwHkQOYpSFrZ4w';
    try {
      final response = await http.post(
        url,
        body: json.encode(
            {'email': email, 'password': password, 'returnSecureToken': true}),
      );

      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        print(responseData['error']['message']);
        throw HttpException(responseData['error']['message']);
      }

      _userId = responseData['localId'];
      _expireTime = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _userToken = responseData['idToken'];

      notifyListeners();
      _autoLogOut();

      preferences = await SharedPreferences.getInstance();
      final userInfo = json.encode({
        'token': _userToken,
        'userId': _userId,
        'expireTime': _expireTime.toIso8601String()
      });
      preferences.setString('userData', userInfo);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  void LogOut() async {
    _userToken = null;
    _userId = null;
    _expireTime = null;
    preferences.clear();
    if (expireTimer != null) {
      expireTimer.cancel();
      expireTimer = null;
    }
    notifyListeners();
    doLogout = true;
  }

  Future<String> theToken() async {
//    await Future.delayed(const Duration(milliseconds: 1500));
    final extractedData =
        json.decode(preferences.getString('userData')) as Map<String, dynamic>;
    return extractedData['token'];
  }

//  Future<bool> doTheAutoLogin() async {
//    return await Future.delayed(Duration(milliseconds: 400))
//        .then((onValue) => tryAutoLogin());
//  }

  Future<bool> tryAutoLogin() async {
    doLogout = false;
    await Future.delayed(const Duration(milliseconds: 1500));
    preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey('userData')) {
      return false;
    }
    final extractedData =
        json.decode(preferences.getString('userData')) as Map<String, dynamic>;
    final expiryTime = DateTime.parse(extractedData['expireTime']);
    if (expiryTime.isBefore(DateTime.now())) {
      return false;
    }
    _userToken = extractedData['token'];
    _userId = extractedData['userId'];
    _expireTime = expiryTime;
    _autoLogOut();
    notifyListeners();
    return true;
  }

  void _autoLogOut() {
    if (expireTimer != null) {
      expireTimer.cancel();
    }
    final _expiryTime = _expireTime.difference(DateTime.now()).inSeconds;
    expireTimer = Timer(Duration(seconds: _expiryTime), LogOut);
  }
}
