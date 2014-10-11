// TODO(adamjcook): Add library description.
library katex;

import 'dart:html';

import 'package:logging/logging.dart';

import './src/build_tree.dart';
import './src/functions.dart';
import './src/parser.dart';

import './src/parse_error.dart';
export './src/parse_error.dart';

import './src/parse_node.dart';
import './src/symbols.dart';


final Logger _logger = new Logger( 'katex' );


// TODO(adamjcook): Add class description.
class Katex {

	final bool loggingEnabled;

	Katex( { bool loggingEnabled: false } )
		: this._init( loggingEnabled: loggingEnabled );

	Katex._init( { this.loggingEnabled } ) {
	    if ( this.loggingEnabled == true ) {
	      Logger.root.level = Level.ALL;
	      Logger.root.onRecord.listen(( LogRecord rec ) {
	        print( '${rec.level.name}: ${rec.time}: ${rec.message}' );
	      });
	    }

	    initSymbols();
	    initFunctions();

  	}

	/**
	 * Parse the raw [String] and build a formatted mathematical expression. The
	 * resulting expression is placed in the [Element] provided.
	 */
  	void render ( String toParse, Element baseElement ) {

  		baseElement.setInnerHtml('');

  		var parser = new Parser(
  			expression: toParse,
  			loggingEnabled: loggingEnabled );

  		List<ParseNode> tree = parser.parse();
  		SpanElement node = buildTree( tree: tree ).toNode();

  		baseElement.append( node );

  	}

}