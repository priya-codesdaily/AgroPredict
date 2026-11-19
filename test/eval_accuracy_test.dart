import 'dart:convert';
import 'dart:io';

import 'package:agropredict/logic/voice_parser.dart';
import 'package:flutter_test/flutter_test.dart';

class _Expected {
  final String file;
  final String crop;
  final double? quantity;
  final String unit;

  _Expected(this.file, this.crop, this.quantity, this.unit);
}

List<_Expected> _readExpected(File file) {
  final rows = <_Expected>[];
  for (final line in file.readAsLinesSync().skip(1)) {
    final clean = line.replaceAll('\uFEFF', '').trim();
    if (clean.isEmpty) continue;
    final p = clean.split(',');
    String at(int i) => i < p.length ? p[i].trim() : '';
    final qty = at(3);
    rows.add(_Expected(
      at(0),
      at(2),
      qty.isEmpty ? null : double.parse(qty),
      at(4),
    ));
  }
  return rows;
}

String _group(String file) {
  final n = int.parse(file);
  if (n <= 20) return 'Hindi';
  if (n <= 30) return 'English';
  if (n <= 40) return 'Hinglish';
  if (n <= 44) return 'Hindi';
  if (n <= 47) return 'English';
  return 'Hinglish';
}

String _show(double? q) {
  if (q == null) return '-';
  return q % 1 == 0 ? q.toInt().toString() : q.toString();
}

String _pct(int a, int b) => b == 0 ? '-' : '${(100 * a / b).round()}%';

void _score(String title, String csvName, String jsonName, String outName) {
  final expectedFile = File('eval/$csvName');
  final transcriptFile = File('eval/$jsonName');
  if (!expectedFile.existsSync() || !transcriptFile.existsSync()) {
    print('$title: eval data not found, skipping.');
    return;
  }

  final expected = _readExpected(expectedFile);
  final heard =
      json.decode(transcriptFile.readAsStringSync()) as Map<String, dynamic>;

  var scored = 0;
  var passed = 0;
  var cropRight = 0;
  var quantityRight = 0;
  final byGroup = <String, List<int>>{};
  final failures = <String>[];
  final seconds = <double>[];

  for (final row in expected) {
    final entry = heard[row.file] as Map<String, dynamic>?;
    if (entry == null) continue;

    final text = entry['transcript'] as String;
    seconds.add((entry['seconds'] as num).toDouble());
    final got = VoiceParser.parse(text);

    final cropOk = got.crop == row.crop;
    final quantityOk = got.quantity == row.quantity;
    final unitOk = got.unit == row.unit;
    final ok = cropOk && quantityOk && unitOk;

    scored++;
    if (ok) passed++;
    if (cropOk) cropRight++;
    if (quantityOk && unitOk) quantityRight++;

    final g = byGroup.putIfAbsent(_group(row.file), () => [0, 0]);
    g[1]++;
    if (ok) g[0]++;

    if (!ok) {
      failures.add('${row.file} (${_group(row.file)}): heard "$text"\n'
          '    expected ${row.crop} ${_show(row.quantity)} ${row.unit}'
          '  |  got ${got.crop ?? '-'} ${_show(got.quantity)} ${got.unit}');
    }
  }

  seconds.sort();
  var median = 0.0;
  if (seconds.isNotEmpty) {
    final mid = seconds.length ~/ 2;
    median = seconds.length.isOdd
        ? seconds[mid]
        : (seconds[mid - 1] + seconds[mid]) / 2;
  }

  final out = StringBuffer();
  out.writeln('# Parser accuracy: $title');
  out.writeln();
  out.writeln('| Group | Correct |');
  out.writeln('|---|---|');
  byGroup.forEach((name, v) {
    out.writeln('| $name | ${v[0]} of ${v[1]} (${_pct(v[0], v[1])}) |');
  });
  out.writeln('| **All** | **$passed of $scored (${_pct(passed, scored)})** |');
  out.writeln();
  out.writeln('Crop correct: $cropRight of $scored');
  out.writeln('Quantity and unit correct: $quantityRight of $scored');
  out.writeln('Median request time: ${median.toStringAsFixed(2)} s');
  out.writeln();
  out.writeln('## Failures');
  out.writeln();
  for (final f in failures) {
    out.writeln('- $f');
  }

  File('eval/$outName').writeAsStringSync(out.toString());
  print(out);
}

void main() {
  test('score the tuned set (40 sentences)', () {
    _score('tuned set', 'expected.csv', 'transcripts.json', 'results.md');
  });

  test('score the unseen set (10 sentences)', () {
    _score(
      'unseen set',
      'expected_heldout.csv',
      'transcripts_heldout.json',
      'results_heldout.md',
    );
  });
}