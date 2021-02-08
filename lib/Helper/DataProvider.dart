
class DataProvider{

  DataProvider prefs ;

  DataProvider._privateConstructor();

  static final DataProvider _instance = DataProvider._privateConstructor();

  factory DataProvider() {
    return _instance;
  }


   String currentLanguage = "en" ;



}