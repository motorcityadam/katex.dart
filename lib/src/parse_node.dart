library katex.parse_node;


// TODO(adamjcook): Add class description.
// TODO(adamjcook): `type` property should be final.
// TODO(adamjcook): `value` property should not be dynamic.
class ParseNode {

	String type;
	final dynamic value;
	final String mode;

	ParseNode( 
		{ String type: '',
		  dynamic value: null,
		  String mode: '' } )
	: this._init( 
		type: type,
		value: value,
		mode: mode );

	ParseNode._init(
		{ this.type,
		  this.value,
		  this.mode} ) { }

}