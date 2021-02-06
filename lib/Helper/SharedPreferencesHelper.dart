
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {

  static const  String _Full_Name_Key = "FullName";
  static const  String _Email_Key = "Email";

  SharedPreferences prefs ;

  SharedPreferencesHelper._privateConstructor(){

    initSharedPreferences();
  }

  void initSharedPreferences()async{

     prefs = await SharedPreferences.getInstance();

  }

  static final SharedPreferencesHelper _instance = SharedPreferencesHelper._privateConstructor();

  factory SharedPreferencesHelper() {
    return _instance;
  }


  void  setFullName(String fullName) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString(_Full_Name_Key, fullName);
  }

  Future<String > getFullName() async{
    prefs = await SharedPreferences.getInstance();
  return  await prefs.get(_Full_Name_Key);

  }


  void  setEmail(String fullName) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString(_Email_Key, fullName);
  }

  Future<String > getEmail() async{
    prefs = await SharedPreferences.getInstance();
    return  await prefs.get(_Email_Key);

  }
}