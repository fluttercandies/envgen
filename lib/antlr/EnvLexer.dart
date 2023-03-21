// Generated from ./antlr/Env.g4 by ANTLR 4.12.0
// ignore_for_file: unused_import, unused_local_variable, prefer_single_quotes
import 'package:antlr4/antlr4.dart';


class EnvLexer extends Lexer {
  static final checkVersion = () => RuntimeMetaData.checkVersion('4.12.0', RuntimeMetaData.VERSION);

  static final List<DFA> _decisionToDFA = List.generate(
        _ATN.numberOfDecisions, (i) => DFA(_ATN.getDecisionState(i), i));
  static final PredictionContextCache _sharedContextCache = PredictionContextCache();
  static const int
    TOKEN_T__0 = 1, TOKEN_KEY = 2, TOKEN_NEWLINE = 3, TOKEN_NOTLINE = 4, 
    TOKEN_COMMENT = 5, TOKEN_INT = 6, TOKEN_DOUBLE = 7, TOKEN_BOOLEAN = 8, 
    TOKEN_SINGLE_QUOTE_STRING = 9, TOKEN_DOUBLE_QUOTE_STRING = 10, TOKEN_NO_QUOTE_STRING = 11, 
    TOKEN_WS = 12;
  @override
  final List<String> channelNames = [
    'DEFAULT_TOKEN_CHANNEL', 'HIDDEN'
  ];

  @override
  final List<String> modeNames = [
    'DEFAULT_MODE'
  ];

  @override
  final List<String> ruleNames = [
    'T__0', 'KEY', 'NEWLINE', 'NOTLINE', 'COMMENT', 'INT', 'DOUBLE', 'BOOLEAN', 
    'ESC', 'SINGLE_QUOTE_STRING', 'DOUBLE_QUOTE_STRING', 'NO_QUOTE_STRING', 
    'WS'
  ];

  static final List<String?> _LITERAL_NAMES = [
      null, "'='"
  ];
  static final List<String?> _SYMBOLIC_NAMES = [
      null, null, "KEY", "NEWLINE", "NOTLINE", "COMMENT", "INT", "DOUBLE", 
      "BOOLEAN", "SINGLE_QUOTE_STRING", "DOUBLE_QUOTE_STRING", "NO_QUOTE_STRING", 
      "WS"
  ];
  static final Vocabulary VOCABULARY = VocabularyImpl(_LITERAL_NAMES, _SYMBOLIC_NAMES);

  @override
  Vocabulary get vocabulary {
    return VOCABULARY;
  }


  EnvLexer(CharStream input) : super(input) {
    interpreter = LexerATNSimulator(_ATN, _decisionToDFA, _sharedContextCache, recog: this);
  }

  @override
  List<int> get serializedATN => _serializedATN;

  @override
  String get grammarFileName => 'Env.g4';

  @override
  ATN getATN() { return _ATN; }

