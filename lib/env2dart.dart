import 'dart:io';

import 'package:antlr4/antlr4.dart';
import 'package:args/args.dart';
import 'package:built_collection/built_collection.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:recase/recase.dart';

import 'antlr/EnvLexer.dart';
import 'antlr/EnvParser.dart';
import 'log.dart';
import 'visitor.dart';

EnvParser _newParser(String contents) {
  final input = InputStream.fromString(contents);
  final lexer = EnvLexer(input);
  final tokens = CommonTokenStream(lexer);
  final parser = EnvParser(tokens);
  parser.addErrorListener(DiagnosticErrorListener());
  return parser;
}

const kIgnoreLints = [
  'camel_case_types',
  'non_constant_identifier_names',
  'prefer_single_quotes',
  'avoid_escaping_inner_quotes',
];

Map<String, Pair> _resolvePairs(File file, String fileName) {
  final input = file.readAsStringSync();
  final parser = _newParser(input);
  final visitor = DefaultVisitor(fileName);
  visitor.visit(parser.env());
  return visitor.pairs;
}

const _numberType = ['int', 'double'];

void _mergeEnv(
  Map<String, Pair> env,
  Map<String, Pair> other, {
  Set<String>? nullableKeys,
  bool useEnvValue = false,
}) {
  other.forEach((key, value) {
    final newValue = value.copyWith();
    if (env.containsKey(key)) {
      final envValue = env[key]!;
      final comments = envValue.comments;
      if (newValue.comments.isNotEmpty) {
        comments.add('========================================');
        comments.addAll(newValue.comments);
      }
      newValue.comments = comments;
      if (envValue.type != newValue.type) {
        if (_numberType.contains(envValue.type) &&
            _numberType.contains(newValue.type)) {
          newValue.type = 'double';
        } else {
          newValue.type = 'String';
        }
      }
      if (useEnvValue) {
        newValue.value = envValue.value;
      }
    }
    if (nullableKeys != null && nullableKeys.contains(newValue.name)) {
      newValue.nullable = true;
    }
    env[key] = newValue;
  });
}

void envgen({
  String? output,
  required String path,
  String? active,
  required String clazz,
}) {
  'Generating, please wait.'.$info(tag: 'env2dart');
  final sw = Stopwatch()..start();
  final dir = Directory(path);
  final entries = dir.listSync().whereType<File>().where((e) {
    final fileName = e.uri.pathSegments.last;
    return fileName == '.env' || fileName.startsWith('.env.');
  }).map((e) {
    final fileName = e.uri.pathSegments.last;
    final pairs = _resolvePairs(e, fileName);
    'found file: $fileName'.$info(tag: 'env2dart');
    return MapEntry(fileName, pairs);
  });
  final envs = Map.fromEntries(entries);
  final List<Spec> body;
  if (envs.containsKey('.env')) {
    final d = envs.remove('.env')!;
    final entries = envs.entries.toList(growable: false);
    final length = entries.length;
    if (length > 0) {
      final exist = d.keys.toSet();
      final otherKeys = <String>{};
      for (final entry in entries) {
        otherKeys.addAll(entry.value.keys);
      }
      otherKeys.removeAll(exist);
      final Set<String> nullableKeys = {...otherKeys};
      if (otherKeys.isNotEmpty && length > 1) {
        final sames = entries[0].value.keys.toSet()..removeAll(exist);
        if (sames.isNotEmpty) {
          for (var index = 1; index < length; index++) {
            final e = entries[index].value.keys.toSet()..removeAll(exist);
            if (e.isEmpty) {
              sames.clear();
              break;
            }
            sames.retainAll(e);
            if (sames.isEmpty) {
              break;
            }
          }
          nullableKeys.removeAll(sames);
        }
      }
      final abs = {...d};
      final impls = <Spec>[];
      final otherEnvs = <Field>[];
      Field? activeField;
      for (final entry in entries) {
        _mergeEnv(
          abs,
          entry.value,
          nullableKeys: nullableKeys,
          useEnvValue: true,
        );
        impls.add(_toSubenv(clazz, entry));
        final key = entry.key.split('.').last;
        final className = '$clazz $key'.pascalCase;
        otherEnvs.add(
          Field(
            (b) => b
              ..name = key
              ..type = Reference(className)
              ..static = true
              ..modifier = FieldModifier.final$
              ..assignment = Code('$className()'),
          ),
        );
        if (key == active) {
          activeField = Field(
            (b) => b
              ..name = r'$active'
              ..type = Reference(clazz)
              ..static = true
              ..assignment = Code(key),
          );
        }
      }
      activeField ??= Field(
        (b) => b
          ..name = r'$active'
          ..type = Reference(clazz)
          ..static = true
          ..assignment = const Code(r'$'),
      );
      otherEnvs.add(activeField);
      final absClass = _toAbs(
        abs,
        othersKey: otherKeys,
        otherEnvs: otherEnvs,
        name: clazz,
      );
      body = [absClass, ...impls];
    } else {
      body = [_toAbs(d, othersKey: {}, name: clazz)];
    }
    body.insert(
      0,
      Method(
        (b) => b
          ..type = MethodType.getter
          ..name = 'env'
          ..lambda = true
          ..body = Code('$clazz.\$active')
          ..returns = Reference(clazz),
      ),
    );
  } else {
    body = _toEnvs(envs, name: clazz);
  }
  final library = Library(
    (b) => b
      ..body.addAll(body)
      ..comments = ListBuilder([
        'coverage:ignore-file',
        "ignore_for_file: ${kIgnoreLints.join(", ")}",
        '======================================',
        'GENERATED CODE - DO NOT MODIFY BY HAND',
        '======================================',
      ]),
  );
  final dartEmitter = DartEmitter();
  var code = library.accept(dartEmitter).toString();
  code = DartFormatter(fixes: StyleFix.all).format(code);
  output ??= './lib/${clazz.snakeCase}.dart';
  if (!output.endsWith('.dart')) {
    output = '$output.dart';
  }
  File(output).writeAsStringSync(code);
  'Generation successful, took ${sw.elapsed.inMilliseconds} milliseconds.'
      .$info(tag: 'env2dart');
}

