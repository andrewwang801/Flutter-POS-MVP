class AreaModel {
  final double x;
  final double y;
  final int status;
  final double width;
  final double height;
  final String? label;

  AreaModel(
      {required this.x,
      required this.y,
      required this.status,
      required this.width,
      required this.height,
      required this.label});
}

List<AreaModel> areas = [
  AreaModel(x: 350, y: 200, status: 1, width: 50, height: 100, label: 'Bar 1'),
  AreaModel(x: 50, y: 120, status: 1, width: 180, height: 30, label: 'Bar2'),
];
