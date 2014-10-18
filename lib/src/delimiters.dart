// TODO(adamjcook): Add library description.
library katex.delimiters;

import 'dart:math' as Math;

import 'build_common.dart' as buildCommon;
import 'dom_node.dart';
import 'font_metrics.dart' as fontMetrics;
import 'options.dart';
import 'parse_error.dart';
import 'styles.dart' as styles;
import 'symbols.dart';
import 'tex_style.dart';


/**
 * Get the metrics [Map] for a given symbol and font, after transformation (i.e.
 * after following replacement from the 'katex.symbols' library).
 */
Map<String, num> getMetrics ( { String symbol, String font } ) {

    if ( symbols[ 'math' ][ symbol ] != null &&
         symbols[ 'math' ][ symbol ].replace != '' ) {

        return fontMetrics.getCharacterMetrics(
                            character: symbols[ 'math' ][ symbol ].replace,
                            style: font );

    } else {

        return fontMetrics.getCharacterMetrics(
                                        character: symbol,
                                        style: font );

    }

}

/**
 * Creates and returns a [SymbolNode] with the provided font size.
 */
SymbolNode makeRomanSize ( { String value, int size, String mode } ) {

    return buildCommon.makeSymbol( value: value,
                                   style: 'Size' + size.toString() + '-Regular',
                                   mode: mode );

}

/**
 * Creates and returns a delimiter [SpanNode] with a given [TexStyle], and adds
 * the adjusted height, depth, and maxFontSize.
 */
SpanNode styleWrap ( { DomNode delim, TexStyle toStyle, Options options } ) {

    SpanNode span = buildCommon.makeSpan(
        classes: [ 'style-wrap', options.reset(), toStyle.HtmlClassName() ],
        children: [ delim ] );

    num multiplier = toStyle.sizeMultiplier / options.style.sizeMultiplier;

    span.height *= multiplier;
    span.depth *= multiplier;
    span.maxFontSize = toStyle.sizeMultiplier;

    return span;

}

/**
 * Creates a small delimiter [SpanNode]. This is a delimiter that comes in the
 * 'Main-Regular' font, but is re-styled to either be in 'textstyle',
 * 'scriptstyle', or 'scriptscriptstyle'.
 */
SpanNode makeSmallDelim ( { String delim, TexStyle style, bool center,
                            Options options, String mode } ) {

    SymbolNode text = buildCommon.makeSymbol( value: delim,
                                              style: 'Main-Regular',
                                              mode: mode );

    SpanNode span = styleWrap( delim: text,
                               toStyle: style,
                               options: options );

    if ( center ) {

        num shift =
            (1 - options.style.sizeMultiplier / style.sizeMultiplier) *
            fontMetrics.metrics[ 'axisHeight' ];

        span.styles[ 'top' ] = shift.toString() + 'em';
        span.height -= shift;
        span.depth += shift;

    }

    return span;

}

/**
 * Makes a large delimiter [SpanNode]. This is a delimiter that comes in the
 * 'Size1', 'Size2', 'Size3', or 'Size4' fonts. It is always rendered in
 * 'textstyle'.
 */
SpanNode makeLargeDelim ( { String delim, int size, bool center,
                            Options options, String mode } ) {

    SymbolNode inner = makeRomanSize( value: delim,
                                      size: size,
                                      mode: mode );

    SpanNode span = styleWrap(
        delim: buildCommon.makeSpan(
            classes: [ 'delimsizing', 'size' + size.toString() ],
            children: [ inner ],
            color: options.getColor() ),
        toStyle: styles.TEXT,
        options: options );

    if ( center ) {

        num shift = ( 1 - options.style.sizeMultiplier ) *
            fontMetrics.metrics[ 'axisHeight' ];

        span.styles[ 'top' ] = shift.toString() + 'em';
        span.height -= shift;
        span.depth += shift;

    }

    return span;

}

/**
 * Create, return and wrap an inner span with the provided symbol and font.
 * This is used in the `makeStackedDelim` method to make the stacking pieces
 * for the delimiter.
 */
Map<String, dynamic> makeInner ( { String symbol, String font, String mode } ) {

    String sizeClass;

    // Apply the correct CSS class apply the desired font.
    if (font == 'Size1-Regular') {
        sizeClass = 'delim-size1';
    } else if (font == 'Size4-Regular') {
        sizeClass = 'delim-size4';
    }

    var inner = buildCommon.makeSpan(
        classes: [ 'delimsizinginner', sizeClass ],
        children: [ buildCommon.makeSpan(
            classes: [],
            children: [ buildCommon.makeSymbol(
                value: symbol, style: font, mode: mode ) ] )
        ] );

    // This will be eventually passed into `makeVerticalList`, therefore,
    // wrap the [SpanNode] element in the appropriate tag that the vertical list
    // expects.
    return { 'type': 'elem', 'elem': inner };

}

