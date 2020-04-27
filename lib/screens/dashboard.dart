import 'package:covid19_tracker/model/covid19_dashboard.dart';
import 'package:covid19_tracker/services/networking.dart';
import 'package:flutter/material.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:country_pickers/country.dart';

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
        title: Text('COVID-19 Dashboard'),
      ),
      body: data == null
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: getData,
              child: ListView.builder(
                  itemCount: data.countries.length,
                  itemBuilder: (context, index) {
                    return ExpansionTile(
                      leading: data.countries[index].countryCode.length == 2
                          ? CountryPickerUtils.getDefaultFlagImage(Country(
                              isoCode: data.countries[index].countryCode))
                          : Text(''),
                      title: Text('${data.countries[index].country}'),
                      trailing: Text('${data.countries[index].confirmed}'),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Rank: ${index + 1}'),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                        'Confirmed: ${data.countries[index].confirmed}'),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                        'Recovered: ${data.countries[index].recovered}',
                                        style: TextStyle(color: Colors.green)),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                        'Deaths: ${data.countries[index].deaths}',
                                        style: TextStyle(color: Colors.red)),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ]),
                            ],
                          ),
                        )
                      ],
                    );
                  }),
            ),
    );
  }

  Future<void> getData() async {
    Networking network = Networking();
    Covid19Dashboard result = await network.getDashboardData();
    setState(() {
      data = result;
    });
  }
}
