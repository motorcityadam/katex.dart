// TODO(adamjcook): The implementation of the TexStyle object seems a little hackish for Dart. Better implementation?
// TODO(adamjcook): Add library description.
library katex.tex_style;

import 'styles.dart' as styles;


// TODO(adamjcook): Add class description.
class TexStyle {

	final int id;
	final int size;
	final bool isCramped;
	final num sizeMultiplier;

	TexStyle( 
		{ int id,
		  int size,
		  bool isCramped: false,
		  num sizeMultiplier: 1.0 } )
	: this._init( 
		id: id,
		size: size,
		isCramped: isCramped,
		sizeMultiplier: sizeMultiplier );

	TexStyle._init(
		{ this.id,
		  this.size,
		  this.isCramped,
		  this.sizeMultiplier } ) { }

	/**
	 * Get the [TexStyle] of the superscript from the base [TexStyle] object.
	 */ 
	TexStyle sup () {

		return styles.styles[ styles.sup[ id ] ];

	}

	/**
	 * Get the [TexStyle] of a subscript given from the base [TexStyle] object.
	 */
	TexStyle sub () {

		return styles.styles[ styles.sub[ id ] ];

	}

	/**
	 * Get the [TexStyle] of a fractional numerator from the base [TexStyle] object.
	 */ 
	TexStyle fracNum () {

		return styles.styles[ styles.fracNum[ id ] ];

	}

	/**
	 * Get the [TexStyle] of a fractional denominator from the base [TexStyle] object.
	 */ 
	TexStyle fracDen () {

		return styles.styles[ styles.fracDen[ id ] ];

	}

	/**
	 * Get the cramped version of the [TexStyle] object from the base [TexStyle] object.
	 * Note that cramping a crapmed style does not change the style.
	 */  
	TexStyle cramp () {

		return styles.styles[ styles.cramp[ id ] ];

	}

	/**
	 * Get the HTML class name based on the size class and on whether or not
	 * the base [TexStyle] is cramped.
	 */ 
	String HtmlClassName () {

		return styles.sizeNames[ size ] + ( isCramped ? " cramped" : " uncramped" );
	}

	/**
	 * Get the HTML reset class name.
	 */
	String ResetClassName () {

		return styles.resetNames[ size ];
	}

}