/**
 * Create and return a [SpanNode] stacked delimiter from a provided delimiter
 * with a total height that is, at least, the value of the `heightTotal`
 * argument provided.
 * This routine is mentioned on page 442 of the TeXbook.
 */
SpanNode makeStackedDelim ( { String delim, num heightTotal, bool center,
                              Options options, String mode } ) {

    // There are four parts - the top, an optional middle, a repeated part, and
    // a bottom.
    String top, middle, repeat, bottom;
    top = repeat = bottom = delim;
    middle = null;

    // Keep track of which font the encountered delimiters are in.
    var font = 'Size1-Regular';

    // The parts and font are set according to the symbol. Note that we use
    // '\u23d0' instead of '|' and '\u2016' instead of '\\|' for the
    // repeats of the arrows.
    if (delim == '\\uparrow') {
        repeat = bottom = '\u23d0';
    } else if (delim == '\\Uparrow') {
        repeat = bottom = '\u2016';
    } else if (delim == '\\downarrow') {
        top = repeat = '\u23d0';
    } else if (delim == '\\Downarrow') {
        top = repeat = '\u2016';
    } else if (delim == '\\updownarrow') {
        top = '\\uparrow';
        repeat = '\u23d0';
        bottom = '\\downarrow';
    } else if (delim == '\\Updownarrow') {
        top = '\\Uparrow';
        repeat = '\u2016';
        bottom = '\\Downarrow';
    } else if (delim == '|' || delim == '\\vert') {
    } else if (delim == '\\|' || delim == '\\Vert') {
    } else if (delim == '[' || delim == '\\lbrack') {
        top = '\u23a1';
        repeat = '\u23a2';
        bottom = '\u23a3';
        font = 'Size4-Regular';
    } else if (delim == ']' || delim == '\\rbrack') {
        top = '\u23a4';
        repeat = '\u23a5';
        bottom = '\u23a6';
        font = 'Size4-Regular';
    } else if (delim == '\\lfloor') {
        repeat = top = '\u23a2';
        bottom = '\u23a3';
        font = 'Size4-Regular';
    } else if (delim == '\\lceil') {
        top = '\u23a1';
        repeat = bottom = '\u23a2';
        font = 'Size4-Regular';
    } else if (delim == '\\rfloor') {
        repeat = top = '\u23a5';
        bottom = '\u23a6';
        font = 'Size4-Regular';
    } else if (delim == '\\rceil') {
        top = '\u23a4';
        repeat = bottom = '\u23a5';
        font = 'Size4-Regular';
    } else if (delim == '(') {
        top = '\u239b';
        repeat = '\u239c';
        bottom = '\u239d';
        font = 'Size4-Regular';
    } else if (delim == ')') {
        top = '\u239e';
        repeat = '\u239f';
        bottom = '\u23a0';
        font = 'Size4-Regular';
    } else if (delim == '\\{' || delim == '\\lbrace') {
        top = '\u23a7';
        middle = '\u23a8';
        bottom = '\u23a9';
        repeat = '\u23aa';
        font = 'Size4-Regular';
    } else if (delim == '\\}' || delim == '\\rbrace') {
        top = '\u23ab';
        middle = '\u23ac';
        bottom = '\u23ad';
        repeat = '\u23aa';
        font = 'Size4-Regular';
    } else if (delim == '\\surd') {
        top = '\ue001';
        bottom = '\u23b7';
        repeat = '\ue000';
        font = 'Size4-Regular';
    }

    // Get the metrics of the four sections.
    Map<String, num> topMetrics = getMetrics( symbol: top, font: font );
    num topHeightTotal = topMetrics[ 'height' ] + topMetrics[ 'depth' ];
    Map<String, num> repeatMetrics = getMetrics( symbol: repeat, font: font );
    num repeatHeightTotal = repeatMetrics[ 'height' ] + repeatMetrics[ 'depth' ];
    Map<String, num> bottomMetrics = getMetrics( symbol: bottom, font: font );
    num bottomHeightTotal = bottomMetrics[ 'height' ] + bottomMetrics[ 'depth' ];

    Map<String, num> middleMetrics;
    num middleHeightTotal;

    if ( middle != null ) {

        middleMetrics = getMetrics( symbol: middle, font: font );
        middleHeightTotal = middleMetrics[ 'height' ] + middleMetrics[ 'depth' ];

    }

    // Compute the real height that the delimiter will have. The real height
    // will be, at least, the size of the top, bottom, and optional middle parts
    // combined.
    num realHeightTotal = topHeightTotal + bottomHeightTotal;
    if ( middle != null ) {
        realHeightTotal += middleHeightTotal;
    }

    // Add repeated pieces until the specified height has been reached.
    while ( realHeightTotal < heightTotal ) {

        realHeightTotal += repeatHeightTotal;
        if (middle != null) {
            // If a middle part exists, we need an equal number of pieces
            // on the top and bottom.
            realHeightTotal += repeatHeightTotal;
        }

    }

    // The center of the delimiter is placed at the center of the axis. Note
    // that in this context, 'center' means that the delimiter should be
    // centered around the axis in the current style, while normally it is
    // centered around the axis in 'textstyle'.
    num axisHeight = fontMetrics.metrics[ 'axisHeight' ];

    if ( center ) {
        axisHeight *= options.style.sizeMultiplier;
    }

    // Calculate the height and depth.
    num height = realHeightTotal / 2 + axisHeight;
    num depth = realHeightTotal / 2 - axisHeight;

    // Start building the pieces that will go into the vertical list.

    // Create a [List] of the inner pieces.
    List<Map<String, dynamic>> inners = [];

    // Add the bottom symbol.
    inners.add( makeInner( symbol: bottom, font: font, mode: mode ) );

    if ( middle == null ) {

        // Calculate the number of repeated symbols we need
        num repeatHeight = realHeightTotal - topHeightTotal - bottomHeightTotal;
        num symbolCount = ( repeatHeight / repeatHeightTotal ).ceil();

        // Add that many symbols
        for ( num i = 0; i < symbolCount; i++ ) {
            inners.add( makeInner( symbol: repeat, font: font, mode: mode ) );
        }

    } else {
        // When a middle part exists, the middle part and the two repeated
        // sections are needed.

        // Compute the number of symbols needed for the top and bottom
        // repeated parts.
        num topRepeatHeight =
            realHeightTotal / 2 - topHeightTotal - middleHeightTotal / 2;

        num topSymbolCount = ( topRepeatHeight / repeatHeightTotal ).ceil();

        num bottomRepeatHeight =
            realHeightTotal / 2 - topHeightTotal - middleHeightTotal / 2;

        num bottomSymbolCount =
            ( bottomRepeatHeight / repeatHeightTotal ).ceil();

        // Add the top repeated part.
        for ( num i = 0; i < topSymbolCount; i++ ) {
            inners.add( makeInner( symbol: repeat, font: font, mode: mode ) );
        }

        // Add the middle part.
        inners.add( makeInner( symbol: middle, font: font, mode: mode ) );

        // Add the bottom repeated part.
        for ( num i = 0; i < bottomSymbolCount; i++ ) {
            inners.add( makeInner( symbol: repeat, font: font, mode: mode ) );
        }
    }

    // Add the top symbol.
    inners.add( makeInner( symbol: top, font: font, mode: mode) );

    // Create the vertical list [SpanNode].
    SpanNode inner = buildCommon.makeVerticalList( children: inners,
                                                   positionType: 'bottom',
                                                   positionData: depth,
                                                   options: options );

    return styleWrap(
        delim: buildCommon.makeSpan( classes: [ 'delimsizing', 'mult' ],
                                     children: [ inner ],
                                     color: options.getColor() ),
        toStyle: styles.TEXT,
        options: options );
}

