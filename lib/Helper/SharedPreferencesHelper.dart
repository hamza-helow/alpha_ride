
import 'package:alpha_ride/Enum/TypeAccount.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {

  static const  String _Full_Name_Key = "FullName";
  static const  String _Email_Key = "Email";
  static const  String _TypeAccount = "TypeAccount";

  static const  String idDriverSelected = "IdDriverSelected";

  static const  String points = "points";

  static const  String rating = "rating";

  SharedPreferences prefs ;

  SharedPreferencesHelper._privateConstructor(){

    initSharedPreferences();
  }
  static final SharedPreferencesHelper _instance = SharedPreferencesHelper._privateConstructor();

  factory SharedPreferencesHelper() {
    return _instance;
  }


  void initSharedPreferences()async{

     prefs = await SharedPreferences.getInstance();
  }



  void  setRating(double rating) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(points,rating);
  }

  Future<double > getRating() async{
    prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(points) ;
  }


  void  setPoints(int point) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setInt(points,point);
  }

  Future<int > getPoints() async{
    prefs = await SharedPreferences.getInstance();
    return prefs.getInt(points) ;
  }



  void  setDriverSelected(String id) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString(idDriverSelected,id);
  }

  Future<String > getDriverSelected() async{
    prefs = await SharedPreferences.getInstance();

    return prefs.get(idDriverSelected) ;


  }



  void  setSetTypeAccount(TypeAccount typeAccount) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString(_TypeAccount, typeAccount.toString());
  }

  Future<TypeAccount > getTypeAccount() async{
    prefs = await SharedPreferences.getInstance();

    return  await () async{
      if(prefs.get(_TypeAccount) == TypeAccount.customer.toString())
        return TypeAccount.customer;
      else
        return TypeAccount.driver;
    }();

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