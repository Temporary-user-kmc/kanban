import 'package:flutter/material.dart';
import 'model.dart';
import 'view_model.dart';

final names = ['TO DO', 'IN PROGRESS', 'DONE'];
final labels = ['TO DO', 'IN PROGRESS', 'DONE'];
final colors = [Color(0xFFEBECF0), Color(0xFFDEEBFF), Color(0xFFE3FCEF)];
const pointChoices = [1, 2, 3, 5, 8];

class KanbanView extends StatefulWidget {
  final KanbanViewModel vm;
  KanbanView(this.vm, {super.key});
  @override
  State<KanbanView> createState() => _KanbanViewState();
}

class _KanbanViewState extends State<KanbanView> {
  final input = TextEditingController();
  int points = 3;

  void add() {
    widget.vm.add(input.text, points);
    input.clear();
  }

  Widget pointPicker(int value, void Function(int) change) =>
    DropdownButton<int>(
      value: value,
      items: [
        for (final p in pointChoices)
          DropdownMenuItem(value: p, child: Text('$p SP')),
      ],
      onChanged: (v) => change(v!),
    );

  Future<void> edit(Task t) async {
    var text = t.title;
    var p = t.points;
    final result = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setDialog) => AlertDialog(
          title: Text('${t.key} を編集'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              initialValue: text,
              autofocus: true,
              onChanged: (v) => text = v,
            ),
            Row(children: [
              Text('ストーリーポイント'),
              SizedBox(width: 12),
              pointPicker(p, (v) => setDialog(() => p = v)),
            ]),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text('保存'),
            ),
          ],
        ),
      ),
    );
    if (result == true) widget.vm.update(t, text, p);
  }

  Widget taskCard(Task t) {
    final s = t.status;
    final buttons = Wrap(spacing: 4, children: [
      if (s > 0)
        TextButton(
          onPressed: () => widget.vm.move(t, s - 1),
          child: Text('← ${labels[s - 1]}'),
        ),
      if (s < 2)
        FilledButton(
          onPressed: () => widget.vm.move(t, s + 1),
          child: Text('${labels[s + 1]} →'),
        ),
    ]);
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: ListTile(
        title: Text(t.title),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(t.key, style: TextStyle(
                color: Color(0xFF0052CC), fontWeight: FontWeight.bold)),
            Spacer(),
            CircleAvatar(
              radius: 12,
              backgroundColor: Color(0xFFDFE1E6),
              child: Text('${t.points}', style: TextStyle(
                  fontSize: 12, color: Colors.black87)),
            ),
          ]),
          buttons,
        ]),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => edit(t),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () => widget.vm.remove(t),
          ),
        ]),
      ),
    );
  }

  Widget lane(int s) {
    final cards = [
      for (final t in widget.vm.tasks)
        if (t.status == s) taskCard(t),
    ];
    return SizedBox(
      width: 360,
      child: Card(
        color: colors[s],
        surfaceTintColor: Colors.transparent,
        child: Column(children: [
          ListTile(
            title: Text('${names[s]}  ${cards.length}件',
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text('${widget.vm.points(s)} SP'),
          ),
          Expanded(child: ListView(children: cards)),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: input,
      decoration: InputDecoration(
        labelText: '新しいチケット',
        hintText: '例：AIの先読み深さを調整する',
        border: OutlineInputBorder(),
      ),
    );
    final button = ValueListenableBuilder(
      valueListenable: input,
      builder: (context, value, child) => FilledButton.icon(
        onPressed: value.text.isEmpty ? null : add,
        icon: Icon(Icons.add),
        label: Text('TO DO に追加'),
      ),
    );
    final entry = Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(children: [
          field,
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            pointPicker(points, (v) => setState(() => points = v)),
            SizedBox(width: 12),
            button,
          ]),
        ]),
      ),
    );
    final progress = ListenableBuilder(
      listenable: widget.vm,
      builder: (context, child) {
        final total = widget.vm.totalPoints;
        final done = widget.vm.points(2);
        final rate = total == 0 ? 0.0 : done / total;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('スプリント進捗: $done / $total SP 完了（${(rate * 100).round()}%）'),
            SizedBox(height: 4),
            LinearProgressIndicator(value: rate, minHeight: 8),
          ]),
        );
      },
    );
    final board = ListenableBuilder(
      listenable: widget.vm,
      builder: (context, child) => ListView(
        scrollDirection: Axis.horizontal,
        children: [for (int s = 0; s < 3; s++) lane(s)],
      ),
    );
    return Scaffold(
      appBar: AppBar(title: Text('🧱🫧 ぷよテトAI 開発ボード')),
      body: Column(children: [
        entry,
        progress,
        Expanded(child: board),
      ]),
    );
  }
}
