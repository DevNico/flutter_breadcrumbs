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

  factory Breadcrumbs({
    Key? key,
    required List<TextSpan> crumbs,
    String? separator,
    String? hiddenElementsReplacement,
    TextStyle? style,
    TextAlign? textAlign,
  }) =>
      Breadcrumbs._(
        key: key,
        crumbs: crumbs,
        separator: separator,
        hiddenElementsReplacement: hiddenElementsReplacement,
        style: style,
        textAlign: textAlign,
      );

  factory Breadcrumbs.builder({
    Key? key,
    required int itemCount,
    required BreadcrumbBuilder itemBuilder,
    BreadcrumbBuilder? separatorBuilder,
    String? hiddenElementsReplacement,
    TextStyle? style,
    TextAlign? textAlign,
  }) =>
      Breadcrumbs._(
        key: key,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        separatorBuilder: separatorBuilder,
        hiddenElementsReplacement: hiddenElementsReplacement,
        style: style,
        textAlign: textAlign,
      );

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
  })  : itemCount = itemCount ?? crumbs?.length ?? 0,
        hiddenElementsReplacement = hiddenElementsReplacement ?? '...',
        separator = separator ?? ' / ',
        textAlign = textAlign ?? TextAlign.left,
        super(key: key);

  @override
  _BreadcrumbsState createState() => _BreadcrumbsState();
}

class _BreadcrumbsState extends State<Breadcrumbs> {
  bool isExpanded = false;
  bool canToggle = true;

  void toggleExpansionState() {
    if (!canToggle) return;
    setState(() {
      isExpanded = !isExpanded;
    });
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
        onTap: toggleExpansionState,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: RichText(text: buildTextSpan(context)),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final removedIndices = <int>[];

        var didExceed = false;
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

          if (exceeds && !isExpanded) {
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

        if (passes == widget.itemCount) {
          // can't collapse
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            setState(() {
              canToggle = false;
              isExpanded = true;
            });
          });
        }

        return GestureDetector(
          onTap: didExceed ? toggleExpansionState : null,
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
