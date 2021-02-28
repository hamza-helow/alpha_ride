import 'package:alpha_ride/Helper/AppLanguage.dart';
import 'package:alpha_ride/Helper/AppLocalizations.dart';
import 'package:alpha_ride/Helper/DataProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SetupLanguage extends StatefulWidget {

  String lang;


  SetupLanguage(this.lang);

  @override
  _SetupLanguageState createState() => _SetupLanguageState();
}

class _SetupLanguageState extends State<SetupLanguage> {

  var appLanguage;
  int selectedRadio;


  @override
  void initState() {
    selectedRadio = widget.lang == "en" ?1 : 2;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    appLanguage = Provider.of<AppLanguage>(context);


    return  Column(
      children: [
        Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                RadioListTile(
                  groupValue: selectedRadio,
                  activeColor: DataProvider().baseColor,
                  value: 1,
                  title: Text(
                      "${AppLocalizations.of(context).translate('english')}"),
                  onChanged: (val) {
                    print("Radio $val");

                    setState(() {
                      setSelectedRadio(val);
                    });
                  },
                ),
                RadioListTile(
                  groupValue: selectedRadio,
                  activeColor: DataProvider().baseColor,
                  value: 2,
                  title: Text(
                      "${AppLocalizations.of(context).translate('arabic')}"),
                  onChanged: (val) {
                    print("Radio $val");

                    setState(() {
                      setSelectedRadio(val);
                    });
                  },
                ),
              ],
            ))
      ],
    );
  }



  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;

      String lang = "";

      if (val == 1)
        lang = "en";
      else
        lang = "ar";

      DataProvider().currentLanguage = lang ;

      appLanguage.changeLanguage(new Locale(lang));
    });
  }



}
