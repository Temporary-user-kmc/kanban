class Task {
  String title;
  int status; // 0:TO DO 1:IN PROGRESS 2:DONE
  int points; // ストーリーポイント
  int num; // チケット番号
  Task(this.title, [this.status = 0, this.points = 3, this.num = 0]);
  String get key => 'PTAI-$num';
}
