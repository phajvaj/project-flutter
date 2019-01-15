import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thdee/src/api.dart';

class Dessert {
  Dessert(
      this.hight,
      this.bw,
      this.bps,
      this.bpd,
      this.bgm,
      this.waist,
      this.conclusion,
      this.vdate,
      this.exercise,
      this.food,
      this.mood,
      this.smok,
      this.alcohol,
      this.state);
  final int hight;
  final int bw;
  final int bgm;
  final int waist;
  final int bps;
  final int bpd;
  final String conclusion;
  final String vdate;
  final String exercise;
  final String food;
  final String mood;
  final String smok;
  final String alcohol;
  final String state;

  bool selected = false;
}

class DessertDataSource extends DataTableSource {
  //DessertDataSource(this._desserts);

  List<Dessert> _desserts = <Dessert>[
    new Dessert(65, 159, 6, 24, 55, 99, '1', '2', '3', '4', '5', '6', '7', '8'),
    new Dessert(65, 159, 6, 24, 55, 99, '1', '2', '3', '4', '5', '6', '7', '8'),
    new Dessert(65, 159, 6, 24, 55, 99, '1', '2', '3', '4', '5', '6', '7', '8'),
    new Dessert(65, 159, 6, 24, 55, 99, '1', '2', '3', '4', '5', '6', '7', '8'),
  ];

  Future<Dessert> fetchData() async {
    ApiProvider apiProvider = ApiProvider();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');
    try {
      var response = await apiProvider.getScreen(token);
      if (response.statusCode == 200) {
        var js = json.decode(response.body);
        if (js['statusCode'] == 200) {
          List dt = js['data'];
          print(js['data']);

          _desserts = await dt.map<Dessert>((dynamic a) {
            return new Dessert(
              a['hight'],
              a['bw'],
              a['bps'],
              a['bpd'],
              a['bgm'],
              a['waist'],
              a['conclusion'],
              a['vdate'],
              a['exercise'],
              a['food'],
              a['mood'],
              a['smok'],
              a['alcohol'],
              a['state'],
            );
          }).toList();

          //return _desserts;
        }
      }
    } catch (error) {
      print(error);
    }
  }

  void _sort<T>(Comparable<T> getField(Dessert d), bool ascending) {
    _desserts.sort((Dessert a, Dessert b) {
      if (!ascending) {
        final Dessert c = a;
        a = b;
        b = c;
      }
      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    notifyListeners();
  }

  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _desserts.length) return null;
    final Dessert dessert = _desserts[index];
    return new DataRow.byIndex(
        index: index,
        selected: dessert.selected,
        onSelectChanged: (bool value) {
          if (dessert.selected != value) {
            _selectedCount += value ? 1 : -1;
            assert(_selectedCount >= 0);
            dessert.selected = value;
            notifyListeners();
          }
        },
        cells: <DataCell>[
          new DataCell(new Text('${dessert.bw}')),
          new DataCell(new Text('${dessert.hight}')),
          //new DataCell(new Text('${dessert.bps}/${dessert.bpd}')),
          new DataCell(new Text('${dessert.bgm}')),
          new DataCell(new Text('${dessert.waist}')),
          new DataCell(new Text('${dessert.food}')),
          new DataCell(new Text('${dessert.exercise}')),
          new DataCell(new Text('${dessert.mood}')),
          new DataCell(new Text('${dessert.smok}')),
          new DataCell(new Text('${dessert.alcohol}')),
          new DataCell(new Text('${dessert.conclusion}')),
          new DataCell(new Text('${dessert.state}')),
          new DataCell(new Text('${dessert.vdate}')),
        ]);
  }

  @override
  int get rowCount => _desserts.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;

  void _selectAll(bool checked) {
    for (Dessert dessert in _desserts) dessert.selected = checked;
    _selectedCount = checked ? _desserts.length : 0;
    notifyListeners();
  }
}

class ScreenTablePage extends StatefulWidget {
  @override
  _ScreenTablePageState createState() => new _ScreenTablePageState();
}