Class _toAbs(
  Map<String, Pair> pairs, {
  Set<String> othersKey = const {},
  List<Field> otherEnvs = const [],
  required String name,
}) {
  final getters = <Method>[];
  final fields = <Field>[];
  final ovps = <Parameter>[];
  final ovcodes = StringBuffer();
  final toJson = StringBuffer();
  final toString = StringBuffer();
  final ovjvs = StringBuffer();
  final ovjps = StringBuffer();
  for (final field in pairs.values) {
    final fieldName = field.name;
    final fieldType = field.type;
    getters.add(
      Method(
        (b) {
          b
            ..name = fieldName
            ..type = MethodType.getter
            ..lambda = true
            ..body = Code('_$fieldName')
            ..returns = Reference(field.nullable ? '$fieldType?' : fieldType)
            ..docs = ListBuilder(field.comments.map((e) => '/// $e'));
          if (othersKey.contains(fieldName)) {
            b.returns = Reference('$fieldType?');
          } else {
            b.returns = Reference(fieldType);
          }
        },
      ),
    );
    fields.add(
      Field(
        (b) {
          b
            ..type = Reference(field.nullable ? '$fieldType?' : fieldType)
            ..name = '_$fieldName';
          if (othersKey.contains(fieldName)) {
            b.type = Reference('$fieldType?');
          } else {
            b.type = Reference(fieldType);
            String v = field.value.toString();
            if (fieldType == 'String' &&
                !RegExp('^[\'"].*[\'"]\$').hasMatch(v)) {
              v = "'$v'";
            }
            b.assignment = Code(v);
          }
        },
      ),
    );
    ovps.add(
      Parameter(
        (b) => b
          ..name = fieldName
          ..named = true
          ..type = Reference('$fieldType?'),
      ),
    );
    ovcodes.writeln('_$fieldName = $fieldName ?? _$fieldName;');
    toJson.write("'$fieldName': $fieldName,");
    toString.write("sb.write('$fieldName: ');\nsb.writeln($fieldName);");
    if (fieldType == 'int') {
      ovjvs.writeln("final $fieldName = json['$fieldName'];");
      ovjps.writeln(
        '$fieldName: $fieldName == null ? null : int.parse($fieldName.toString()),',
      );
    } else if (fieldType == 'double') {
      ovjvs.writeln("final $fieldName = json['$fieldName'];");
      ovjps.writeln(
        '$fieldName: $fieldName == null ? null : double.parse($fieldName.toString()),',
      );
    } else if (fieldType == 'bool') {
      ovjvs.writeln("final $fieldName = json['$fieldName'].toString();");
      ovjps.writeln(
        "$fieldName: $fieldName == 'true' || $fieldName == 'false' ? $fieldName == 'true' : null,",
      );
    } else if (fieldType == 'String') {
      ovjvs.writeln("final $fieldName = json['$fieldName'];");
      ovjps.writeln('$fieldName: $fieldName,');
    }
  }
  return Class(
    (b) => b
      ..name = name
      ..fields = ListBuilder([
        Field(
          (b) => b
            ..name = 'env'
            ..modifier = FieldModifier.final$
            ..type = const Reference('String'),
        ),
        Field(
          (b) => b
            ..name = r'$'
            ..static = true
            ..modifier = FieldModifier.final$
            ..assignment = Code("$name('')")
            ..type = Reference(name),
        ),
        ...otherEnvs,
        ...fields,
      ])
      ..methods = ListBuilder([
        ...getters,
        Method(
          (b) => b
            ..name = 'overrideValue'
            ..returns = const Reference('void')
            ..body = Code(ovcodes.toString())
            ..optionalParameters = ListBuilder(ovps),
        ),
        Method(
          (b) => b
            ..name = 'overrideValueFromJson'
            ..returns = const Reference('void')
            ..body = Code('${ovjvs}overrideValue($ovjps);')
            ..requiredParameters = ListBuilder([
              Parameter(
                (b) => b
                  ..name = 'json'
                  ..type = const Reference('Map'),
              )
            ]),
        ),
        Method(
          (b) => b
            ..name = 'toJson'
            ..returns = const Reference('Map<String, dynamic>')
            ..body = Code('return {$toJson};'),
        ),
        Method(
          (b) => b
            ..name = 'toString'
            ..annotations =
                ListBuilder([const CodeExpression(Code('override'))])
            ..returns = const Reference('String')
            ..body = Code(
              'final sb = StringBuffer();\n$toString\nreturn sb.toString();',
            ),
        )
      ])
      ..constructors = ListBuilder([
        Constructor(
          (b) => b
            ..requiredParameters = ListBuilder([
              Parameter(
                (b) => b
                  ..name = 'env'
                  ..toThis = true,
              )
            ]),
        ),
      ]),
  );
}

