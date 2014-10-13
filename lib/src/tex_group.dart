// TODO(adamjcook): Add library description.
library katex.tex_group;

import 'dart:math' as Math;

import 'build_common.dart' as buildCommon;
import 'build_tree.dart';
import 'delimiters.dart' as delimiters;
import 'dom_node.dart';
import 'font_metrics.dart' as fontMetrics;
import 'functions.dart';
import 'options.dart';
import 'parse_node.dart';
import 'styles.dart' as styles;
import 'tex_function.dart';
import 'tex_style.dart';


// TODO(adamjcook): Add class description.
class TexGroup {

    String type;
    final ParseNode group;
    final Options options;
    final ParseNode prev;

    DomNode value;

    TexGroup( {
        String type,
        ParseNode group,
        Options options,
        ParseNode prev } )
    : this._init(
        type: type,
        group: group,
        options: options,
        prev: prev );

    TexGroup._init({
        this.type,
        this.group,
        this.options,
        this.prev } ) {

        /**
         * TeXbook algorithms often reference 'character boxes', which are simply groups
         * with a single character in them. To decide if something is a character box,
         * we find its innermost group, and see if it is a single character.
         */
        bool isCharacterBox ( { ParseNode group } ) {

            ParseNode baseElem = getBaseElem( group: group );

            if ( baseElem == null ) {
              return null;
            }

            // These are all they types of groups which hold single characters
            return baseElem.type == 'mathord' ||
                baseElem.type == 'textord' ||
                baseElem.type == 'bin' ||
                baseElem.type == 'rel' ||
                baseElem.type == 'inner' ||
                baseElem.type == 'open' ||
                baseElem.type == 'close' ||
                baseElem.type == 'punct';

        }


        /**
         * Sometimes, groups perform special rules when they have superscripts or
         * subscripts attached to them. This function lets the `supsub` group know that
         * its inner element should handle the superscripts and subscripts instead of
         * handling them itself.
         */
        bool shouldHandleSupSub ( { ParseNode group, Options options } ) {

            bool returnValue;

            if ( group == null ) {

                returnValue = false;

            } else if ( group.type == 'op' ) {

                // Operators handle supsubs differently when they have limits
                // (e.g. `\displaystyle\sum_2^3`)
                returnValue =
                    group.value.limits && options.style.size == styles.DISPLAY.size;

            } else if ( group.type == 'accent' ) {

                returnValue = isCharacterBox( group: group.value[ 'base' ] );

            } else {

                returnValue = null;

            }

            return returnValue;

        }


        if ( type == 'mathord' ) {

            value = buildCommon.makeSymbolItalic(
                                        value: group.value,
                                        mode: group.mode,
                                        color: options.getColor(),
                                        classes: [ 'mord' ] );

        } else if ( type == 'textord' ) {

            value = buildCommon.makeSymbolRoman(
                                    value: group.value,
                                    mode: group.mode,
                                    color: options.getColor(),
                                    classes: [ 'mord' ] );

        } else if ( type == 'bin' ) {

            String className = 'mbin';
            // Pull out the most recent element. Do some special handling to find
            // things at the end of a \color group. Note that we don't use the same
            // logic for ordgroups (which count as ords).
            ParseNode prevAtom = prev;
            while ( prevAtom != null && prevAtom.type == 'color' ) {

                List<ParseNode> atoms = prevAtom.value[ 'value' ];
                prevAtom = atoms[ atoms.length - 1 ];

            }

            // See TeXbook pg. 442-446, Rules 5 and 6, and the text before Rule 19.
            // Here, we determine whether the bin should turn into an ord. We
            // currently only apply Rule 5.
            if ( prev == null ||
                ['mbin', 'mopen', 'mrel', 'mop', 'mpunct']
                    .contains( getTypeOfGroup( group: prevAtom ) ) ) {

                group.type = 'textord';
                className = 'mord';

            }

            value = buildCommon.makeSymbolRoman(
                                        value: group.value,
                                        mode: group.mode,
                                        color: options.getColor(),
                                        classes: [ className ] );

        } else if ( type == 'rel' ) {

            value = buildCommon.makeSymbolRoman(
                                        value: group.value,
                                        mode: group.mode,
                                        color: options.getColor(),
                                        classes: [ 'mrel' ] );

        } else if ( type == 'open' ) {

            value = buildCommon.makeSymbolRoman(
                                        value: group.value,
                                        mode: group.mode,
                                        color: options.getColor(),
                                        classes: [ 'mopen' ] );

        } else if ( type == 'close' ) {

            value = buildCommon.makeSymbolRoman(
                                        value: group.value,
                                        mode: group.mode,
                                        color: options.getColor(),
                                        classes: [ 'mclose' ] );

        } else if ( type == 'inner' ) {

            value = buildCommon.makeSymbolRoman(
                                        value: group.value,
                                        mode: group.mode,
                                        color: options.getColor(),
                                        classes: [ 'minner' ] );

        } else if ( type == 'punct' ) {

            value = buildCommon.makeSymbolRoman(
                                        value: group.value,
                                        mode: group.mode,
                                        color: options.getColor(),
                                        classes: ['mpunct'] );

        } else if ( type == 'ordgroup' ) {

            value = buildCommon.makeSpan(
                    classes: [ 'mord',
                                options.style.HtmlClassName() ],
                    children: buildExpression(
                                    expression: group.value,
                                    options: options.reset() ) );

        } else if ( type == 'text' ) {

            value = buildCommon.makeSpan(
                    classes: [ 'text',
                               'mord',
                               options.style.HtmlClassName() ],
                    children: buildExpression(
                                    expression: group.value.body,
                                    options: options.reset() ) );

        } else if ( type == 'color' ) {

            List<DomNode> elements = buildExpression(
                                expression: group.value[ 'value' ],
                                options: options.withColor( group.value[ 'color' ] ),
                                prev: prev );

            // \color isn't supposed to affect the type of the elements it
            // contains. To accomplish this, we wrap the results in a fragment,
            // so the inner elements will be able to directly interact with
            // their neighbors.
            //
            // For example,
            // `\color{red}{2 +} 3` has the same spacing as `2 + 3`
            value = buildCommon.makeFragment( children: elements );

        } else if ( type == 'supsub' ) {

            // Superscript and subscripts are handled in the TeXbook on page
            // 445-446, rules 18(a-f).
            ParseNode baseGroup = group.value[ 'base' ];
            SpanNode submid;
            DomNode sub;
            SpanNode supmid;
            DomNode sup;
            TexFunction groupTypeFunc;

            // Here is where we defer to the inner group if it should handle
            // superscripts and subscripts itself.
            if ( shouldHandleSupSub( group: group.value[ 'base' ],
                                     options: options ) ) {

              type = group.value[ 'base' ].type;
//                groupTypeFunc = groupTypes[ group.value[ 'base' ].type ];
//                value = Function.apply( groupTypeFunc.handler, [ group, options, prev ] );

            }

            DomNode base = buildGroup( group: group.value[ 'base' ],
                                       options: options.reset() );

            if ( group.value[ 'sup' ] != null ) {

                sup = buildGroup(
                        group: group.value[ 'sup' ],
                        options: options.withStyle( options.style.sup() ) );

                supmid = buildCommon.makeSpan(
                            classes: [ options.style.ResetClassName(),
                                       options.style.sup().HtmlClassName() ],
                            children: [ sup ] );

            }

            if ( group.value[ 'sub' ] != null ) {

                sub = buildGroup(
                        group: group.value[ 'sub' ],
                        options: options.withStyle( options.style.sub() ) );

                submid = buildCommon.makeSpan(
                            classes: [ options.style.ResetClassName(),
                                       options.style.sub().HtmlClassName() ],
                            children: [ sub ] );

            }

            // Rule 18a
            num supShift;
            num subShift;

            if ( isCharacterBox( group: group.value[ 'base' ] ) != null ) {

                supShift = 0;
                subShift = 0;

            } else {

                supShift = base.height - fontMetrics.metrics[ 'supDrop' ];
                subShift = base.depth + fontMetrics.metrics[ 'subDrop' ];

            }

            // Rule 18c
            num minSupShift;

            if ( options.style == styles.DISPLAY ) {
                minSupShift = fontMetrics.metrics[ 'sup1' ];
            } else if ( options.style.isCramped ) {
                minSupShift = fontMetrics.metrics[ 'sup3' ];
            } else {
                minSupShift = fontMetrics.metrics[ 'sup2' ];
            }

            // scriptspace is a font-size-independent size, so scale it
            // appropriately
            num multiplier = styles.TEXT.sizeMultiplier *
                                                options.style.sizeMultiplier;

            String scriptspace =
                ( ( 0.5 / fontMetrics.metrics[ 'ptPerEm' ] ) / multiplier ).toString() + 'em';

            SpanNode supsub;

            if ( group.value[ 'sup' ] == null ) {

                // Rule 18b
                subShift = Math.max(
                    Math.max( subShift, fontMetrics.metrics[ 'sub1' ] ),
                    sub.height - 0.8 * fontMetrics.metrics[ 'xHeight' ] );

                supsub = buildCommon.makeVerticalList(
                            children: [ { 'type': 'elem', 'elem': submid } ],
                            positionType: 'shift',
                            positionData: subShift,
                            options: options );

                supsub.children[0].styles[ 'margin-right' ] =
                                                                    scriptspace;

                // Subscripts shouldn't be shifted by the base's italic correction.
                // Account for that by shifting the subscript back the appropriate
                // amount. Note we only do this when the base is a single symbol.
                if ( base is SymbolNode ) {

                    supsub.children[0].styles[ 'margin-left' ] =
                        ( -base.italic ).toString() + 'em';

                }

            } else if ( group.value[ 'sub' ] == null ) {

                // Rule 18c, d
                supShift = Math.max(
                    Math.max( supShift, minSupShift ),
                    sup.depth + 0.25 * fontMetrics.metrics[ 'xHeight' ] );

                supsub = buildCommon.makeVerticalList(
                            children: [ { 'type': 'elem', 'elem': supmid } ],
                            positionType: 'shift',
                            positionData: -supShift,
                            options: options );

                supsub.children[0].styles[ 'margin-right' ] = scriptspace;

            } else {

                supShift = Math.max(
                    Math.max( supShift, minSupShift ),
                    sup.depth + 0.25 * fontMetrics.metrics[ 'xHeight' ] );

                subShift = Math.max( subShift, fontMetrics.metrics[ 'sub2' ] );

                num ruleWidth = fontMetrics.metrics[ 'defaultRuleThickness' ];

                // Rule 18e
                if ( ( supShift - sup.depth ) - ( sub.height - subShift ) <
                        4 * ruleWidth ) {

                    subShift = 4 * ruleWidth - ( supShift - sup.depth ) + sub.height;
                    num psi = 0.8 * fontMetrics.metrics[ 'xHeight' ] -
                        ( supShift - sup.depth );

                    if ( psi > 0 ) {
                        supShift += psi;
                        subShift -= psi;
                    }

                }

                supsub = buildCommon.makeVerticalList(
                    children: [ { 'type': 'elem', 'elem': submid, 'shift': subShift },
                                { 'type': 'elem', 'elem': supmid, 'shift': -supShift } ],
                    positionType: 'individualShift',
                    positionData: null,
                    options: options );

                // See comment above about subscripts not being shifted
                if ( base is SymbolNode ) {

                    supsub.children[ 0 ]
                        .styles[ 'margin-left' ] = ( -base.italic ).toString() + 'em';

                }

                supsub.children[ 0 ].styles[ 'margin-right' ] = scriptspace;

                supsub.children[ 1 ].styles[ 'margin-right' ] = scriptspace;

            }

            value = buildCommon.makeSpan(
                        classes: [ getTypeOfGroup( group: group.value[ 'base' ] ) ],
                        children: [ base, supsub ] );

        } else if ( type == 'frac' ) {

            // Fractions are handled in the TeXbook on pages 444-445, rules 15(a-e).
            // Figure out what style this fraction should be in based on the
            // function used
            TexStyle fstyle = options.style;

            if ( group.value[ 'size' ] == 'dfrac' ) {

                fstyle = styles.DISPLAY;

            } else if ( group.value[ 'size' ] == 'tfrac' ) {

                fstyle = styles.TEXT;

            }

            TexStyle nstyle = fstyle.fracNum();
            TexStyle dstyle = fstyle.fracDen();

            DomNode numer = buildGroup( group: group.value[ 'numer' ],
                                        options: options.withStyle( nstyle ) );

            SpanNode numerreset = buildCommon.makeSpan(
                classes: [ fstyle.ResetClassName(), nstyle.HtmlClassName() ],
                children: [ numer ] );

            DomNode denom = buildGroup( group: group.value[ 'denom' ],
                                        options: options.withStyle( dstyle ) );

            SpanNode denomreset = buildCommon.makeSpan(
                classes: [ fstyle.ResetClassName(), dstyle.HtmlClassName() ],
                children: [ denom ] );

            num ruleWidth = fontMetrics.metrics[ 'defaultRuleThickness' ] /
                options.style.sizeMultiplier;

            SpanNode mid = buildCommon.makeSpan(
                                    classes: [ options.style.ResetClassName(),
                                    styles.TEXT.HtmlClassName(),
                                    'frac-line' ] );

            // Manually set the height of the line because its height is created in
            // CSS
            mid.height = ruleWidth;

            // Rule 15b, 15d
            num numShift;
            num denomShift;
            num clearance;

            if ( fstyle.size == styles.DISPLAY.size ) {

                numShift = fontMetrics.metrics[ 'num1' ];
                denomShift = fontMetrics.metrics[ 'denom1' ];
                clearance = 3 * ruleWidth;

            } else {

                numShift = fontMetrics.metrics[ 'num2' ];
                denomShift = fontMetrics.metrics[ 'denom2' ];
                clearance = ruleWidth;

            }

            num axisHeight = fontMetrics.metrics[ 'axisHeight' ];

            // Rule 15d
            if ( ( numShift - numer.depth ) - ( axisHeight + 0.5 * ruleWidth )
                    < clearance ) {

                numShift += clearance - ( ( numShift - numer.depth ) -
                                ( axisHeight + 0.5 * ruleWidth ) );

            }

            if ( ( axisHeight - 0.5 * ruleWidth ) - ( denom.height - denomShift )
                    < clearance ) {

                denomShift += clearance - ( ( axisHeight - 0.5 * ruleWidth ) -
                                ( denom.height - denomShift ) );

            }

            num midShift = -( axisHeight - 0.5 * ruleWidth );

            SpanNode frac = buildCommon.makeVerticalList(
                children: [ { 'type': 'elem', 'elem': denomreset, 'shift': denomShift },
                            { 'type': 'elem', 'elem': mid,        'shift': midShift },
                            { 'type': 'elem', 'elem': numerreset, 'shift': -numShift } ],
                positionType: 'individualShift',
                positionData: null,
                options: options );

            // Since we manually change the style sometimes (with \dfrac or \tfrac),
            // account for the possible size change here.
            frac.height *= fstyle.sizeMultiplier / options.style.sizeMultiplier;
            frac.depth *= fstyle.sizeMultiplier / options.style.sizeMultiplier;

            value = buildCommon.makeSpan(
                                classes: [ 'minner',
                                           'mfrac',
                                           options.style.ResetClassName(),
                                           fstyle.HtmlClassName() ],
                                children: [ frac ],
                                color: options.getColor() );

        } else if ( type == 'spacing' ) {

            if ( group.value == '\\ ' ||
                 group.value == '\\space' ||
                 group.value == ' ' ||
                 group.value == '~' ) {

                // Spaces are generated by adding an actual space. Each of these
                // things has an entry in the symbols table, so these will be turned
                // into appropriate outputs.
                value = buildCommon.makeSpan(
                            classes: [ 'mord', 'mspace' ],
                            children: [ buildCommon.makeSymbolRoman(
                                                            value: group.value,
                                                             mode: group.mode ) ] );

            } else {

                // Other kinds of spaces are of arbitrary width. We use CSS to
                // generate these.
                Map<String, String> spacingClassMap = {

                    '\\qquad': 'qquad',
                    '\\quad': 'quad',
                    '\\enspace': 'enspace',
                    '\\;': 'thickspace',
                    '\\:': 'mediumspace',
                    '\\,': 'thinspace',
                    '\\!': 'negativethinspace'

                };

                value = buildCommon.makeSpan(
                            classes: [ 'mord',
                                       'mspace',
                                       spacingClassMap[ group.value ] ] );

            }

        } else if ( type == 'llap' ) {

            SpanNode inner = buildCommon.makeSpan(
                                    classes: [ 'inner' ],
                                    children: [ buildGroup(
                                                    group: group.value.body,
                                                    options: options.reset() ) ] );

            SpanNode fix = buildCommon.makeSpan(
                                            classes: [ 'fix' ],
                                            children: [] );

            value = buildCommon.makeSpan(
                                    classes: [ 'llap',
                                               options.style.HtmlClassName() ],
                                    children: [ inner, fix ] );

        } else if ( type == 'rlap' ) {

            SpanNode inner = buildCommon.makeSpan(
                                classes: [ 'inner' ],
                                children: [ buildGroup(
                                                group: group.value.body,
                                                options: options.reset() ) ] );

            SpanNode fix = buildCommon.makeSpan(
                                            classes: [ 'fix' ],
                                            children: [] );

            value = buildCommon.makeSpan(
                            classes: [ 'rlap',
                                        options.style.HtmlClassName() ],
                            children: [ inner, fix ] );

        } else if ( type == 'op' ) {

            // Operators are handled in the TeXbook pg. 443-444, rule 13(a).
            ParseNode supGroup;
            ParseNode subGroup;
            bool hasLimits = false;

            if ( group.type == 'supsub' ) {

                // If we have limits, supsub will pass us its group to handle.
                // Pull out the superscript and subscript and set the group to
                // the op in its base.
                supGroup = group.value[ 'sup' ];
                subGroup = group.value[ 'sub' ];
                group = group.value[ 'base' ];
                hasLimits = true;

            }

            // Most operators have a large successor symbol, but these don't.
            List<String> noSuccessor = [ '\\smallint' ];

            bool large = false;

            if ( options.style.size == styles.DISPLAY.size &&
                 group.value.symbol &&
                 !noSuccessor.contains( group.value.body ) ) {

                // Most symbol operators get larger in displaystyle (rule 13)
                large = true;

            }

            DomNode base;
            num baseShift = 0;
            num slant = 0;

            if ( group.value[ 'symbol' ] ) {

                // If this is a symbol, create the symbol.
                String style = large ? 'Size2-Regular' : 'Size1-Regular';
                base = buildCommon.makeSymbol(
                    value: group.value[ 'body' ],
                    style: style,
                    mode: 'math',
                    color: options.getColor(),
                    classes: [ 'op-symbol', large ? 'large-op' : 'small-op', 'mop' ] );

                // Shift the symbol so its center lies on the axis (rule 13). It
                // appears that our fonts have the centers of the symbols already
                // almost on the axis, so these numbers are very small. Note we
                // don't actually apply this here, but instead it is used either in
                // the vlist creation or separately when there are no limits.
                baseShift = ( base.height - base.depth ) / 2 -
                    fontMetrics.metrics[ 'axisHeight' ] *
                    options.style.sizeMultiplier;

                // The slant of the symbol is just its italic correction.
                slant = base.italic;

            } else {

                // Otherwise, this is a text operator. Build the text from the
                // operator's name.
                // TODO(adamjcook): Add a space in the middle of some of these
                // operators, like \limsup
                List<SymbolNode> output = [];
                for ( num i = 1; i < group.value[ 'body' ].value.length; i++ ) {

                    output.add( buildCommon.makeSymbolRoman(
                                        value: group.value[ 'body' ].value[ i ],
                                        mode: group.mode ) );

                }

                base = buildCommon.makeSpan( classes: [ 'mop' ],
                                             children: output,
                                             color: options.getColor() );

            }

            if ( hasLimits ) {

                // IE 8 clips \int if it is in a display: inline-block. We wrap it
                // in a new span so it is an inline, and works.
                base = buildCommon.makeSpan( classes: [],
                                             children: [ base ] );

                SpanNode supmid;
                num supKern;
                SpanNode submid;
                num subKern;

                // We manually have to handle the superscripts and subscripts. This,
                // aside from the kern calculations, is copied from supsub.
                if ( supGroup ) {

                    DomNode sup = buildGroup(
                        group: supGroup,
                        options: options.withStyle( options.style.sup() ) );

                    supmid = buildCommon.makeSpan(
                        classes: [ options.style.ResetClassName(),
                                   options.style.sup().HtmlClassName() ],
                        children: [ sup ] );

                    supKern = Math.max(
                        fontMetrics.metrics[ 'bigOpSpacing1' ],
                        fontMetrics.metrics[ 'bigOpSpacing3' ] - sup.depth );

                }

                if ( subGroup ) {

                    DomNode sub = buildGroup(
                        group: subGroup,
                        options: options.withStyle( options.style.sub() ) );

                    submid = buildCommon.makeSpan(
                                classes: [ options.style.ResetClassName(),
                                           options.style.sub().HtmlClassName() ],
                                children: [ sub ] );

                    subKern = Math.max(
                        fontMetrics.metrics[ 'bigOpSpacing2' ],
                        fontMetrics.metrics[ 'bigOpSpacing4' ] - sub.height );

                }

                // Build the final group as a vlist of the possible subscript, base,
                // and possible superscript.
                SpanNode finalGroup;

                if ( !supGroup ) {

                    num top = base.height - baseShift;

                    finalGroup = buildCommon.makeVerticalList(
                        children: [ { 'type': 'kern',
                                      'size': fontMetrics.metrics[ 'bigOpSpacing5' ] },
                                    { 'type': 'elem', 'elem': submid },
                                    { 'type': 'kern', 'size': subKern },
                                    { 'type': 'elem', 'elem': base } ],
                        positionType: 'top',
                        positionData: top,
                        options: options );

                    // Here, we shift the limits by the slant of the symbol. Note
                    // that we are supposed to shift the limits by 1/2 of the slant,
                    // but since we are centering the limits adding a full slant of
                    // margin will shift by 1/2 that.
                    finalGroup.children[0].styles[ 'marginLeft' ] =
                        ( -slant ).toString() + 'em';


                } else if ( !subGroup ) {

                    num bottom = base.depth + baseShift;

                    finalGroup = buildCommon.makeVerticalList(
                        children: [ { 'type': 'elem', 'elem': base },
                                    { 'type': 'kern', 'size': supKern },
                                    { 'type': 'elem', 'elem': supmid },
                                    { 'type': 'kern',
                                       'size': fontMetrics.metrics[ 'bigOpSpacing5' ] } ],
                        positionType: 'bottom',
                        positionData: bottom,
                        options: options );

                    // See comment above about slants
                    finalGroup.children[1]
                        .styles[ 'marginLeft' ] = slant.toString() + 'em';

                } else if ( !supGroup && !subGroup ) {

                    // This case probably shouldn't occur (this would mean the
                    // supsub was sending us a group with no superscript or
                    // subscript) but be safe.
                    value = base;

                } else {

                    num bottom = fontMetrics.metrics[ 'bigOpSpacing5' ] +
                        submid.height + submid.depth +
                        subKern +
                        base.depth + baseShift;

                    finalGroup = buildCommon.makeVerticalList(
                        children:
                        [ { 'type': 'kern',
                            'size': fontMetrics.metrics[ 'bigOpSpacing5' ] },
                          { 'type': 'elem', 'elem': submid },
                          { 'type': 'kern', 'size': subKern },
                          { 'type': 'elem', 'elem': base },
                          { 'type': 'kern', 'size': supKern },
                          { 'type': 'elem', 'elem': supmid },
                          { 'type': 'kern',
                            'size': fontMetrics.metrics[ 'bigOpSpacing5' ] } ],
                        positionType: 'bottom',
                        positionData: bottom,
                        options: options );

                    // See comment above about slants
                    finalGroup.children[0]
                        .styles[ 'marginLeft' ] = ( -slant ).toString() + 'em';

                    finalGroup.children[2]
                        .styles[ 'marginLeft' ] = slant.toString() + 'em';

                }

                value = buildCommon.makeSpan(
                                        classes: [ 'mop', 'op-limits' ],
                                        children: [ finalGroup ] );

            } else {

                if ( group.value[ 'symbol' ] ) {

                    base.styles[ 'top' ] =
                        baseShift.toString() + 'em';

                }

                value = base;
            }

        } else if ( type == 'katex' ) {

            // The KaTeX logo. The offsets for the K and a were chosen to look
            // good, but the offsets for the T, E, and X were taken from the
            // definition of \TeX in TeX (see TeXbook pg. 356)
            SpanNode k = buildCommon.makeSpan(
                classes: [ 'k' ],
                children: [ buildCommon.makeSymbolRoman(
                                                    value: 'K',
                                                    mode: group.mode ) ] );

            SpanNode a = buildCommon.makeSpan(
                classes: [ 'a' ],
                children: [ buildCommon.makeSymbolRoman(
                                                    value: 'A',
                                                    mode: group.mode ) ] );

            a.height = ( a.height + 0.2 ) * 0.75;
            a.depth = ( a.height - 0.2 ) * 0.75;

            SpanNode t = buildCommon.makeSpan(
                classes: [ 't' ],
                children: [ buildCommon.makeSymbolRoman(
                                                    value: 'T',
                                                    mode: group.mode ) ] );

            SpanNode e = buildCommon.makeSpan(
                classes: [ 'e' ],
                children: [ buildCommon.makeSymbolRoman(
                                                    value: 'E',
                                                    mode: group.mode ) ] );


            e.height = ( e.height - 0.2155 );
            e.depth = ( e.depth + 0.2155 );

            SpanNode x = buildCommon.makeSpan(
                classes: [ 'x' ],
                children: [ buildCommon.makeSymbolRoman(
                                                    value: 'X',
                                                    mode: group.mode ) ] );

            value = buildCommon.makeSpan(
                                    classes: ['katex-logo'],
                                    children: [ k, a, t, e, x ],
                                    color: options.getColor() );

        } else if ( type == 'overline' ) {

            // Overlines are handled in the TeXbook pg 443, Rule 9.

            // Build the inner group in the cramped style.
            DomNode innerGroup = buildGroup(
                                    group: group.value.body,
                                    options: options.withStyle(
                                                        options.style.cramp() ) );

            num ruleWidth =
                fontMetrics.metrics[ 'defaultRuleThickness' ] /
                options.style.sizeMultiplier;

            // Create the line above the body
            SpanNode line = buildCommon.makeSpan(
                                    classes: [ options.style.ResetClassName(),
                                               styles.TEXT.HtmlClassName(),
                                               'overline-line' ] );

            line.height = ruleWidth;
            line.maxFontSize = 1.0;

            // Generate the vlist, with the appropriate kerns
            SpanNode verticalList = buildCommon.makeVerticalList(
                children: [ { 'type': 'elem', 'elem': innerGroup },
                            { 'type': 'kern', 'size': 3 * ruleWidth },
                            { 'type': 'elem', 'elem': line },
                            { 'type': 'kern', 'size': ruleWidth } ],
                positionType: 'firstBaseline',
                positionData: null,
                options: options );

            value = buildCommon.makeSpan(
                                    classes: [ 'overline', 'mord' ],
                                    children: [ verticalList ],
                                    color: options.getColor() );

        } else if ( type == 'sqrt' ) {

            // Square roots are handled in the TeXbook pg. 443, Rule 11.

            // First, we do the same steps as in overline to build the inner group
            // and line
            DomNode inner = buildGroup(
                                group: group.value.body,
                                options: options.withStyle(
                                                    options.style.cramp() ) );

            num ruleWidth = fontMetrics.metrics[ 'defaultRuleThickness' ] /
                options.style.sizeMultiplier;

            SpanNode line = buildCommon.makeSpan(
                classes: [ options.style.ResetClassName(),
                           styles.TEXT.HtmlClassName(),
                           'sqrt-line' ],
                children: [],
                color: options.getColor() );

            line.height = ruleWidth;
            line.maxFontSize = 1.0;

            num phi = ruleWidth;

            if ( options.style.id < styles.TEXT.id ) {
                phi = fontMetrics.metrics[ 'xHeight' ];
            }

            // Calculate the clearance between the body and line
            num lineClearance = ruleWidth + phi / 4;

            num innerHeight =
                ( inner.height + inner.depth ) * options.style.sizeMultiplier;

            num minDelimiterHeight = innerHeight + lineClearance + ruleWidth;

            // Create a \surd delimiter of the required minimum size
            SpanNode delim = buildCommon.makeSpan(
                classes: ['sqrt-sign'],
                children: [ delimiters.makeCustomSizedDelim(
                                                    delim: '\\surd',
                                                    height: minDelimiterHeight,
                                                    center: false,
                                                    options: options,
                                                    mode: group.mode ) ],
                color: options.getColor() );

            num delimDepth = ( delim.height + delim.depth ) - ruleWidth;

            // Adjust the clearance based on the delimiter size
            if ( delimDepth > ( inner.height + inner.depth + lineClearance ) ) {
                lineClearance =
                    ( lineClearance + delimDepth - inner.height - inner.depth ) / 2;
            }

            // Shift the delimiter so that its top lines up with the top of the line
            num delimShift = -( inner.height + lineClearance + ruleWidth ) +
                delim.height;

            delim.styles[ 'top' ] = delimShift.toString() + 'em';
            delim.height -= delimShift;
            delim.depth += delimShift;

            // We add a special case here, because even when `inner` is empty, we
            // still get a line. So, we use a simple heuristic to decide if we
            // should omit the body entirely. (note this doesn't work for something
            // like `\sqrt{\rlap{x}}`, but if someone is doing that they deserve for
            // it not to work.
            SpanNode body;

            if ( inner.height == 0 && inner.depth == 0 ) {

                body = buildCommon.makeSpan();

            } else {

                body = buildCommon.makeVerticalList(
                    children: [ { 'type': 'elem', 'elem': inner },
                                { 'type': 'kern', 'size': lineClearance },
                                { 'type': 'elem', 'elem': line },
                                { 'type': 'kern', 'size': ruleWidth } ],
                    positionType: 'firstBaseline',
                    positionData: null,
                    options: options );

            }

            value = buildCommon.makeSpan( classes: [ 'sqrt', 'mord' ],
                                         children: [ delim, body ] );

        } else if ( type == 'sizing' ) {

            // Handle sizing operators like \Huge. Real TeX doesn't actually allow
            // these functions inside of math expressions, so we do some special
            // handling.
            List<DomNode> inner = buildExpression(
                                        expression: group.value.value,
                                        options: options.withSize(
                                                            group.value.size),
                                        prev: prev );

            SpanNode span = buildCommon.makeSpan(
                                        classes: [ 'mord' ],
                                        children: [ buildCommon.makeSpan(
                                        classes: [ 'sizing',
                                                   'reset-' + options.size,
                                                    group.value.size,
                                                   options.style.HtmlClassName() ],
                                        children: inner ) ] );

            // Calculate the correct maxFontSize manually
            num fontSize = sizingMultiplier[ group.value.size ];
            span.maxFontSize = fontSize * options.style.sizeMultiplier;

            value = span;

        } else if ( type == 'styling' ) {

            // Style changes are handled in the TeXbook on pg. 442, Rule 3.

            // Figure out what style we're changing to.
            Map<String, TexStyle> style = {
                'display': styles.DISPLAY,
                'text': styles.TEXT,
                'script': styles.SCRIPT,
                'scriptscript': styles.SCRIPTSCRIPT
            };

            var newStyle = style[ group.value.style ];

            // Build the inner expression in the new style.
            List<DomNode> inner = buildExpression(
                                    expression: group.value.value,
                                    options: options.withStyle( newStyle ),
                                    prev: prev );

            value = buildCommon.makeSpan(
                                classes: [ options.style.ResetClassName(),
                                           newStyle.HtmlClassName() ],
                                children: inner );

        } else if ( type == 'delimsizing' ) {

            var delim = group.value.value;

            if ( delim == '.' ) {
                // Empty delimiters still count as elements, even though they don't
                // show anything.
                value = buildCommon.makeSpan(
                            classes: [ groupToType[ group.value.delimType ] ] );
            } else {
                            // Use delimiter.sizedDelim to generate the delimiter.
                value = buildCommon.makeSpan(
                            classes: [ groupToType[ group.value.delimType ] ],
                            children: [ delimiters.makeSizedDelim(
                                                    delim: delim,
                                                    size: group.value.size,
                                                    options: options,
                                                    mode: group.mode ) ] );
            }

        } else if ( type == 'leftright' ) {

            // Build the inner expression
            List<DomNode> inner = buildExpression(
                                            expression: group.value[ 'body' ],
                                            options: options.reset() );

            num innerHeight = 0;
            num innerDepth = 0;

            // Calculate its height and depth
            for (var i = 0; i < inner.length; i++) {
                innerHeight = Math.max( inner[ i ].height, innerHeight );
                innerDepth = Math.max( inner[ i ].depth, innerDepth );
            }

            // The size of delimiters is the same, regardless of what style we are
            // in. Thus, to correctly calculate the size of delimiter we need around
            // a group, we scale down the inner size based on the size.
            innerHeight *= options.style.sizeMultiplier;
            innerDepth *= options.style.sizeMultiplier;

            SpanNode leftDelim;

            if ( group.value[ 'left' ][ 'value' ] == '.' ) {

                // Empty delimiters in \left and \right make null delimiter spaces.
                leftDelim = buildCommon.makeSpan(
                                            classes: [ 'nulldelimiter' ] );

            } else {

                // Otherwise, use leftRightDelim to generate the correct sized
                // delimiter.
                leftDelim = delimiters.makeLeftRightDelim(
                                        delim: group.value[ 'left' ][ 'value'],
                                        height: innerHeight,
                                        depth: innerDepth,
                                        options: options,
                                        mode: group.mode );

            }

            // Add it to the beginning of the expression
            inner.insert( 0, leftDelim );

            SpanNode rightDelim;
            // Same for the right delimiter
            if ( group.value[ 'right' ][ 'value' ] == '.' ) {

                rightDelim = buildCommon.makeSpan(
                                            classes: [ 'nulldelimiter' ] );

            } else {

                rightDelim = delimiters.makeLeftRightDelim(
                                        delim: group.value[ 'right' ][ 'value' ],
                                        height: innerHeight,
                                        depth: innerDepth,
                                        options: options,
                                        mode: group.mode );

            }

            // Add it to the end of the expression.
            inner.add( rightDelim );

            value = buildCommon.makeSpan(
                                    classes: [ 'minner',
                                               options.style.HtmlClassName() ],
                                    children: inner,
                                    color: options.getColor() );

        } else if ( type == 'rule' ) {

            // Make an empty span for the rule
            SpanNode rule = buildCommon.makeSpan(
                                            classes: [ 'mord', 'rule' ],
                                            children: [],
                                            color: options.getColor() );

            // Calculate the shift, width and height of the rule, and account
            // for units.
            num shift = 0;
            if ( group.value.shift != null ) {

              shift = group.value.shift.number;
              if ( group.value.shift.unit == 'ex' ) {
                shift *= fontMetrics.metrics[ 'xHeight' ];
              }

            }

            num width = group.value.width.number;
            if ( group.value.width.unit == 'ex' ) {

                width *= fontMetrics.metrics[ 'xHeight' ];

            }

            num height = group.value.height.number;
            if ( group.value.height.unit == 'ex' ) {

                height *= fontMetrics.metrics[ 'xHeight' ];

            }

            // The sizes of rules are absolute, so make it larger if we are in a
            // smaller style.
            shift /= options.style.sizeMultiplier;
            width /= options.style.sizeMultiplier;
            height /= options.style.sizeMultiplier;

            // Style the rule to the right size
            rule.styles[ 'borderRightWidth' ] = width.toString() + 'em';
            rule.styles[ 'borderTopWidth' ] = height.toString() + 'em';
            rule.styles[ 'bottom' ] = shift.toString() + 'em';

            // Record the height and width.
            rule.width = width;
            rule.height = height + shift;
            rule.depth = -shift;

            value = rule;

        } else if ( type == 'accent' ) {

            // Accents are handled in the TeXbook pg. 443, rule 12.
            ParseNode base = group.value[ 'base' ];

            DomNode supsubGroup;

            if ( group.type == 'supsub' ) {

                // If our base is a character box, and we have superscripts and
                // subscripts, the supsub will defer to us. In particular, we want
                // to attach the superscripts and subscripts to the inner body (so
                // that the position of the superscripts and subscripts won't be
                // affected by the height of the accent). We accomplish this by
                // sticking the base of the accent into the base of the supsub, and
                // rendering that, while keeping track of where the accent is.

                // The supsub group is the group that was passed in
                ParseNode supsub = group;
                // The real accent group is the base of the supsub group
                group = supsub.value[ 'base' ];
                // The character box is the base of the accent group
                base = group.value[ 'base' ];
                // Stick the character box into the base of the supsub group
                supsub.value[ 'base' ] = base;

                // Rerender the supsub group with its new base, and store that
                // result.
                supsubGroup = buildGroup( group: supsub,
                                          options: options.reset(),
                                          prev: prev);

            }

            // Build the base group
            DomNode body = buildGroup( group: base,
                                       options: options.withStyle( options.style.cramp() ) );

            // Calculate the skew of the accent. This is based on the line 'If the
            // nucleus is not a single character, let s = 0; otherwise set s to the
            // kern amount for the nucleus followed by the \skewchar of its font.'
            // Note that our skew metrics are just the kern between each character
            // and the skewchar.
            num skew;

            if ( isCharacterBox( group: base ) ) {

                // If the base is a character box, then we want the skew of the
                // innermost character. To do that, we find the innermost character:
                var baseChar = getBaseElem( group: base );
                // Then, we render its group to get the symbol inside it
                DomNode baseGroup = buildGroup( group: baseChar,
                                                options: options.withStyle( options.style.cramp() ) );
                // Finally, we pull the skew off of the symbol.
                skew = baseGroup.skew;
                // Note that we now throw away baseGroup, because the layers we
                // removed with getBaseElem might contain things like \color which
                // we can't get rid of.
                // TODO(adamjcook): Find a better way to get the skew

            } else {

                skew = 0;

            }

            // calculate the amount of space between the body and the accent
            num clearance = Math.min( body.height, fontMetrics.metrics[ 'xHeight' ] );

            // Build the accent
            SymbolNode accent = buildCommon.makeSymbol(
                value: group.value[ 'accent' ],
                style: 'Main-Regular',
                mode: 'math',
                color: options.getColor() );

            // Remove the italic correction of the accent, because it only serves to
            // shift the accent over to a place we don't want.
            accent.italic = 0;

            // The \vec character that the fonts use is a combining character, and
            // thus shows up much too far to the left. To account for this, we add a
            // specific class which shifts the accent over to where we want it.
            // TODO(adamjcook): Fix this in a better way, like by changing the font
            String vecClass = group.value[ 'accent' ] == '\\vec' ? 'accent-vec' : null;

            SpanNode accBody =
                buildCommon.makeSpan(
                    classes: [ 'accent-body', vecClass ],
                    children: [ buildCommon.makeSpan( classes: [],
                                                      children: [ accent ] ) ] );

            SpanNode accentBody = buildCommon.makeVerticalList(
                children: [ { 'type': 'elem', 'elem': body },
                            { 'type': 'kern', 'size': -clearance },
                            { 'type': 'elem', 'elem': accBody } ],
                positionType: 'firstBaseline',
                positionData: null,
                options: options );

            // Shift the accent over by the skew. Note we shift by twice the skew
            // because we are centering the accent, so by adding 2*skew to the left,
            // we shift it to the right by 1*skew.
            accentBody.children[1].styles[ 'marginLeft' ] =
                ( 2 * skew ).toString() + 'em';

            SpanNode accentWrap =
                buildCommon.makeSpan( classes: [ 'mord', 'accent' ],
                                      children: [ accentBody ] );

            if ( supsubGroup != null ) {

                // Here, we replace the 'base' child of the supsub with our newly
                // generated accent.
                supsubGroup.children[ 0 ] = accentWrap;

                // Since we don't rerun the height calculation after replacing the
                // accent, we manually recalculate height.
                supsubGroup.height = Math.max(accentWrap.height, supsubGroup.height);

                // Accents should always be ords, even when their innards are not.
                supsubGroup.classes[ 0 ] = 'mord';

                value = supsubGroup;

            } else {

                value = accentWrap;

            }

        }

    }

}