// Three kinds of delimiters exist:
//  - Delimiters that stack when they become too large.
//  - Delimiters that always stack.
//  - Delimiters that never stack.

// Delimiters that stack when they become too large.
List<String> stackLargeDelimiters = [
    '(', ')',
    '[', '\\lbrack',
    ']', '\\rbrack',
    '\\{', '\\lbrace',
    '\\}', '\\rbrace',
    '\\lfloor', '\\rfloor',
    '\\lceil', '\\rceil',
    '\\surd'
];

// Delimiters that always stack.
List<String> stackAlwaysDelimiters = [
    '\\uparrow', '\\downarrow', '\\updownarrow',
    '\\Uparrow', '\\Downarrow', '\\Updownarrow',
    '|', '\\|',
    '\\vert', '\\Vert'
];

// Delimiters that never stack.
List<String> stackNeverDelimiters = [
    '<', '>',
    '\\langle', '\\rangle',
    '/', '\\backslash'
];

// Metrics of the different sizes. Found by looking at TeX's output of
// $\bigl| // \Bigl| \biggl| \Biggl| \showlists$
// Used to create stacked delimiters of appropriate sizes in makeSizedDelim.
List<num> sizeToMaxHeight = [ 0, 1.2, 1.8, 2.4, 3.0 ];