List<Class> _toEnvs(
  Map<String, Map<String, Pair>> envs, {
  required String name,
}) {
  return envs.entries.map((e) => _toEnvClass(name, e)).toList(growable: false);
}

Class _toSubenv(
  String name,
  MapEntry<String, Map<String, Pair>> env,
) {
  final ovcodes = StringBuffer();
  for (final field in env.value.values) {
    ovcodes.writeln(
      field.comments
          .where((e) => e.isNotEmpty)
          .map((e) => '    // $e')
          .join('\n'),
    );
    String v = field.value.toString();
    if (field.type == 'String' && !RegExp('^[\'"].*[\'"]\$').hasMatch(v)) {
      v = "'$v'";
    }
    ovcodes.writeln('_${field.name} = $v;');
  }
  final className = '$name ${env.key.split('.').last}'.pascalCase;
  return Class(
    (b) => b
      ..name = className
      ..extend = Reference(name)
      ..constructors = ListBuilder([
        Constructor(
          (b) => b
            ..body = Code(ovcodes.toString())
            ..initializers = ListBuilder(
              [Code("super('${env.key.split('.').last}')")],
            ),
        ),
      ]),
  );
}

Class _toEnvClass(
  String name,
  MapEntry<String, Map<String, Pair>> env,
) {
  final getters = <Method>[];
  final fields = <Field>[];
  final ovps = <Parameter>[];
  final ovcodes = StringBuffer();
  final toJson = StringBuffer();
  final toString = StringBuffer();
  final ovjvs = StringBuffer();
  final ovjps = StringBuffer();
  for (final field in env.value.values) {
    final fieldName = field.name;
    final fieldType = field.type;
    getters.add(
      Method(
        (b) => b
          ..name = fieldName
          ..type = MethodType.getter
          ..lambda = true
          ..body = Code('_$fieldName')
          ..docs = ListBuilder(field.comments.map((e) => '/// $e'))
          ..returns = Reference(fieldType),
      ),
    );
    fields.add(
      Field(
        (b) => b
          ..type = Reference(fieldType)
          ..name = '_$fieldName'
          ..assignment = Code(field.value.toString()),
      ),
    );
    ovps.add(
      Parameter(
        (b) => b
          ..name = fieldName
          ..named = true
          ..type = Reference('$fieldType?'),
      ),
    );
    ovcodes.writeln('_$fieldName = $fieldName ?? _$fieldName;');
    toJson.write("'$fieldName': $fieldName,");
    toString.write("sb.write('$fieldName: ');\nsb.writeln($fieldName);");
    if (fieldType == 'int') {
      ovjvs.writeln("final $fieldName = json['$fieldName'];");
      ovjps.writeln(
        '$fieldName: $fieldName == null ? null : int.parse($fieldName.toString()),',
      );
    } else if (fieldType == 'double') {
      ovjvs.writeln("final $fieldName = json['$fieldName'];");
      ovjps.writeln(
        '$fieldName: $fieldName == null ? null : double.parse($fieldName.toString()),',
      );
    } else if (fieldType == 'bool') {
      ovjvs.writeln("final $fieldName = json['$fieldName'].toString();");
      ovjps.writeln(
        "$fieldName: $fieldName == 'true' || $fieldName == 'false' ? $fieldName == 'true' : null,",
      );
    } else if (fieldType == 'String') {
      ovjvs.writeln("final $fieldName = json['$fieldName'];");
      ovjps.writeln('$fieldName: $fieldName,');
    }
  }
  final isDefault = env.key == '.env';
  final className =
      isDefault ? name : '$name ${env.key.split('.').last}'.pascalCase;
  return Class(
    (b) => b
      ..name = className
      ..fields = ListBuilder([
        Field(
          (b) => b
            ..name = 'env'
            ..modifier = FieldModifier.final$
            ..type = const Reference('String'),
        ),
        ...fields,
      ])
      ..methods = ListBuilder([
        ...getters,
        Method(
          (b) => b
            ..name = 'overrideValue'
            ..returns = const Reference('void')
            ..body = Code(ovcodes.toString())
            ..optionalParameters = ListBuilder(ovps),
        ),
        Method(
          (b) => b
            ..name = 'overrideValueFromJson'
            ..returns = const Reference('void')
            ..body = Code('${ovjvs}overrideValue($ovjps);')
            ..requiredParameters = ListBuilder([
              Parameter(
                (b) => b
                  ..name = 'json'
                  ..type = const Reference('Map'),
              )
            ]),
        ),
        Method(
          (b) => b
            ..name = 'toJson'
            ..returns = const Reference('Map<String, dynamic>')
            ..body = Code('return {$toJson};'),
        ),
        Method(
          (b) => b
            ..name = 'toString'
            ..annotations =
                ListBuilder([const CodeExpression(Code('override'))])
            ..returns = const Reference('String')
            ..body = Code(
              'final sb = StringBuffer();\n$toString\nreturn sb.toString();',
            ),
        )
      ])
      ..constructors = ListBuilder([
        Constructor(
          (b) => b
            ..initializers = ListBuilder(
              [Code("env = '${isDefault ? '' : env.key.split('.').last}'")],
            ),
        ),
      ]),
  );
}

void parseAndGen(List<String> arguments) {
  final args = ArgParser();
  args.addOption(
    'path',
    abbr: 'p',
    defaultsTo: '',
    help:
        'Specify working directory, the CLI will look for the .env file in the current directory.',
  );
  args.addOption(
    'output',
    abbr: 'o',
    help: 'Specify the output file path.',
    defaultsTo: 'lib/env.g.dart',
  );
  args.addOption(
    'active',
    abbr: 'a',
    help:
        'Specify the environment variables to use. For example, if -active prod is specified, the CLI will look for the .env.prod file and merge it with the .env file.',
  );
  args.addOption(
    'class',
    abbr: 'c',
    defaultsTo: 'Env',
    help: 'Specify the name for the generated class',
  );
  args.addFlag(
    'help',
    abbr: 'h',
    negatable: false,
    help: 'View help options.',
  );
  final parse = args.parse(arguments);
  if (parse['help'] == true) {
    print(args.usage);
    return;
  }
  envgen(
    path: parse['path'],
    output: parse['output'],
    active: parse['active'],
    clazz: parse['class'],
  );
}
