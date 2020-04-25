import 'package:country_code_picker/country_code_picker.dart';
import 'package:covid19_tracker/model/covid19_dashboard.dart';
import 'package:covid19_tracker/services/networking.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Covid19Dashboard data;
  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: ListView.builder(itemBuilder: (context, index) {
        return ListTile(
          leading: CountryCodePicker(
            onChanged: print,
            initialSelection: data.countries[index].countryCode,
            showCountryOnly: false,
            showFlag: true,
          ),
          title: Text('${data.countries[index].country}'),
          trailing: Text('${data.countries[index].confirmed}'),
        );
      }),
    );
  }

  getData() async {
    Networking network = Networking();
    Covid19Dashboard result = await network.getDashboardData();
    setState(() {
      data = result;
    });
  }
}
