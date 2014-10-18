library katex.parse_func_or_argument;

import 'parse_result.dart';


// TODO(adamjcook): Add class description.
class ParseFuncOrArgument {

	final ParseResult result;
	final bool isFunction;
	final bool isAllowedInText;
	final int numArgs;
  final int numOptionalArgs;
	final List<String> argTypes;

	ParseFuncOrArgument(
		{ ParseResult result: null,
		  bool isFunction: false,
		  bool isAllowedInText: false,
		  int numArgs: 0,
      int numOptionalArgs: 0,
		  List<String> argTypes: null } )
	: this._init(
		result: result,
		isFunction: isFunction,
		isAllowedInText: isAllowedInText,
		numArgs: numArgs,
    numOptionalArgs: numOptionalArgs,
		argTypes: argTypes );

	ParseFuncOrArgument._init(
		{ this.result,
		  this.isFunction,
		  this.isAllowedInText,
		  this.numArgs,
      this.numOptionalArgs,
		  this.argTypes } ) { }

}