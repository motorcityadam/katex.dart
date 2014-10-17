// TODO(adamjcook): The implementation of the Options object seems a little hackish for Dart. Better implementation?
// TODO(adamjcook): Add library description.
library katex.options;

import 'tex_style.dart';


// TODO(adamjcook): Add class description.
class Options {

	final TexStyle style;
	final String color;
	final String size;

	TexStyle parentStyle;
	String parentSize;

	/**
	 * A map of Katex color names to CSS colors.
	 */
	Map<String, String> _colorMap = {

	    "katex-blue": "#6495ed",
	    "katex-orange": "#ffa500",
	    "katex-pink": "#ff00af",
	    "katex-red": "#df0030",
	    "katex-green": "#28ae7b",
	    "katex-gray": "gray",
	    "katex-purple": "#9d38bd"

	};

	Options(
		{ TexStyle style,
		  String color,
		  String size: '',
		  TexStyle parentStyle: null,
		  String parentSize: '' } )
	: this._init(
		style: style,
		color: color,
		size: size,
		parentStyle: parentStyle,
		parentSize: parentSize );

	Options._init(
		{ this.style,
		  this.color,
		  this.size,
		  this.parentStyle,
		  this.parentSize } ) {

		if ( parentStyle == null ) {
        	parentStyle = style;
    	}

    	this.parentStyle = parentStyle;

    	if ( parentSize == '' ) {
        	parentSize = size;
    	}

    	this.parentSize = parentSize;

	}

	/**
	 * Return a new [Options] object from the base [Options] object with the
	 * provided color.
	 */
	Options withColor ( String color ) {

		return new Options(
			style: this.style,
			color: color,
			size: this.size,
			parentStyle: this.style,
			parentSize: this.size );

	}

	/**
	 * Return a new [Options] object from the base [Options] object with the
	 * provided size.
	 */
	Options withSize ( String size ) {

		return new Options(
			style: this.style,
			color: this.color,
			size: size,
			parentStyle: this.style,
			parentSize: this.size );

	}

	/**
	 * Return a new [Options] object from the base [Options] object with the
	 * provided [TexStyle] object.
	 */
	Options withStyle ( TexStyle style ) {

		return new Options(
			style: style,
			color: this.color,
			size: this.size,
			parentStyle: this.style,
			parentSize: this.size );

	}

	/**
	 * Created a new [Options] object with the same style, size and color from
	 * the base [Options] object.
	 */
	Options reset () {

		return new Options(
			style: this.style,
			color: this.color,
			size: this.size,
			parentStyle: this.style,
			parentSize: this.size );

	}

	/**
	 * Get the CSS color of the base [Options] object.
	 */
	String getColor () {

    if ( _colorMap.containsKey( color ) ) {
      return _colorMap[ color ];
    } else {
      return color;
    }

	}

}