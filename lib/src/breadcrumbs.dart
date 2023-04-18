import 'package:flutter/material.dart';

typedef BreadcrumbBuilder = TextSpan Function(BuildContext context, int index);

class Breadcrumbs extends StatefulWidget {
  final List<TextSpan>? crumbs;
  final int itemCount;
  final BreadcrumbBuilder? itemBuilder;
  final BreadcrumbBuilder? separatorBuilder;
  final String separator;
  final String hiddenElementsReplacement;
  final TextStyle? style;
  final TextAlign textAlign;

  /// Control the expansion behavior of the breadcrumbs. If set to `true`, the
  /// breadcrumbs will expand when tapped. If set to `false`, the breadcrumbs
  /// will not expand when tapped.
  final bool toggleExpansionOnTap;

  /// Force the expansion state of the breadcrumbs.
  final bool? expanded;

  const factory Breadcrumbs({
    Key? key,
    required List<TextSpan> crumbs,
    String? separator,
    String? hiddenElementsReplacement,
    TextStyle? style,
    TextAlign? textAlign,
    bool? toggleExpansionOnTap,
    bool? expanded,
  }) = Breadcrumbs._;

  const factory Breadcrumbs.builder({
    Key? key,
    required int itemCount,
    required BreadcrumbBuilder itemBuilder,
    BreadcrumbBuilder? separatorBuilder,
    String? hiddenElementsReplacement,
    TextStyle? style,
    TextAlign? textAlign,
    bool? toggleExpansionOnTap,
    bool? expanded,
  }) = Breadcrumbs._;

  const Breadcrumbs._({
    Key? key,
    this.crumbs,
    this.itemBuilder,
    int? itemCount,
    this.separatorBuilder,
    String? hiddenElementsReplacement,
    String? separator,
    this.style,
    TextAlign? textAlign,
    bool? toggleExpansionOnTap,
    this.expanded,
  })  : itemCount = itemCount ?? crumbs?.length ?? 0,
        hiddenElementsReplacement = hiddenElementsReplacement ?? '...',
        separator = separator ?? ' / ',
        textAlign = textAlign ?? TextAlign.left,
        toggleExpansionOnTap = toggleExpansionOnTap ?? true,
        super(key: key);

  @override
  _BreadcrumbsState createState() => _BreadcrumbsState();
}

class _BreadcrumbsState extends State<Breadcrumbs> {
  late bool isExpanded = widget.expanded ?? false;
  bool didExceed = false;

  VoidCallback? toggleExpansionState() {
    if (!widget.toggleExpansionOnTap || widget.expanded != null || !didExceed) {
      return null;
    }

    return () {
      setState(() {
        isExpanded = !isExpanded;
      });
    };
  }

  TextSpan _separator(BuildContext context, int index) {
    return widget.separatorBuilder?.call(context, index) ??
        TextSpan(text: widget.separator);
  }

  TextSpan buildTextSpan(
    BuildContext context, [
    List<int> removedElementIndices = const [],
  ]) {
    final children = <TextSpan>[];

    bool hiddenElementsReplacementInserted = false;
    for (var index = 0; index < widget.itemCount; index++) {
      if (removedElementIndices.contains(index)) {
        if (!hiddenElementsReplacementInserted) {
          children.add(TextSpan(
            text: widget.hiddenElementsReplacement,
          ));
          children.add(_separator(context, index));
          hiddenElementsReplacementInserted = true;
        }
        continue;
      }

      final crumb =
          widget.itemBuilder?.call(context, index) ?? widget.crumbs![index];

      children.add(crumb);

      if (index == widget.itemCount - 1) {
        continue;
      }

      children.add(_separator(context, index));
    }

    return TextSpan(
      children: children,
      style: widget.style,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isExpanded) {
      return GestureDetector(
        onTap: toggleExpansionState(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: RichText(text: buildTextSpan(context)),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final removedIndices = <int>[];

        var exceeds = true;
        var textSpan = const TextSpan(text: '');
        int passes = 0;

        while (exceeds && passes < widget.itemCount) {
          textSpan = buildTextSpan(context, removedIndices);

          final textPainter = TextPainter(
            maxLines: 1,
            textAlign: widget.textAlign,
            textDirection: Directionality.of(context),
            text: textSpan,
          );
          textPainter.layout(maxWidth: constraints.maxWidth);

          // Wether the text overflowed or not
          exceeds = textPainter.didExceedMaxLines;

          if (exceeds) {
            didExceed = true;

            final indices = List.generate(widget.itemCount, (index) => index);
            indices.removeWhere((element) => removedIndices.contains(element));

            var toRemove = indices[(indices.length / 2).floor()];

            if (toRemove == indices.last) {
              toRemove -= 1;
            }

            removedIndices.add(toRemove);
          }

          passes++;
        }

        if (passes == widget.itemCount && !exceeds) {
          // can't collapse
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            setState(() {
              isExpanded = true;
            });
          });
        }

        return GestureDetector(
          onTap: toggleExpansionState(),
          child: RichText(
            text: textSpan,
            maxLines: 1,
            textAlign: widget.textAlign,
          ),
        );
      },
    );
  }
}
