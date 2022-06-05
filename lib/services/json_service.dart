import 'package:flutter/material.dart';

class JsonService {
  const JsonService();

  Future<String> fetchData(BuildContext context, String path) async {
    return await DefaultAssetBundle.of(context).loadString(path);
  }
}
