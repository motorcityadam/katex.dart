// TODO(adamjcook): Add library description.
library katex.tex_symbol;


// TODO(adamjcook): Add class description.
class TexSymbol {

	final String font;
	final String group;
	final String replace;

	TexSymbol( 
		{ String font: '',
		  String group: '',
		  String replace: '' } )
	: this._init( 
		font: font,
		group: group,
		replace: replace );

	TexSymbol._init(
		{ this.font,
		  this.group,
		  this.replace } ) { }

}