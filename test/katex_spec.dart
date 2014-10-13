library katex_spec;

import 'package:unittest/unittest.dart';

import 'package:katex/katex.dart';


main() {

	unittestConfiguration.timeout = new Duration( seconds: 5 );

	group( 'Parser', () {

   test( 'should ignore whitespace', () {

   Katex katex = new Katex( loggingEnabled: false );

   Parser parserA = new Parser(
               expression: 'xy',
               loggingEnabled: false );

List<ParseNode> treeA = parserA.parse();

  Parser parserB = new Parser(
              expression: '    x    y    ',
  loggingEnabled: false );

  List<ParseNode> treeB = parserB.parse();

  expect( treeA[0].value, treeB[0].value );
  expect( treeA[1].value, treeB[1].value );

    });

		test( 'should ignore whitespace', () {

			Katex katex = new Katex( loggingEnabled: false );

			Parser parserA = new Parser(
									expression: 'xy',
									loggingEnabled: false );

			List<ParseNode> treeA = parserA.parse();

     Parser parserB = new Parser(
                 expression: '    x    y    ',
                 loggingEnabled: false );

     List<ParseNode> treeB = parserB.parse();

     expect( treeA[0].value, treeB[0].value );
     expect( treeA[1].value, treeB[1].value );

		});

	});

}