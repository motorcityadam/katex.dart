library katex.parse_result;

import 'parse_node.dart';


class ParseResult {

	final List<ParseNode> result;
	final int position;

	ParseResult( 
		{ List<ParseNode> result: null,
		  int position: 0 } )
	: this._init( 
		result: result,
		position: position );

	ParseResult._init(
		{ this.result,
		  this.position} ) {

  	}

}