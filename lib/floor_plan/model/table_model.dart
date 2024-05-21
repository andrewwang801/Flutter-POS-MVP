class TableModel {
  final double x;
  final double y;
  final double width;
  final double height;
  final int status;
  final String? label;

  TableModel(this.x, this.y, this.width, this.height, this.status, this.label);
}

List<TableModel> tables = [
  TableModel(170, 50, 40, 40, 2, 'T1'),
  TableModel(290, 50, 40, 40, 2, 'T2'),
  TableModel(150, 200, 40, 40, 2, 'T3'),
  TableModel(50, 170, 40, 40, 2, 'T4'),
  TableModel(80, 250, 40, 40, 2, 'T5'),
];
