library katex_spec;

import 'package:unittest/unittest.dart';

import 'package:katex/katex.dart';


main() {

  unittestConfiguration.timeout = new Duration( seconds: 5 );

  SpanNode toBuild ( { String expression } ) {

    Parser parser = new Parser( expression: expression );
    List<ParseNode> tree = parser.parse();
    return buildTree( tree: tree );

  }

  List<SymbolNode> getBuilt( { String expression } ) {

    SpanNode node = toBuild( expression: expression );

    return node.children[ 0 ].children[ 2 ].children;

  }

  List<ParseNode> toParse ( { String expression } ) {

    Parser parser = new Parser( expression: expression );
    return parser.parse();

  }

  setUp( () {

    Katex katex = new Katex();

  });

  group( 'A parser', () {

    test( 'should not fail on an empty string', () {

      toParse( expression: '' );

    });

    test( 'should ignore whitespace', () {

      List<ParseNode> treeA = toParse( expression: 'xy' );
      List<ParseNode> treeB = toParse( expression: '    x    y    ' );

      expect( treeA[0].value, treeB[0].value );
      expect( treeA[1].value, treeB[1].value );

    });

  });

  group( 'An ord parser', () {

    String expression = '1234|/@.\"`abcdefgzABCDEFGZ';

    test( 'should not fail', () {

      toParse( expression: expression );

    });

    test( 'should build a list of ords', () {

      List<ParseNode> tree = toParse( expression: expression );

      expect( tree, isNotNull );
      expect( tree.length, isNonZero );

      tree.forEach( ( parseNode ) {
        expect( parseNode.type, matches( new RegExp( 'ord' ) ) );
      });

    });

    test( 'should parse the right number of ords', () {

      List<ParseNode> tree = toParse( expression: expression );

      expect( tree.length , expression.length );

    });

  });

  group( 'A bin parser', () {

    String expression = '+-*\\cdot\\pm\\div';

    test( 'should not fail', () {

      toParse( expression: expression );

    });

    test( 'should build a list of bins', () {

      List<ParseNode> tree = toParse( expression: expression );

      expect( tree, isNotNull );
      expect( tree.length, isNonZero );

      tree.forEach( ( parseNode ) {
        expect( parseNode.type, matches( new RegExp( 'bin' ) ) );
      });

    });

  });

  group( 'A rel parser', () {

    String expression = '=<>\\leq\\geq\\neq\\nleq\\ngeq\\cong';

    test( 'should not fail', () {

      toParse( expression: expression );

    });

    test( 'should build a list of rels', () {

      List<ParseNode> tree = toParse( expression: expression );

      expect( tree, isNotNull );
      expect( tree.length, isNonZero );

      tree.forEach( ( parseNode ) {
        expect( parseNode.type, matches( new RegExp( 'rel' ) ) );
      });

    });

  });

  group( 'A punct parser', () {

    String expression = ',;\\colon';

    test( 'should not fail', () {

      toParse( expression: expression );

    });

    test( 'should build a list of puncts', () {

      List<ParseNode> tree = toParse( expression: expression );

      expect( tree, isNotNull );
      expect( tree.length, isNonZero );

      tree.forEach( ( parseNode ) {
        expect( parseNode.type, matches( new RegExp( 'punct' ) ) );
      });

    });

  });

  group( 'An open parser', () {

    String expression = '([';

    test( 'should not fail', () {

      toParse( expression: expression );

    });

    test( 'should build a list of opens', () {

      List<ParseNode> tree = toParse( expression: expression );

      expect( tree, isNotNull );
      expect( tree.length, isNonZero );

      tree.forEach( ( parseNode ) {
        expect( parseNode.type, matches( new RegExp( 'open' ) ) );
      });

    });

  });

  group( 'A close parser', () {

    String expression = ')]?!';

    test( 'should not fail', () {

      toParse( expression: expression );

    });

    test( 'should build a list of closes', () {

      List<ParseNode> tree = toParse( expression: expression );

      expect( tree, isNotNull );
      expect( tree.length, isNonZero );

      tree.forEach( ( parseNode ) {
        expect( parseNode.type, matches( new RegExp( 'close' ) ) );
      });

    });

  });

  group( 'A \\KaTeX parser', () {

    test( 'should not fail', () {

      toParse( expression: '\\KaTeX' );

    });

  });

  group( 'A subscript and superscript parser', () {

    test( 'should not fail on superscripts', () {

      toParse( expression: 'x^2' );

    });

    test( 'should not fail on subscripts', () {

      toParse( expression: 'x_3' );

    });

    test( 'should not fail on both subscripts and superscripts', () {

      toParse( expression: 'x^2_3' );
      toParse( expression: 'x_2^3' );

    });

    test( 'should not fail when there is no nucleus', () {

      toParse( expression: '^3' );
      toParse( expression: '_2' );
      toParse( expression: '^3_2' );
      toParse( expression: '_2^3' );

    });

    test( 'should produce supsubs for superscript', () {

      ParseNode parseNode = toParse( expression: 'x^2' )[ 0 ];

      expect( parseNode.type, 'supsub' );
      expect( parseNode.value[ 'base' ], isNotNull );
      expect( parseNode.value[ 'sup' ], isNotNull );
      expect( parseNode.value[ 'sub' ], isNull );

    });

    test( 'should produce supsubs for subscript', () {

      ParseNode parseNode = toParse( expression: 'x_3' )[ 0 ];

      expect( parseNode.type, 'supsub' );
      expect( parseNode.value[ 'base' ], isNotNull );
      expect( parseNode.value[ 'sub' ], isNotNull );
      expect( parseNode.value[ 'sup' ], isNull );

    });

    test( 'should produce supsubs for ^_', () {

      ParseNode parseNode = toParse( expression: 'x^2_3' )[ 0 ];

      expect( parseNode.type, 'supsub' );
      expect( parseNode.value[ 'base' ], isNotNull );
      expect( parseNode.value[ 'sub' ], isNotNull );
      expect( parseNode.value[ 'sup' ], isNotNull );

    });

    test( 'should produce supsubs for _^', () {

      ParseNode parseNode = toParse( expression: 'x_3^2' )[ 0 ];

      expect( parseNode.type, 'supsub' );
      expect( parseNode.value[ 'base' ], isNotNull );
      expect( parseNode.value[ 'sub' ], isNotNull );
      expect( parseNode.value[ 'sup' ], isNotNull );

    });

    test( 'should produce the same thing regardless of order', () {

      List<ParseNode> treeA = toParse( expression: 'x^2_3' );
      List<ParseNode> treeB = toParse( expression: 'x_3^2' );

      expect( treeA[ 0 ].value[ 'base' ].value, treeB[ 0 ].value[ 'base' ].value );

      expect( treeA[ 0 ].value[ 'sub' ].value, treeB[ 0 ].value[ 'sub' ].value );

      expect( treeA[ 0 ].value[ 'sup' ].value, treeB[ 0 ].value[ 'sup' ].value );

    });

    test( 'should not parse double subscripts or superscripts', () {

      expect( () => toParse( expression: 'x^x^x' ), throwsA( new isInstanceOf<ParseError>() ) );

      expect( () => toParse( expression: 'x_x_x' ), throwsA( new isInstanceOf<ParseError>() ) );

      expect( () => toParse( expression: 'x_x^x_x' ), throwsA( new isInstanceOf<ParseError>() ) );

      expect( () => toParse( expression: 'x_x^x^x' ), throwsA( new isInstanceOf<ParseError>() ) );

      expect( () => toParse( expression: 'x^x_x_x' ), throwsA( new isInstanceOf<ParseError>() ) );

      expect( () => toParse( expression: 'x^x_x^x' ), throwsA( new isInstanceOf<ParseError>() ) );

    });

    test( 'should work correctly with {}s', () {

      toParse( expression: 'x^{2+3}' );

      toParse( expression: 'x_{3-2}' );

      toParse( expression: 'x^{2+3}_3' );

      toParse( expression: 'x^2_{3-2}' );

      toParse( expression: 'x^{2+3}_{3-2}' );

      toParse( expression: 'x_{3-2}^{2+3}' );

      toParse( expression: 'x_3^{2+3}' );

      toParse( expression: 'x_{3-2}^2' );

    });

    test( 'should work with nested super/subscripts', () {

      toParse( expression: 'x^{x^x}' );

      toParse( expression: 'x^{x_x}' );

      toParse( expression: 'x_{x^x}' );

      toParse( expression: 'x_{x_x}' );

    });

  });

  group( 'A subscript and superscript tree-builder', () {

    test( 'should not fail when there is no nucleus', () {

      toBuild( expression: '^3' );

      toBuild( expression: '_2' );

      toBuild( expression: '^3_2' );

      toBuild( expression: '_2^3' );

    });

  });

  group( 'A group parser', () {

    test( 'should not fail', () {

      toParse( expression: '{xy}' );

    });

    test( 'should produce a single ord', () {

      List<ParseNode> tree = toParse( expression: '{xy}' );

      expect( tree.length, 1 );

      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.type, matches( new RegExp( 'ord' ) ) );
      expect( parseNode.value, isNotNull );

    });

  });

  group( 'An implicit group parser', () {

    test( 'should not fail', () {

      toParse( expression: '\\Large x' );

      toParse( expression: 'abc {abc \\Large xyz} abc' );

    });

    test( 'should produce a single object', () {

      List<ParseNode> tree = toParse( expression: '\\Large abc' );

      expect( tree.length, 1 );

      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.type, matches( new RegExp( 'sizing' ) ) );
      expect( parseNode.value, isNotNull );

    });

    test( 'should apply only after the function', () {

      List<ParseNode> tree = toParse( expression: 'a \\Large abc' );

      expect( tree.length, 2 );

      ParseNode parseNode = tree[ 1 ];

      expect( parseNode.type, matches( new RegExp( 'sizing' ) ) );
      expect( parseNode.value[ 'value' ].length, 3 );

    });

    test( 'should stop at the ends of groups', () {

      List<ParseNode> tree = toParse( expression: 'a { b \\Large c } d' );

      ParseNode group = tree[ 1 ];
      ParseNode sizing = group.value[ 1 ];

      expect( sizing.type, matches( new RegExp( 'sizing' ) ) );
      expect( sizing.value[ 'value' ].length, 1 );

    });

  });

  group( 'A function parser', () {

    test( 'should parse no argument functions', () {

      toParse( expression: '\\div' );

    });

    test( 'should parse 1 argument functions', () {

      toParse( expression: '\\blue x' );

    });

    test( 'should parse 2 argument functions', () {

      toParse( expression: '\\frac 1 2' );

    });

    test( 'should not parse 1 argument functions with no arguments', () {

      expect( () => toParse( expression: '\\blue' ), throwsA( new isInstanceOf<ParseError>() ) );

    });

    test( 'should not parse 2 argument functions with 0 or 1 arguments', () {

      expect( () => toParse( expression: '\\frac' ), throwsA( new isInstanceOf<ParseError>() ) );

      expect( () => toParse( expression: '\\frac 1' ), throwsA( new isInstanceOf<ParseError>() ) );

    });

    test( 'should not parse a function with text right after test', () {

      expect( () => toParse( expression: '\\redx' ), throwsA( new isInstanceOf<ParseError>() ) );

    });

    test( 'should parse a function with a number right after test', () {

      toParse( expression: '\\frac12' );

    });

    test( 'should parse some functions with text right after test', () {

      toParse( expression: '\\;x' );

    });

  });

  group( 'A frac parser', () {

    String expression = '\\frac{x}{y}';
    String dfracExpression = '\\dfrac{x}{y}';
    String tfracExpression = '\\tfrac{x}{y}';

    test( 'should not fail', () {

      toParse( expression: expression );

    });

    test( 'should produce a frac', () {

      List<ParseNode> tree = toParse( expression: expression );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.type, matches( new RegExp( 'frac' ) ) );
      expect( parseNode.value[ 'numer' ], isNotNull );
      expect( parseNode.value[ 'denom' ], isNotNull );

    });

    test( 'should also parse dfrac and tfrac', () {

      toParse( expression: dfracExpression );

      toParse( expression: tfracExpression );

    });

    test( 'should parse dfrac and tfrac as fracs', () {

      List<ParseNode> treeA = toParse( expression: dfracExpression );
      ParseNode parseNodeA = treeA[ 0 ];

      expect( parseNodeA.type, matches( new RegExp( 'frac' ) ) );
      expect( parseNodeA.value[ 'numer' ], isNotNull );
      expect( parseNodeA.value[ 'denom' ], isNotNull );

      List<ParseNode> treeB = toParse( expression: tfracExpression );
      ParseNode parseNodeB = treeB[ 0 ];

      expect( parseNodeB.type, matches( new RegExp( 'frac' ) ) );
      expect( parseNodeB.value[ 'numer' ], isNotNull );
      expect( parseNodeB.value[ 'denom' ], isNotNull );

    });

  });

  group( 'An over parser', () {

    String simpleOver = '1 \\over x';
    String complexOver = '1+2i \\over 3+4i';

    test( 'should not fail', () {

      toParse( expression: simpleOver );

      toParse( expression: complexOver );

    });

    test( 'should produce a frac', () {

      List<ParseNode> treeA = toParse( expression: simpleOver );
      ParseNode parseNodeA = treeA[ 0 ];

      expect( parseNodeA.type, matches( new RegExp( 'frac' ) ) );
      expect( parseNodeA.value[ 'numer' ], isNotNull );
      expect( parseNodeA.value[ 'denom' ], isNotNull );

      List<ParseNode> treeB = toParse( expression: complexOver );
      ParseNode parseNodeB = treeB[ 0 ];

      expect( parseNodeB.type, matches( new RegExp( 'frac' ) ) );
      expect( parseNodeB.value[ 'numer' ], isNotNull );
      expect( parseNodeB.value[ 'denom' ], isNotNull );

    });

    test( 'should create a numerator from the atoms before \\over', () {

      List<ParseNode> tree = toParse( expression: complexOver );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.value[ 'numer' ].value.length, 4 );

    });

    test( 'should create a demonimator from the atoms after \\over', () {

      List<ParseNode> tree = toParse( expression: complexOver );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.value[ 'denom' ].value.length, 4 );

    });

    test( 'should handle empty numerators', () {

      String emptyNumerator = '\\over x';

      List<ParseNode> tree = toParse( expression: emptyNumerator );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.type, matches( new RegExp( 'frac' ) ) );
      expect( parseNode.value[ 'numer' ], isNotNull );
      expect( parseNode.value[ 'denom' ], isNotNull );

    });

    test( 'should handle empty denominators', () {

      String emptyDenominator = '1 \\over';

      List<ParseNode> tree = toParse( expression: emptyDenominator );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.type, matches( new RegExp( 'frac' ) ) );
      expect( parseNode.value[ 'numer' ], isNotNull );
      expect( parseNode.value[ 'denom' ], isNotNull );

    });

    test( 'should handle \\displaystyle correctly', () {

      String displaystyleExpression = '\\displaystyle 1 \\over 2';

      List<ParseNode> tree = toParse( expression: displaystyleExpression );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.type, matches( new RegExp( 'frac' ) ) );

      expect( parseNode.value[ 'numer' ].value[ 0 ].type,
              matches( new RegExp('styling') ) );

      expect( parseNode.value[ 'denom' ], isNotNull );

    });

    test( 'should handle nested factions', () {

      String nestedOverExpression = '{1 \\over 2} \\over 3';

      List<ParseNode> tree = toParse( expression: nestedOverExpression );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.type, matches( new RegExp( 'frac' ) ) );

      expect( parseNode.value[ 'numer' ].value[ 0 ].type,
              matches( new RegExp('frac') ) );

      expect( parseNode.value[ 'numer' ].value[ 0 ].value[ 'numer' ].value[ 0 ].value, '1' );

      expect( parseNode.value[ 'numer' ].value[ 0 ].value[ 'denom' ].value[ 0 ].value, '2' );

      expect( parseNode.value[ 'denom' ], isNotNull );

      expect( parseNode.value[ 'denom' ].value[ 0 ].value, '3' );

    });

    test( 'should fail with multiple overs in the same group', () {

      String badMultipleOvers = '1 \\over 2 + 3 \\over 4';

      expect( () => toParse( expression: badMultipleOvers ),
              throwsA( new isInstanceOf<ParseError>() ) );

    });

  });

  group( 'A sizing parser', () {

    String sizeExpression = '\\Huge{x}\\small{x}';
    String nestedSizeExpression = '\\Huge{\\small{x}}';

    test( 'should not fail', () {

      toParse( expression: sizeExpression );

    });

    test( 'should produce a sizing node', () {

      List<ParseNode> tree = toParse( expression: sizeExpression );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.type, matches( new RegExp( 'sizing' ) ) );
      expect( parseNode.value, isNotNull );

    });

  });

  group( 'A text parser', () {

    String textExpression = '\\text{a b}';
    String noBraceTextExpression = '\\text x';
    String nestedTextExpression =
                      '\\text{a {b} \\blue{c} \\color{#fff}{x} \\llap{x}}';
    String spaceTextExpression = '\\text{  a \\ }';
    String leadingSpaceTextExpression = '\\text {moo}';
    String badTextExpression = '\\text{a b%}';
    String badFunctionExpression = '\\text{\\sqrt{x}}';

    test( 'should not fail', () {

      toParse( expression: textExpression );

    });

    test( 'should produce a text', () {

      List<ParseNode> tree = toParse( expression: textExpression );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.type, matches( new RegExp( 'text' ) ) );
      expect( parseNode.value, isNotNull );

    });

    test( 'should produce textords instead of mathords', () {

      List<ParseNode> tree = toParse( expression: textExpression );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.value[ 'body' ][ 0 ].type, matches( new RegExp( 'textord' ) ) );

    });

    test( 'should not parse bad text', () {

      expect( () => toParse( expression: badTextExpression ),
              throwsA( new isInstanceOf<ParseError>() ) );

    });

    test( 'should not parse bad functions inside text', () {

      expect( () => toParse( expression: badFunctionExpression ),
              throwsA( new isInstanceOf<ParseError>() ) );

    });

    test( 'should parse text wtesth no braces around test', () {

      toParse( expression: noBraceTextExpression );

    });

    test( 'should parse nested expressions', () {

      toParse( expression: nestedTextExpression );

    });

    test( 'should contract spaces', () {

      List<ParseNode> tree = toParse( expression: spaceTextExpression );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.value[ 'body' ][ 0 ].type,
              matches( new RegExp( 'spacing' ) ) );

      expect( parseNode.value[ 'body' ][ 1 ].type,
              matches( new RegExp( 'textord' ) ) );

      expect( parseNode.value[ 'body' ][ 2 ].type,
              matches( new RegExp( 'spacing' ) ) );

      expect( parseNode.value[ 'body' ][ 3 ].type,
              matches( new RegExp( 'spacing' ) ) );

    });

    test( 'should ignore a space before the text group', () {

      List<ParseNode> tree = toParse( expression: leadingSpaceTextExpression );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.value[ 'body' ].length, 3 );
      expect( parseNode.value[ 'body' ].map( (n) => n.value ).join(''), 'moo' );

    });

  });

  group( 'A color parser', () {

    String colorExpression = '\\blue{x}';
    String customColorExpression = '\\color{#fA6}{x}';
    String badCustomColorExpression = '\\color{bad-color}{x}';

    test( 'should not fail', () {

      toParse( expression: colorExpression );

    });

    test( 'should build a color node', () {

      List<ParseNode> tree = toParse( expression: colorExpression );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.type, matches( new RegExp( 'color' ) ) );
      expect( parseNode.value[ 'color' ], isNotNull );
      expect( parseNode.value[ 'value' ], isNotNull );

    });

    test( 'should parse a custom color', () {

      toParse( expression: customColorExpression );

    });

    test( 'should correctly extract the custom color', () {

      List<ParseNode> tree = toParse( expression: customColorExpression );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.value[ 'color' ], matches( new RegExp( '#fA6' ) ) );

    });

    test( 'should not parse a bad custom color', () {

      expect( () => toParse( expression: badCustomColorExpression ),
              throwsA( new isInstanceOf<ParseError>() ) );

    });

  });

  group( 'A tie parser', () {

    String mathTie = 'a~b';
    String textTie = '\\text{a~ b}';

    test( 'should parse ties in math mode', () {

      toParse( expression: mathTie );

    });

    test( 'should parse ties in text mode', () {

      toParse( expression: textTie );

    });

    test( 'should produce spacing in math mode', () {

      List<ParseNode> tree = toParse( expression: mathTie );
      ParseNode parseNode = tree[ 1 ];

      expect( parseNode.type, matches( new RegExp( 'spacing' ) ) );

    });

    test( 'should produce spacing in text mode', () {

      List<ParseNode> tree = toParse( expression: textTie );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.value[ 'body' ][ 1 ].type ,
              matches( new RegExp( 'spacing' ) ) );

    });

    test( 'should not contract with spaces in text mode', () {

      List<ParseNode> tree = toParse( expression: textTie );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.value[ 'body' ][ 2 ].type,
              matches( new RegExp( 'spacing' ) ) );

    });

  });

  group( 'A delimiter sizing parser', () {

    String normalDelim = '\\bigl |';
    String notDelim = '\\bigl x';
    String bigDelim = '\\Biggr \\langle';

    test( 'should parse normal delimiters', () {

      toParse( expression: normalDelim );

      toParse( expression: bigDelim );

    });

    test( 'should not parse not-delimiters', () {

      expect( () => toParse( expression: notDelim ),
              throwsA( new isInstanceOf<ParseError>() ) );

    });

    test( 'should produce a delimsizing', () {

      List<ParseNode> tree = toParse( expression: normalDelim );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.type, matches( new RegExp( 'delimsizing' ) ) );

    });

    test( 'should produce the correct direction delimiter', () {

      List<ParseNode> treeA = toParse( expression: normalDelim );
      ParseNode parseNodeA = treeA[ 0 ];

      expect( parseNodeA.value[ 'delimType' ], matches( new RegExp( 'open' ) ) );

      List<ParseNode> treeB = toParse( expression: bigDelim );
      ParseNode parseNodeB = treeB[ 0 ];

      expect( parseNodeB.value[ 'delimType' ], matches( new RegExp( 'close' ) ) );

    });

    test( 'should parse the correct size delimiter', () {

      List<ParseNode> treeA = toParse( expression: normalDelim );
      ParseNode parseNodeA = treeA[ 0 ];

      expect( parseNodeA.value[ 'size' ], 1 );

      List<ParseNode> treeB = toParse( expression: bigDelim );
      ParseNode parseNodeB = treeB[ 0 ];

      expect( parseNodeB.value[ 'size' ], 4 );

    });

  });

  group( 'An overline parser', () {

    String overline = '\\overline{x}';

    test( 'should not fail', () {

      toParse( expression: overline );

    });

    test( 'should produce an overline', () {

      List<ParseNode> tree = toParse( expression: overline );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.type, matches( new RegExp( 'overline' ) ) );

    });

  });

  group( 'A rule parser', () {

    String emRule = '\\rule{1em}{2em}';
    String exRule = '\\rule{1ex}{2em}';
    String badUnitRule = '\\rule{1px}{2em}';
    String noNumberRule = '\\rule{1em}{em}';
    String incompleteRule = '\\rule{1em}';
    String hardNumberRule = '\\rule{   01.24ex}{2.450   em   }';

    test( 'should not fail', () {

      toParse( expression: emRule );
      toParse( expression: exRule );

    });

    test( 'should not parse invalid units', () {

      expect( () => toParse( expression: badUnitRule ),
              throwsA( new isInstanceOf<ParseError>() ) );

      expect( () => toParse( expression: noNumberRule ),
              throwsA( new isInstanceOf<ParseError>() ) );

    });

    test( 'should not parse incomplete rules', () {

      expect( () => toParse( expression: incompleteRule ),
              throwsA( new isInstanceOf<ParseError>() ) );

    });

    test( 'should produce a rule', () {

      List<ParseNode> tree = toParse( expression: emRule );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.type, matches( new RegExp( 'rule' ) ) );

    });

    test( 'should list the correct units', () {

      List<ParseNode> treeA = toParse( expression: emRule );
      ParseNode parseNodeA = treeA[ 0 ];

      expect( parseNodeA.value[ 'width' ][ 'unit' ],
              matches( new RegExp( 'em' ) ) );

      expect( parseNodeA.value[ 'height' ][ 'unit' ],
              matches( new RegExp( 'em' ) ) );

      List<ParseNode> treeB = toParse( expression: exRule );
      ParseNode parseNodeB = treeB[ 0 ];

      expect( parseNodeB.value[ 'width' ][ 'unit' ],
              matches( new RegExp( 'ex' ) ) );

      expect( parseNodeB.value[ 'height' ][ 'unit' ],
              matches( new RegExp( 'em' ) ) );

    });

    test( 'should parse the number correctly', () {

      List<ParseNode> tree = toParse( expression: hardNumberRule );
      ParseNode parseNode = tree[ 0 ];

      expect( double.parse( parseNode.value[ 'width' ][ 'number' ] ), 1.24 );
      expect( double.parse( parseNode.value[ 'height' ][ 'number' ] ), 2.45 );

    });

    test( 'should parse negative sizes', () {

      List<ParseNode> tree = toParse( expression: '\\rule{-1em}{- 0.2em}' );
      ParseNode parseNode = tree[ 0 ];

      expect( double.parse( parseNode.value[ 'width' ][ 'number' ] ), -1 );
      expect( double.parse( parseNode.value[ 'height' ][ 'number' ] ), -0.2 );

    });

  });

  group( 'A left/right parser', () {

    String normalLeftRight = '\\left( \\dfrac{x}{y} \\right)';
    String emptyRight = '\\left( \\dfrac{x}{y} \\right.';

    test( 'should not fail', () {

      toParse( expression: normalLeftRight );

    });

    test( 'should produce a leftright', () {

      List<ParseNode> tree = toParse( expression: normalLeftRight );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.type, matches( new RegExp( 'leftright' ) ) );

      expect( parseNode.value[ 'left' ][ 'value' ],
              matches( new RegExp( '\\(' ) ) );

      expect( parseNode.value[ 'right' ][ 'value' ],
              matches( new RegExp( '\\)' ) ) );

    });

    test( 'should error when test is mismatched', () {

      String unmatchedLeft = '\\left( \\dfrac{x}{y}';
      String unmatchedRight = '\\dfrac{x}{y} \\right)';

      expect( () => toParse( expression: unmatchedLeft ),
              throwsA( new isInstanceOf<ParseError>() ) );

      expect( () => toParse( expression: unmatchedRight ),
              throwsA( new isInstanceOf<ParseError>() ) );

    });

    test( 'should error when braces are mismatched', () {

      String unmatched = '{ \\left( \\dfrac{x}{y} } \\right)';

      expect( () => toParse( expression: unmatched ),
              throwsA( new isInstanceOf<ParseError>() ) );

    });

    test( 'should error when non-delimiters are provided', () {

      String nonDelimiter = r'\\left$ \\dfrac{x}{y} \\right)';

      expect( () => toParse( expression: nonDelimiter ),
              throwsA( new isInstanceOf<ParseError>() ) );

    });

    test( 'should parse the empty "." delimiter', () {

      toParse( expression: emptyRight );

    });

    test( 'should parse the "." delimiter with normal sizes', () {

      String normalEmpty = '\\Bigl .';

      toParse( expression: normalEmpty );

    });

  });

  group( 'A sqrt parser', () {

    String sqrt = '\\sqrt{x}';
    String missingGroup = '\\sqrt';

    test( 'should parse square roots', () {

      toParse( expression: sqrt );

    });

    test( 'should error when there is no group', () {

      expect( () => toParse( expression: missingGroup ),
              throwsA( new isInstanceOf<ParseError>() ) );

    });

    test( 'should produce sqrts', () {

      List<ParseNode> tree = toParse( expression: sqrt );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.type, matches( new RegExp( 'sqrt' ) ) );

    });

  });

  group( 'A TeX-compliant parser', () {

    test( 'should work', () {

      toParse( expression: '\\frac 2 3' );

    });

    test( 'should fail if there are not enough arguments', () {

      List<String> missingGroups = [
        '\\frac{x}',
        '\\color{#fff}',
        '\\rule{1em}',
        '\\llap',
        '\\bigl',
        '\\text'
      ];

      missingGroups.forEach( (group) {

        expect( () => toParse( expression: group ),
                throwsA( new isInstanceOf<ParseError>() ) );

      });

    });

    test( 'should fail when there are missing sup/subscripts', () {

      expect( () => toParse( expression: 'x^' ),
              throwsA( new isInstanceOf<ParseError>() ) );

      expect( () => toParse( expression: 'x_' ),
              throwsA( new isInstanceOf<ParseError>() ) );

    });

    test( 'should fail when arguments require arguments', () {

      List<String> badArguments = [
        '\\frac \\frac x y z',
        '\\frac x \\frac y z',
        '\\frac \\sqrt x y',
        '\\frac x \\sqrt y',
        '\\frac \\llap x y',
        '\\frac x \\llap y',
        '\\llap \\llap x',
        '\\sqrt \\llap x'
      ];

      badArguments.forEach( (argument) {

        expect( () => toParse( expression: argument ),
                throwsA( new isInstanceOf<ParseError>() ) );

      });

    });

    test( 'should work when the arguments have braces', () {

      List<String> goodArguments = [
        '\\frac {\\frac x y} z',
        '\\frac x {\\frac y z}',
        '\\frac {\\sqrt x} y',
        '\\frac x {\\sqrt y}',
        '\\frac {\\llap x} y',
        '\\frac x {\\llap y}',
        '\\llap {\\frac x y}',
        '\\llap {\\llap x}',
        '\\sqrt {\\llap x}'
      ];

      goodArguments.forEach( (argument) {

        toParse( expression: argument );

      });

    });

    test( 'should fail when sup/subscripts require arguments', () {

      List<String> badSupSubscripts = [
        'x^\\sqrt x',
        'x^\\llap x',
        'x_\\sqrt x',
        'x_\\llap x'
      ];

      badSupSubscripts.forEach( (supSubscript) {

        expect( () => toParse( expression: supSubscript ),
                throwsA( new isInstanceOf<ParseError>() ) );

      });

    });

    test( 'should work when sup/subscripts arguments have braces', () {

      List<String> goodSupSubscripts = [
        'x^{\\sqrt x}',
        'x^{\\llap x}',
        'x_{\\sqrt x}',
        'x_{\\llap x}'
      ];

      goodSupSubscripts.forEach( (supSubscript) {

        toParse( expression: supSubscript );

      });

    });

    test( 'should parse multiple primes correctly', () {

      toParse( expression: "x''''" );
      toParse( expression: "x_2''" );
      toParse( expression: "x''_2" );
      toParse( expression: "x'_2'" );

    });

    test( 'should fail when sup/subscripts are interspersed with arguments', () {

      expect( () => toParse( expression: '\\sqrt^23' ),
              throwsA( new isInstanceOf<ParseError>() ) );

      expect( () => toParse( expression: '\\frac^234' ),
              throwsA( new isInstanceOf<ParseError>() ) );

      expect( () => toParse( expression: '\\frac2^34' ),
              throwsA( new isInstanceOf<ParseError>() ) );

    });

    test( 'should succeed when sup/subscripts come after whole functions', () {

      toParse( expression: '\\sqrt2^3' );
      toParse( expression: '\\frac23^4' );

    });

    test( 'should succeed with a sqrt around a text/frac', () {

      toParse( expression: '\\sqrt \\frac x y' );
      toParse( expression: '\\sqrt \\text x' );
      toParse( expression: 'x^\\frac x y' );
      toParse( expression: 'x_\\text x' );

    });

    test( 'should fail when arguments are \\left', () {

      List<String> badLeftArguments = [
        '\\frac \\left( x \\right) y',
        '\\frac x \\left( y \\right)',
        '\\llap \\left( x \\right)',
        '\\sqrt \\left( x \\right)',
        'x^\\left( x \\right)'
      ];

      badLeftArguments.forEach( (argument) {

        expect( () => toParse( expression: argument ),
                throwsA( new isInstanceOf<ParseError>() ) );

      });

    });

    test( 'should succeed when there are braces around the \\left/\\right', () {

      List<String> goodLeftArguments = [
        '\\frac {\\left( x \\right)} y',
        '\\frac x {\\left( y \\right)}',
        '\\llap {\\left( x \\right)}',
        '\\sqrt {\\left( x \\right)}',
        'x^{\\left( x \\right)}'
      ];

      goodLeftArguments.forEach( (argument) {

        toParse( expression: argument );

      });

    });

  });

  group( 'A style change parser', () {

    test( 'should not fail', () {

      toParse( expression: '\\displaystyle x' );
      toParse( expression: '\\textstyle x' );
      toParse( expression: '\\scriptstyle x' );
      toParse( expression: '\\scriptscriptstyle x' );

    });

    test( 'should produce the correct style', () {

      List<ParseNode> treeA = toParse( expression: '\\displaystyle x' );
      ParseNode parseNodeA = treeA[ 0 ];

      expect( parseNodeA.value[ 'style' ],
              matches( new RegExp( 'display' ) ) );

      List<ParseNode> treeB = toParse( expression: '\\scriptscriptstyle x' );
      ParseNode parseNodeB = treeB[ 0 ];

      expect( parseNodeB.value[ 'style' ],
              matches( new RegExp( 'scriptscript' ) ) );

    });

    test( 'should only change the style within its group', () {

      String text = 'a b { c d \\displaystyle e f } g h';

      List<ParseNode> tree = toParse( expression: text );
      ParseNode parseNode = tree[ 2 ];

      ParseNode displayNode = parseNode.value[ 2 ];

      expect( displayNode.type, matches( new RegExp( 'styling' ) ) );

      List<ParseNode> displayBody = displayNode.value[ 'value' ];

      expect( displayBody.length, 2 );
      expect( displayBody[ 0 ].value, matches( new RegExp( 'e' ) ) );

    });

  });

  group( 'A bin builder', () {

    test( 'should create mbins normally', () {

      List<SymbolNode> symbols = getBuilt( expression: 'x + y' );

      expect( symbols[ 1 ].classes.contains( 'mbin' ), isTrue );

    });

    test( 'should create ords when at the beginning of lists', () {

      List<SymbolNode> symbols = getBuilt( expression: '+ x' );

      expect( symbols[ 0 ].classes.contains( 'mord' ), isTrue );
      expect( symbols[ 0 ].classes.contains( 'mbin' ), isFalse );

    });

    test( 'should create ords after some other objects', () {

      expect( getBuilt( expression: 'x + + 2' )[ 2 ].classes.contains( 'mord' ),
              isTrue );

      expect( getBuilt( expression: '( + 2' )[ 1 ].classes.contains( 'mord' ),
              isTrue );

      expect( getBuilt( expression: '= + 2' )[ 1 ].classes.contains( 'mord' ),
              isTrue );

      expect( getBuilt( expression: '\\sin + 2' )[ 1 ].classes.contains( 'mord' ),
              isTrue );

      expect( getBuilt( expression: ', + 2' )[ 1 ].classes.contains( 'mord' ),
              isTrue );

    });

    test( 'should correctly interact with color objects', () {

      expect( getBuilt( expression: '\\blue{x}+y' )[ 1 ].classes.contains( 'mbin' ),
              isTrue );

      expect( getBuilt( expression: '\\blue{x+}+y' )[ 1 ].classes.contains( 'mord' ),
              isTrue );

    });

  });

  group( 'A markup generator', () {

    test( 'marks trees up', () {

      Katex katex = new Katex();
      String markup = katex.renderToString( '\\sigma^2' );

      expect( markup.indexOf( '<span' ), 0 );
      expect( markup.contains( '\u03c3' ), isTrue );
      expect( markup.contains( 'margin-right' ), isTrue );
      expect( markup.contains( 'marginRight' ), isFalse );

    });

  });

  group( 'An accent parser', () {

    test( 'should not fail', () {

      toParse( expression: '\\vec{x}' );
      toParse( expression: '\\vec{x^2}' );
      toParse( expression: '\\vec{x}^2' );
      toParse( expression: '\\vec x' );

    });

    test( 'should produce accents', () {

      List<ParseNode> tree = toParse( expression: '\\vec x' );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.type, matches( new RegExp( 'accent' ) ) );

    });

    test( 'should be grouped more tightly than supsubs', () {

      List<ParseNode> tree = toParse( expression: '\\vec x^2' );
      ParseNode parseNode = tree[ 0 ];

      expect( parseNode.type, matches( new RegExp( 'supsub' ) ) );

    });

    test( 'should not parse expanding accents', () {

      expect( () => toParse( expression: '\\widehat{x}' ),
              throwsA( new isInstanceOf<ParseError>() ) );

    });

  });

  group( 'An accent builder', () {

    test( 'should not fail', () {

      toBuild( expression: '\\vec{x}' );
      toBuild( expression: '\\vec{x}^2' );
      toBuild( expression: '\\vec{x}_2' );
      toBuild( expression: '\\vec{x}_2^2' );

    });

    test( 'should produce mords', () {

      expect( getBuilt( expression: '\\vec x' )[ 0 ].classes.contains( 'mord' ),
              isTrue );

      expect( getBuilt( expression: '\\vec +' )[ 0 ].classes.contains( 'mord' ),
              isTrue );

      expect( getBuilt( expression: '\\vec +' )[ 0 ].classes.contains( 'mbin' ),
              isFalse );

      expect( getBuilt( expression: '\\vec )^2' )[ 0 ].classes.contains( 'mord' ),
              isTrue );

      expect( getBuilt( expression: '\\vec )^2' )[ 0 ].classes.contains( 'mclose' ),
              isFalse );

    });

  });

  group( 'A parser error', () {

    test( 'should report the position of an error', () {

      try {
        toParse( expression: '\\sqrt}' );
      } catch ( e ) {
        expect( e.position , 5 );
      }

    });

  });

  group( 'An optional argument parser', () {

    test( 'should not fail', () {

      toParse( expression: '\\frac[1]{2}{3}' );
      toParse( expression: '\\rule[0.2em]{1em}{1em}' );

    });

    test( 'should fail on sqrts for now', () {

      expect( () => toParse( expression: '\\sqrt[3]{2}' ),
      throwsA( new isInstanceOf<ParseError>() ) );

    });

    test( 'should work when the optional argument is missing', () {

      toParse( expression: '\\sqrt{2}' );
      toParse( expression: '\\rule{1em}{2em}' );

    });

    test( 'should fail when the optional argument is malformed', () {

      expect( () => toParse( expression: '\\rule[1]{2em}{3em}' ),
      throwsA( new isInstanceOf<ParseError>() ) );

    });

    test( 'should not work if the optional argument is not closed', () {

      expect( () => toParse( expression: '\\sqrt[' ),
      throwsA( new isInstanceOf<ParseError>() ) );

    });

  });

}