  static const List<int> _serializedATN = [
      4,0,12,115,6,-1,2,0,7,0,2,1,7,1,2,2,7,2,2,3,7,3,2,4,7,4,2,5,7,5,2,
      6,7,6,2,7,7,7,2,8,7,8,2,9,7,9,2,10,7,10,2,11,7,11,2,12,7,12,1,0,1,
      0,1,1,1,1,5,1,32,8,1,10,1,12,1,35,9,1,1,2,4,2,38,8,2,11,2,12,2,39,
      1,3,1,3,1,4,1,4,5,4,46,8,4,10,4,12,4,49,9,4,1,5,3,5,52,8,5,1,5,4,5,
      55,8,5,11,5,12,5,56,1,6,3,6,60,8,6,1,6,4,6,63,8,6,11,6,12,6,64,1,6,
      1,6,4,6,69,8,6,11,6,12,6,70,1,7,1,7,1,7,1,7,1,7,1,7,1,7,1,7,1,7,3,
      7,82,8,7,1,8,1,8,1,8,1,9,1,9,1,9,5,9,90,8,9,10,9,12,9,93,9,9,1,9,1,
      9,1,10,1,10,1,10,5,10,100,8,10,10,10,12,10,103,9,10,1,10,1,10,1,11,
      4,11,108,8,11,11,11,12,11,109,1,12,1,12,1,12,1,12,0,0,13,1,1,3,2,5,
      3,7,4,9,5,11,6,13,7,15,8,17,0,19,9,21,10,23,11,25,12,1,0,9,2,0,65,
      90,95,95,3,0,48,57,65,90,95,95,2,0,10,10,13,13,1,0,48,57,8,0,34,34,
      47,47,92,92,98,98,102,102,110,110,114,114,116,116,2,0,39,39,92,92,
      2,0,34,34,92,92,5,0,9,10,13,13,32,32,35,35,61,61,2,0,9,9,32,32,127,
      0,1,1,0,0,0,0,3,1,0,0,0,0,5,1,0,0,0,0,7,1,0,0,0,0,9,1,0,0,0,0,11,1,
      0,0,0,0,13,1,0,0,0,0,15,1,0,0,0,0,19,1,0,0,0,0,21,1,0,0,0,0,23,1,0,
      0,0,0,25,1,0,0,0,1,27,1,0,0,0,3,29,1,0,0,0,5,37,1,0,0,0,7,41,1,0,0,
      0,9,43,1,0,0,0,11,51,1,0,0,0,13,59,1,0,0,0,15,81,1,0,0,0,17,83,1,0,
      0,0,19,86,1,0,0,0,21,96,1,0,0,0,23,107,1,0,0,0,25,111,1,0,0,0,27,28,
      5,61,0,0,28,2,1,0,0,0,29,33,7,0,0,0,30,32,7,1,0,0,31,30,1,0,0,0,32,
      35,1,0,0,0,33,31,1,0,0,0,33,34,1,0,0,0,34,4,1,0,0,0,35,33,1,0,0,0,
      36,38,7,2,0,0,37,36,1,0,0,0,38,39,1,0,0,0,39,37,1,0,0,0,39,40,1,0,
      0,0,40,6,1,0,0,0,41,42,8,2,0,0,42,8,1,0,0,0,43,47,5,35,0,0,44,46,8,
      2,0,0,45,44,1,0,0,0,46,49,1,0,0,0,47,45,1,0,0,0,47,48,1,0,0,0,48,10,
      1,0,0,0,49,47,1,0,0,0,50,52,5,45,0,0,51,50,1,0,0,0,51,52,1,0,0,0,52,
      54,1,0,0,0,53,55,7,3,0,0,54,53,1,0,0,0,55,56,1,0,0,0,56,54,1,0,0,0,
      56,57,1,0,0,0,57,12,1,0,0,0,58,60,5,45,0,0,59,58,1,0,0,0,59,60,1,0,
      0,0,60,62,1,0,0,0,61,63,7,3,0,0,62,61,1,0,0,0,63,64,1,0,0,0,64,62,
      1,0,0,0,64,65,1,0,0,0,65,66,1,0,0,0,66,68,5,46,0,0,67,69,7,3,0,0,68,
      67,1,0,0,0,69,70,1,0,0,0,70,68,1,0,0,0,70,71,1,0,0,0,71,14,1,0,0,0,
      72,73,5,116,0,0,73,74,5,114,0,0,74,75,5,117,0,0,75,82,5,101,0,0,76,
      77,5,102,0,0,77,78,5,97,0,0,78,79,5,108,0,0,79,80,5,115,0,0,80,82,
      5,101,0,0,81,72,1,0,0,0,81,76,1,0,0,0,82,16,1,0,0,0,83,84,5,92,0,0,
      84,85,7,4,0,0,85,18,1,0,0,0,86,91,5,39,0,0,87,90,3,17,8,0,88,90,8,
      5,0,0,89,87,1,0,0,0,89,88,1,0,0,0,90,93,1,0,0,0,91,89,1,0,0,0,91,92,
      1,0,0,0,92,94,1,0,0,0,93,91,1,0,0,0,94,95,5,39,0,0,95,20,1,0,0,0,96,
      101,5,34,0,0,97,100,3,17,8,0,98,100,8,6,0,0,99,97,1,0,0,0,99,98,1,
      0,0,0,100,103,1,0,0,0,101,99,1,0,0,0,101,102,1,0,0,0,102,104,1,0,0,
      0,103,101,1,0,0,0,104,105,5,34,0,0,105,22,1,0,0,0,106,108,8,7,0,0,
      107,106,1,0,0,0,108,109,1,0,0,0,109,107,1,0,0,0,109,110,1,0,0,0,110,
      24,1,0,0,0,111,112,7,8,0,0,112,113,1,0,0,0,113,114,6,12,0,0,114,26,
      1,0,0,0,15,0,33,39,47,51,56,59,64,70,81,89,91,99,101,109,1,6,0,0
  ];

  static final ATN _ATN =
      ATNDeserializer().deserialize(_serializedATN);
}