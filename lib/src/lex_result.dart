library katex.lex_result;


// TODO(adamjcook): Add class description.
class LexResult {

  // TOOD(adamjcook): 'text' property should have a fixed, known type
	final String type;
	final dynamic text;
	final num position;

	LexResult(
		{ String type: '',
      dynamic text: '',
		  num position: 0 } )
	: this._init(
		type: type,
		text: text,
		position: position );

	LexResult._init(
		{ this.type,
		  this.text,
		  this.position } ) { }

}