/**
 * Create a delimiter of a specific size - where `size` is 1, 2, 3, or 4.
 */
SpanNode makeSizedDelim ( { String delim, int size,
                            Options options, String mode } ) {

    // < and > turn into \langle and \rangle in delimiters.
    if (delim == '<') {
        delim = '\\langle';
    } else if (delim == '>') {
        delim = '\\rangle';
    }

    // Sized delimiters are never centered.
    if ( stackLargeDelimiters.contains( delim ) ||
         stackNeverDelimiters.contains( delim ) ) {

        return makeLargeDelim( delim: delim,
                               size: size,
                               center: false,
                               options: options,
                               mode: mode );

    } else if ( stackAlwaysDelimiters.contains( delim ) ) {

        return makeStackedDelim( delim: delim,
                                 heightTotal: sizeToMaxHeight[size],
                                 center: false,
                                 options: options,
                                 mode: mode );

    } else {

        throw new ParseError( message: 'Illegal delimiter: ' + delim );

    }

}

/**
 * There are three different sequences of delimiter sizes that the delimiters
 * follow depending on the kind of delimiter. This is used when creating custom
 * sized delimiters to decide whether to create a small, large, or stacked
 * delimiter.
 *
 * In TeX, these sequences are not explicitly defined, but are instead
 * defined inside the font metrics. Since there are only three sequences that
 * are possible for the delimiters that TeX defines, it is simpler to encode
 * them explicitly here.
 */

// Delimiters that never stack try small delimiters and large delimiters only
List<Map<String, dynamic>> stackNeverDelimiterSequence = [

    { 'type': 'small', 'style': styles.SCRIPTSCRIPT },
    { 'type': 'small', 'style': styles.SCRIPT },
    { 'type': 'small', 'style': styles.TEXT },
    { 'type': 'large', 'size': 1 },
    { 'type': 'large', 'size': 2 },
    { 'type': 'large', 'size': 3 },
    { 'type': 'large', 'size': 4 }

];

// Delimiters that always stack try the small delimiters first, then stack
List<Map<String, dynamic>> stackAlwaysDelimiterSequence = [

    { 'type': 'small', 'style': styles.SCRIPTSCRIPT },
    { 'type': 'small', 'style': styles.SCRIPT },
    { 'type': 'small', 'style': styles.TEXT },
    { 'type': 'stack' }

];

// Delimiters that stack when large try the small and then large delimiters, and
// stack afterwards
List<Map<String, dynamic>> stackLargeDelimiterSequence = [

    { 'type': 'small', 'style': styles.SCRIPTSCRIPT },
    { 'type': 'small', 'style': styles.SCRIPT },
    { 'type': 'small', 'style': styles.TEXT },
    { 'type': 'large', 'size': 1 },
    { 'type': 'large', 'size': 2 },
    { 'type': 'large', 'size': 3 },
    { 'type': 'large', 'size': 4 },
    { 'type': 'stack' }

];

/**
 * Get the font used in a delimiter based on what kind of delimiter it is.
 */
String delimTypeToFont ( { Map<String, dynamic> type } ) {

    String returnValue;

    if (type[ 'type' ] == 'small') {

        returnValue = 'Main-Regular';

    } else if (type[ 'type' ] == 'large') {

        returnValue = 'Size' + type[ 'size' ].toString() + '-Regular';

    } else if (type[ 'type' ] == 'stack') {

        returnValue = 'Size4-Regular';

    }

    return returnValue;

}

/**
 * Traverse a sequence of types of delimiters to decide what kind of delimiter
 * should be used to create a delimiter of the given height+depth.
 */
