import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identist_app/identist_app.dart';

Widget _host(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? GlassTheme.darkTheme,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('wordmark: "iDentist" + ".Live" + verified badge', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const IDentistLiveTitle()));
    expect(find.text('iDentist'), findsOneWidget);
    expect(find.text('.Live'), findsOneWidget);
    expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
  });

  testWidgets('splash is S3: tile, title, pill, lock line, Made in India', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(AppIconTile), findsOneWidget);
    expect(find.byType(BrandTitle), findsOneWidget);
    expect(find.text('PREMIUM DENTIST PLATFORM'), findsOneWidget);
    expect(find.text('PREMIUM DENTIST ECOSYSTEM'), findsNothing);
    expect(find.text(splashUnlockingText), findsOneWidget);
    expect(find.text('Made in India'), findsOneWidget);
    expect(find.text('Made for India'), findsOneWidget);
    expect(find.byType(IndiaFlag), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('splash shows the step in place of the lock line', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: SplashScreen(message: 'Signing you in…')),
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byKey(const ValueKey('splash_message')), findsOneWidget);
    expect(find.text(splashUnlockingText), findsNothing);
  });

  testWidgets('splash fits a small phone and a big window', (tester) async {
    for (final size in const [Size(320, 568), Size(1440, 900)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
      await tester.pump(const Duration(milliseconds: 700));
      expect(tester.takeException(), isNull, reason: '$size');
    }
    tester.view.reset();
  });

  testWidgets('GlassContainer renders its child in dark and light', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const GlassContainer(child: Text('inside'))));
    expect(find.text('inside'), findsOneWidget);
    await tester.pumpWidget(
      _host(
        const GlassContainer(child: Text('inside')),
        theme: GlassTheme.lightTheme,
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('inside'), findsOneWidget);
  });

  for (final dark in [false, true]) {
    testWidgets(
      'GlassContainer: blurSigma 0 drops the backdrop filter, same pixels (${dark ? 'dark' : 'light'})',
      (tester) async {
        tester.view.physicalSize = const Size(320, 200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final theme = dark ? GlassTheme.darkTheme : GlassTheme.lightTheme;

        Future<List<int>> shot(double sigma) async {
          final key = GlobalKey();
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: RepaintBoundary(
                  key: key,
                  child: ColoredBox(
                    color: theme.scaffoldBackgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: GlassContainer(
                        blurSigma: sigma,
                        child: const SizedBox(width: 240, height: 120),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 600));
          expect(
            find.byType(BackdropFilter),
            sigma > 0 ? findsOneWidget : findsNothing,
          );
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final bytes = await tester.runAsync(() async {
            final image = await boundary.toImage();
            final data = await image.toByteData();
            image.dispose();
            return data!.buffer.asUint8List().toList();
          });
          return bytes!;
        }

        final blurred = await shot(15);
        final plain = await shot(0);
        expect(plain.length, blurred.length);
        var worst = 0;
        var sum = 0;
        for (var i = 0; i < plain.length; i++) {
          final d = (plain[i] - blurred[i]).abs();
          sum += d;
          if (d > worst) worst = d;
        }
        final mean = sum / plain.length;
        expect(mean, lessThan(1.0), reason: 'mean channel difference $mean');
        expect(
          worst,
          lessThanOrEqualTo(16),
          reason: 'largest channel difference $worst',
        );
      },
    );
  }

  testWidgets('TopNotification appears, then hides itself', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => TopNotification.success(context, 'Saved'),
                child: const Text('notify'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('notify'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Saved'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(find.text('Saved'), findsNothing);
  });

  testWidgets(
    'TopNotification with an action: stays while sticky, runs the action, then goes',
    (tester) async {
      var acted = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => TopNotification.show(
                    context,
                    message: 'Update ready',
                    color: Colors.blue,
                    duration: Duration.zero,
                    actionLabel: 'Reload now',
                    onAction: () => acted++,
                  ),
                  child: const Text('notify'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('notify'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 30));
      expect(
        find.text('Update ready'),
        findsOneWidget,
        reason: 'a sticky note stays',
      );
      await tester.tap(find.byKey(const Key('top_notification_action')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(acted, 1);
      expect(
        find.text('Update ready'),
        findsNothing,
        reason: 'the note goes once acted on',
      );
    },
  );

  testWidgets('UserAvatar falls back to the initial', (tester) async {
    await tester.pumpWidget(
      _host(const UserAvatar(photo: null, displayName: 'sample person')),
    );
    expect(find.text('S'), findsOneWidget);

    await tester.pumpWidget(
      _host(const UserAvatar(photo: 'not base64 !', displayName: 'Asha')),
    );
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('WriteFailureBanner: hidden when empty, names a single failure', (
    tester,
  ) async {
    var retried = 0;
    var dismissed = 0;

    await tester.pumpWidget(
      _host(
        WriteFailureBanner(
          failureLabels: const [],
          onRetryAll: () {},
          onDismiss: () {},
        ),
      ),
    );
    expect(find.byType(TextButton), findsNothing);

    await tester.pumpWidget(
      _host(
        WriteFailureBanner(
          failureLabels: const ['Payment of 1500.00'],
          onRetryAll: () => retried++,
          onDismiss: () => dismissed++,
        ),
      ),
    );
    expect(
      find.textContaining('Payment of 1500.00 was not saved'),
      findsOneWidget,
    );
    await tester.tap(find.text('Retry'));
    await tester.tap(find.byTooltip('Dismiss'));
    expect(retried, 1);
    expect(dismissed, 1);
  });

  test('breakpoints keep their values', () {
    expect(Responsive.mobile, 900);
    expect(Responsive.tablet, 760);
    expect(Responsive.phone, 430);
    expect(Responsive.phoneNarrow, 360);
  });
}
