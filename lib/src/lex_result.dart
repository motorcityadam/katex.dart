library katex.lex_result;


// TODO(adamjcook): Add class description.
class LexResult {

	final String type;
	final String text;
	final num position;

	LexResult( 
		{ String type: '',
		  String text: '',
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