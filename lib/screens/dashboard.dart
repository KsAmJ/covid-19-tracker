import 'package:covid19_tracker/model/countries.dart';
import 'package:covid19_tracker/model/covid19_dashboard.dart';
import 'package:covid19_tracker/services/networking.dart';
import 'package:flutter/material.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:country_pickers/country.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  Covid19Dashboard data;
  AnimationController _controller;
  Animation _curvedAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _curvedAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.bounceInOut);
    getData();
    //_controller.forward();
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
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                    ),
                    delegate: SliverChildListDelegate([
                      buildSummerCard(
                          text: 'Confirmed',
                          color: Colors.black,
                          count: data.confirmed),
                      buildSummerCard(
                          text: 'Active',
                          color: Colors.blue,
                          count: data.active),
                      buildSummerCard(
                          text: 'Recovered',
                          color: Colors.green,
                          count: data.recovered),
                      buildSummerCard(
                          text: 'Deaths',
                          color: Colors.red,
                          count: data.deaths),
                    ]),
                  ),
                  SliverList(
                      delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: Text('Result date: ${data.date}'),
                      ),
                    )
                  ])),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      var item = data.countries[index];
                      return buildExpansionTile(item, index);
                    }, childCount: data.countries.length),
                  )
                ],
              )
              //  ListView.builder(
              //     itemCount: data.countries.length,
              //     itemBuilder: (context, index) {
              //       var item = data.countries[index];
              //       return buildExpansionTile(item, index);
              //     }),
              ),
    );
  }

  Widget buildSummerCard({int count, Color color, String text}) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0, end: 1).animate(_curvedAnimation),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
            borderRadius: BorderRadius.circular(10),
            elevation: 10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${formatter.format(count)}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                )
              ],
            )),
      ),
    );
  }

  ExpansionTile buildExpansionTile(Countries item, int index) {
    return ExpansionTile(
      leading: item.countryCode.length == 2
          ? CountryPickerUtils.getDefaultFlagImage(
              Country(isoCode: item.countryCode))
          : Text(''),
      title: Text('${item.country}'),
      trailing: Text('${formatter.format(item.confirmed)}'),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                buildDetailText(
                    color: Colors.black, count: index + 1, text: 'Rank'),
                buildDetailText(
                    color: Colors.blue, count: item.active, text: 'Active'),
                buildDetailText(
                    color: Colors.green,
                    count: item.recovered,
                    text: 'Recovered'),
                buildDetailText(
                    color: Colors.red, count: item.deaths, text: 'Deaths'),
              ]),
            ],
          ),
        )
      ],
    );
  }

  Widget buildDetailText({int count, Color color, String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        '$text: ${formatter.format(count)}',
        style: TextStyle(color: color),
      ),
    );
  }

  Future<void> getData() async {
    Networking network = Networking();
    Covid19Dashboard result = await network.getDashboardData();
    setState(() {
      data = result;
      if (data != null) {
        _controller.reset();
        _controller.forward();
      }
    });
  }

  final formatter = NumberFormat.decimalPattern('en-US');
}
