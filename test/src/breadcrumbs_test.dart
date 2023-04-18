import 'package:breadcrumbs/src/breadcrumbs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void expectBreadcrumb(WidgetTester tester, String text) {
    final textFinder = find.byType(RichText);
    expect(
      (textFinder.evaluate().single.widget as RichText).text.toPlainText(),
      text,
    );
  }

  testWidgets('should collapse', (widgetTester) async {
    final crumbs = [
      'Home',
      'Library',
      'Documents',
      'Pictures',
      'Videos',
    ];
    await widgetTester.binding.setSurfaceSize(const Size(150, 50));

    await widgetTester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Breadcrumbs(
          crumbs: crumbs.map((e) => TextSpan(text: e)).toList(),
        ),
      ),
    );

    final breadcrumbsFinder = find.byType(Breadcrumbs);
    expect(breadcrumbsFinder, findsOneWidget);

    expectBreadcrumb(widgetTester, 'Home / ... / Videos');
  });

  testWidgets('should expand on tap', (widgetTester) async {
    final crumbs = [
      'Home',
      'Library',
      'Documents',
      'Pictures',
      'Videos',
    ];
    await widgetTester.binding.setSurfaceSize(const Size(150, 50));

    await widgetTester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Breadcrumbs(
          crumbs: crumbs.map((e) => TextSpan(text: e)).toList(),
        ),
      ),
    );

    final breadcrumbsFinder = find.byType(Breadcrumbs);
    expect(breadcrumbsFinder, findsOneWidget);
    expectBreadcrumb(widgetTester, 'Home / ... / Videos');

    await widgetTester.tap(breadcrumbsFinder);
    await widgetTester.pumpAndSettle();

    expectBreadcrumb(
      widgetTester,
      'Home / Library / Documents / Pictures / Videos',
    );
  });

  testWidgets(
    'should be force expanded and ignore taps',
    (widgetTester) async {
      final crumbs = [
        'Home',
        'Library',
        'Documents',
        'Pictures',
        'Videos',
      ];
      await widgetTester.binding.setSurfaceSize(const Size(150, 50));

      await widgetTester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Breadcrumbs(
            crumbs: crumbs.map((e) => TextSpan(text: e)).toList(),
            expanded: true,
          ),
        ),
      );

      final breadcrumbsFinder = find.byType(Breadcrumbs);
      expect(breadcrumbsFinder, findsOneWidget);
      expectBreadcrumb(
        widgetTester,
        'Home / Library / Documents / Pictures / Videos',
      );

      await widgetTester.tap(breadcrumbsFinder);
      await widgetTester.pumpAndSettle();

      expectBreadcrumb(
        widgetTester,
        'Home / Library / Documents / Pictures / Videos',
      );
    },
  );

  testWidgets('should ignore taps', (widgetTester) async {
    final crumbs = [
      'Home',
      'Library',
      'Documents',
      'Pictures',
      'Videos',
    ];
    await widgetTester.binding.setSurfaceSize(const Size(150, 50));

    await widgetTester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Breadcrumbs(
          crumbs: crumbs.map((e) => TextSpan(text: e)).toList(),
          toggleExpansionOnTap: false,
        ),
      ),
    );

    final breadcrumbsFinder = find.byType(Breadcrumbs);
    expect(breadcrumbsFinder, findsOneWidget);
    expectBreadcrumb(widgetTester, 'Home / ... / Videos');

    await widgetTester.tap(breadcrumbsFinder);
    await widgetTester.pumpAndSettle();

    expectBreadcrumb(widgetTester, 'Home / ... / Videos');
  });
}