Map<String, dynamic> traverseSequence ( { String delim,
                                          num height,
                                          List<Map<String, dynamic>> sequence,
                                          Options options } ) {

    // Here, we choose the index we should start at in the sequences. In smaller
    // sizes (which correspond to larger numbers in style.size) we start earlier
    // in the sequence. Thus, scriptscript starts at index 3-3=0, script starts
    // at index 3-2=1, text starts at 3-1=2, and display starts at min(2,3-0)=2
    num start = Math.min( 2, ( 3 - options.style.size ) );

    for ( num i = start; i < sequence.length; i++ ) {

        if ( sequence[ i ][ 'type' ] == 'stack' ) {
            // This is always the last delimiter, so break the loop now.
            break;
        }

        Map<String, num> metrics =
            getMetrics( symbol: delim,
                        font: delimTypeToFont( type: sequence[ i ] ) );

        num heightDepth = metrics[ 'height' ] + metrics[ 'depth' ];

        // Small delimiters are scaled down versions of the same font, so an
        // accounting for the style change size must be made.

        if ( sequence[ i ][ 'type' ] == 'small' ) {
            heightDepth *= sequence[ i ][ 'style' ].sizeMultiplier;
        }

        // Check if the delimiter at this size works for the given height.
        if ( heightDepth > height ) {
            return sequence[i];
        }

    }

    // If the end of the sequence is reached, return the last sequence element.
    return sequence[ sequence.length - 1 ];

}

/**
 * Create a delimiter [SpanNode] of a given height plus its depth, with optional
 * centering. Traverse the sequences, and create a delimiter [SpanNode] that
 * the sequence describes.
 */
SpanNode makeCustomSizedDelim ( { String delim, num height, bool center,
                                  Options options, String mode } ) {

    if ( delim == '<' ) {

        delim = '\\langle';

    } else if ( delim == '>' ) {

        delim = '\\rangle';

    }

    var sequence;

    if ( stackNeverDelimiters.contains( delim ) ) {

        sequence = stackNeverDelimiterSequence;

    } else if ( stackLargeDelimiters.contains( delim ) ) {

        sequence = stackLargeDelimiterSequence;

    } else {

        sequence = stackAlwaysDelimiterSequence;

    }

    // Look through the sequence
    Map<String, dynamic> delimType = traverseSequence( delim: delim,
                                                       height: height,
                                                       sequence: sequence,
                                                       options: options );

    // Depending on the sequence element we decided on, call the appropriate
    // function.
    if (delimType[ 'type' ] == 'small') {

        return makeSmallDelim(
                            delim: delim,
                            style: delimType[ 'style' ],
                            center: center,
                            options: options,
                            mode: mode );

    } else if (delimType[ 'type' ] == 'large') {

        return makeLargeDelim(
                            delim: delim,
                            size: delimType[ 'size' ],
                            center: center,
                            options: options,
                            mode: mode );

    } else if (delimType[ 'type' ] == 'stack') {

        return makeStackedDelim(
                            delim: delim,
                            heightTotal: height,
                            center: center,
                            options: options,
                            mode: mode );

    }

}

/**
 * Create a delimiter [SpanNode] for use with `\left` and `\right`. The height
 * and depth of the expression that the delimiters surround is provided.
 */
SpanNode makeLeftRightDelim ( { String delim, num height, num depth,
                                Options options, String mode } ) {

    // The \left/\right delimiters are always centered, so the axis is always
    // shifted.
    num axisHeight =
        fontMetrics.metrics[ 'axisHeight' ] * options.style.sizeMultiplier;

    // Taken from TeX source, tex.web, function make_left_right
    num delimiterFactor = 901;
    num delimiterExtend = 5.0 / fontMetrics.metrics[ 'ptPerEm' ];

    var maxDistFromAxis = Math.max(
        height - axisHeight, depth + axisHeight);

    num totalHeight = Math.max(
        // In TeX, calculations are done using integral values which are
        // 65536 per pt, or 655360 per em. So, the division here truncates in
        // TeX but does not here, producing different results. If it is desired
        // to exactly match TeX's calculation, the following could be
        // implemented:
        //
        //   Math.floor(655360 * maxDistFromAxis / 500) *
        //    delimiterFactor / 655360
        //
        // (To see the difference, compare
        //    x^{x^{\left(\rule{0.1em}{0.68em}\right)}}
        // in TeX and katex.dart).
        maxDistFromAxis / 500 * delimiterFactor,
        2 * maxDistFromAxis - delimiterExtend );

    // Finally, defer to `makeCustomSizedDelim` with the calculated total
    // height.
    return makeCustomSizedDelim( delim: delim,
                                 height: totalHeight,
                                 center: true,
                                 options: options,
                                 mode: mode );

}