class _ScreenTablePageState extends State<ScreenTablePage> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;

  final DessertDataSource _dessertsDataSource = new DessertDataSource();

  void _sort<T>(
      Comparable<T> getField(Dessert d), int columnIndex, bool ascending) {
    _dessertsDataSource._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  initState() {
    super.initState();
    _dessertsDataSource.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: const Text('ข้อมูลคัดกรอง')),
        body:
            new ListView(padding: const EdgeInsets.all(2.0), children: <Widget>[
          new PaginatedDataTable(
              header: Text('ข้อมูล'),
              rowsPerPage: _rowsPerPage,
              onRowsPerPageChanged: (int value) {
                setState(() {
                  _rowsPerPage = value;
                });
              },
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              onSelectAll: _dessertsDataSource._selectAll,
              columns: <DataColumn>[
                new DataColumn(
                    label: const Text('น้ำหนัก'),
                    onSort: (int columnIndex, bool ascending) => _sort<num>(
                        (Dessert d) => d.bw, columnIndex, ascending)),
                new DataColumn(
                    label: const Text('ส่วนสูง'),
                    tooltip:
                        'The total amount of food energy in the given serving size.',
                    numeric: true,
                    onSort: (int columnIndex, bool ascending) => _sort<num>(
                        (Dessert d) => d.hight, columnIndex, ascending)),
//                new DataColumn(
//                    label: const Text('ความดันโลหิต'),
//                    numeric: true,
//                    onSort: (int columnIndex, bool ascending) => _sort<num>(
//                        (Dessert d) => d.bpd, columnIndex, ascending)),
                new DataColumn(
                    label: const Text('น้ำตาล'),
                    numeric: true,
                    onSort: (int columnIndex, bool ascending) => _sort<num>(
                        (Dessert d) => d.bgm, columnIndex, ascending)),
                new DataColumn(
                    label: const Text('รอบเอว'),
                    numeric: true,
                    onSort: (int columnIndex, bool ascending) => _sort<num>(
                        (Dessert d) => d.waist, columnIndex, ascending)),
                new DataColumn(
                    label: const Text('อาหาร'),
                    numeric: true,
                    onSort: (int columnIndex, bool ascending) => _sort<String>(
                        (Dessert d) => d.food, columnIndex, ascending)),
                new DataColumn(
                    label: const Text('ออกกำลังกาย'),
                    numeric: true,
                    onSort: (int columnIndex, bool ascending) => _sort<String>(
                        (Dessert d) => d.exercise, columnIndex, ascending)),
                new DataColumn(
                    label: const Text('อารมณ์'),
                    numeric: true,
                    onSort: (int columnIndex, bool ascending) => _sort<String>(
                        (Dessert d) => d.mood, columnIndex, ascending)),
                new DataColumn(
                    label: const Text('สูบบุหรี่'),
                    numeric: true,
                    onSort: (int columnIndex, bool ascending) => _sort<String>(
                        (Dessert d) => d.smok, columnIndex, ascending)),
                new DataColumn(
                    label: const Text('ดื่มสุรา'),
                    numeric: true,
                    onSort: (int columnIndex, bool ascending) => _sort<String>(
                        (Dessert d) => d.alcohol, columnIndex, ascending)),
                new DataColumn(
                    label: const Text('ผลสรุป'),
                    numeric: true,
                    onSort: (int columnIndex, bool ascending) => _sort<String>(
                        (Dessert d) => d.state, columnIndex, ascending)),
                new DataColumn(
                    label: const Text('สถานะ'),
                    numeric: true,
                    onSort: (int columnIndex, bool ascending) => _sort<String>(
                        (Dessert d) => d.state, columnIndex, ascending)),
                new DataColumn(
                    label: const Text('วันที่บันทึก'),
                    numeric: true,
                    onSort: (int columnIndex, bool ascending) => _sort<String>(
                        (Dessert d) => d.vdate, columnIndex, ascending)),
              ],
              source: _dessertsDataSource)
        ]));
  }
}
