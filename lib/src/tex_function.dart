// TODO(adamjcook): Add library description.
library katex.tex_function;


// TODO(adamjcook): Add class description.
class TexFunction {

	final int numArgs;
	final bool allowedInText;
	final List<String> argTypes;
	final int greediness;
  final int numOptionalArgs;
	final dynamic handler;

	TexFunction(
		{ int numArgs: 0,
		  bool allowedInText: false,
		  List<String> argTypes: null,
		  int greediness: 1,
      int numOptionalArgs: 0,
		  dynamic handler: null } )
	: this._init(
		numArgs: numArgs,
		allowedInText: allowedInText,
		argTypes: argTypes,
		greediness: greediness,
    numOptionalArgs: numOptionalArgs,
		handler: handler );

	TexFunction._init(
		{ this.numArgs,
		  this.allowedInText,
		  this.argTypes,
		  this.greediness,
      this.numOptionalArgs,
		  this.handler } ) { }

}