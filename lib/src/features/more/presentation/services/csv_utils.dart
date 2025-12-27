import 'package:wiih/src/features/cellar/domain/models/wine.dart';

const List<String> csvHeader = [
  'id',
  'name',
  'type',
  'winery',
  'country',
  'grapeVariety',
  'year',
  'price',
  'bottleCount',
  'imageUrl',
];

String buildCsv(List<Wine> wines) {
  final buffer = StringBuffer();
  buffer.writeln(csvHeader.join(','));

  for (final wine in wines) {
    buffer.writeln(
      [
        wine.id.toString(),
        _escapeCsv(wine.name),
        _escapeCsv(wine.type),
        _escapeCsv(wine.winery),
        _escapeCsv(wine.country),
        _escapeCsv(wine.grapeVariety),
        wine.year.toString(),
        wine.price.toString(),
        wine.bottleCount.toString(),
        _escapeCsv(wine.imageUrl ?? ''),
      ].join(','),
    );
  }

  return buffer.toString();
}

String buildCsvFromRows(
  List<List<String>> rows, {
  required bool includeHeader,
  List<String>? header,
}) {
  final buffer = StringBuffer();
  if (includeHeader) {
    buffer.writeln((header ?? csvHeader).join(','));
  }
  for (final row in rows) {
    buffer.writeln(row.map(_escapeCsv).join(','));
  }
  return buffer.toString();
}

List<List<String>> stripHeader(List<List<String>> rows) {
  if (rows.isEmpty) {
    return rows;
  }
  if (isHeaderRow(rows.first)) {
    return rows.sublist(1);
  }
  return rows;
}

bool isHeaderRow(List<String> row) {
  if (row.length < csvHeader.length) {
    return false;
  }
  for (var i = 0; i < csvHeader.length; i++) {
    if (row[i].trim().toLowerCase() != csvHeader[i]) {
      return false;
    }
  }
  return true;
}

List<List<String>> parseCsvRows(String csv) {
  final rows = <List<String>>[];
  final currentRow = <String>[];
  final currentField = StringBuffer();
  var inQuotes = false;

  for (var i = 0; i < csv.length; i++) {
    final char = csv[i];
    if (inQuotes) {
      if (char == '"') {
        final isEscaped = i + 1 < csv.length && csv[i + 1] == '"';
        if (isEscaped) {
          currentField.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        currentField.write(char);
      }
    } else {
      if (char == '"') {
        inQuotes = true;
      } else if (char == ',') {
        currentRow.add(currentField.toString());
        currentField.clear();
      } else if (char == '\n') {
        currentRow.add(currentField.toString());
        currentField.clear();
        rows.add(List<String>.from(currentRow));
        currentRow.clear();
      } else if (char == '\r') {
        continue;
      } else {
        currentField.write(char);
      }
    }
  }

  if (inQuotes) {
    return rows;
  }

  if (currentField.isNotEmpty || currentRow.isNotEmpty) {
    currentRow.add(currentField.toString());
    rows.add(List<String>.from(currentRow));
  }
  return rows;
}

ParsedWine parseWineRow(
  List<String> row,
  Set<int> existingIds,
  int nextId,
) {
  if (row.length < csvHeader.length - 1) {
    return const ParsedWine(error: 'Missing columns');
  }

  final name = row.length > 1 ? row[1].trim() : '';
  final type = row.length > 2 ? row[2].trim() : '';
  final winery = row.length > 3 ? row[3].trim() : '';
  final country = row.length > 4 ? row[4].trim() : '';
  final grapeVariety = row.length > 5 ? row[5].trim() : '';
  final yearText = row.length > 6 ? row[6].trim() : '';
  final priceText = row.length > 7 ? row[7].trim() : '';
  final bottleText = row.length > 8 ? row[8].trim() : '';

  if (name.isEmpty) {
    return const ParsedWine(error: 'Name missing');
  }
  if (type.isEmpty) {
    return const ParsedWine(error: 'Type missing');
  }
  if (winery.isEmpty) {
    return const ParsedWine(error: 'Winery missing');
  }
  if (country.isEmpty) {
    return const ParsedWine(error: 'Country missing');
  }
  if (grapeVariety.isEmpty) {
    return const ParsedWine(error: 'Grape variety missing');
  }

  final year = int.tryParse(yearText);
  final price = int.tryParse(priceText);
  final bottleCount = int.tryParse(bottleText);
  if (year == null || price == null || bottleCount == null) {
    return const ParsedWine(error: 'Year, price, or bottle count invalid');
  }

  var id = int.tryParse(row[0].trim());
  if (id == null || existingIds.contains(id)) {
    id = nextId;
  }

  return ParsedWine(
    wine: Wine(
      id: id,
      name: name,
      type: type,
      winery: winery,
      country: country,
      grapeVariety: grapeVariety,
      year: year,
      price: price,
      imageUrl: null,
      bottleCount: bottleCount,
    ),
  );
}

String buildFailedCsv({
  required List<List<String>> failedRows,
  required List<String> failedReasons,
}) {
  final normalized = normalizeFailedRows(failedRows);
  final rowsWithErrors = <List<String>>[];
  for (var i = 0; i < normalized.length; i++) {
    final error = i < failedReasons.length ? failedReasons[i] : 'Invalid row';
    rowsWithErrors.add([...normalized[i], error]);
  }
  return buildCsvFromRows(
    rowsWithErrors,
    includeHeader: true,
    header: [...csvHeader, 'error'],
  );
}

List<List<String>> normalizeFailedRows(List<List<String>> rows) {
  return rows.map((row) {
    if (row.length >= csvHeader.length) {
      return row.sublist(0, csvHeader.length);
    }
    return [
      ...row,
      ...List.filled(csvHeader.length - row.length, ''),
    ];
  }).toList();
}

int maxInt(int a, int b) => a > b ? a : b;

String _escapeCsv(String value) {
  final escaped = value.replaceAll('"', '""');
  final needsQuotes = escaped.contains(',') ||
      escaped.contains('\n') ||
      escaped.contains('\r') ||
      escaped.contains('"');
  return needsQuotes ? '"$escaped"' : escaped;
}

class ParsedWine {
  const ParsedWine({this.wine, this.error});

  final Wine? wine;
  final String? error;
}
