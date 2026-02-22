import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      restorationScopeId: 'app',
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RestorationMixin {
  final RestorableInt taka = RestorableInt(0);

  @override
  String? get restorationId => 'home';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(taka, 'taka');
  }

  @override
  void dispose() {
    taka.dispose();
    super.dispose();
  }

  void pressDigit(int n) {
    setState(() {
      // Prevent leading zeros and limit to 7 digits to prevent int overflow
      if (taka.value == 0 && n == 0) return;
      if (taka.value.toString().length < 10) {
        taka.value = taka.value * 10 + n;
      }
    });
  }

  void clearAmount() {
    setState(() {
      taka.value = 0;
    });
  }

  static const bills = [500, 100, 50, 20, 10, 5, 2, 1];

  Map<int, int> makeChange(int value) {
    final result = <int, int>{};
    int remaining = value;

    for (final n in bills) {
      result[n] = remaining ~/ n;
      remaining = remaining % n;
    }
    return result;
  }

  Widget keyBtn(String text, VoidCallback onTap, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ElevatedButton(
          onPressed: onTap,
          child: Text(text),
        ),
      ),
    );
  }

  Widget portraitKeypad() {
    return Column(
      children: [
        Expanded(
          child: Row(children: [
            keyBtn('1', () => pressDigit(1)),
            keyBtn('2', () => pressDigit(2)),
            keyBtn('3', () => pressDigit(3)),
          ]),
        ),
        Expanded(
          child: Row(children: [
            keyBtn('4', () => pressDigit(4)),
            keyBtn('5', () => pressDigit(5)),
            keyBtn('6', () => pressDigit(6)),
          ]),
        ),
        Expanded(
          child: Row(children: [
            keyBtn('7', () => pressDigit(7)),
            keyBtn('8', () => pressDigit(8)),
            keyBtn('9', () => pressDigit(9)),
          ]),
        ),
        Expanded(
          child: Row(children: [
            keyBtn('0', () => pressDigit(0)),
            keyBtn('CLEAR', clearAmount, flex: 2),
          ]),
        ),
      ],
    );
  }

  Widget landscapeKeypad() {
    return Column(
      children: [
        Expanded(
          child: Row(children: [
            keyBtn('1', () => pressDigit(1)),
            keyBtn('2', () => pressDigit(2)),
            keyBtn('3', () => pressDigit(3)),
            keyBtn('4', () => pressDigit(4)),
          ]),
        ),
        Expanded(
          child: Row(children: [
            keyBtn('5', () => pressDigit(5)),
            keyBtn('6', () => pressDigit(6)),
            keyBtn('7', () => pressDigit(7)),
            keyBtn('8', () => pressDigit(8)),
          ]),
        ),
        Expanded(
          child: Row(children: [
            keyBtn('9', () => pressDigit(9)),
            keyBtn('0', () => pressDigit(0)),
            keyBtn('CLEAR', clearAmount, flex: 2),
          ]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final change = makeChange(taka.value);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(title: const Text('VangtiChai')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text('Taka: ${taka.value}', style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: ChangeTable(change: change)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: isLandscape ? landscapeKeypad() : portraitKeypad(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangeTable extends StatelessWidget {
  final Map<int, int> change;
  const ChangeTable({super.key, required this.change});

  static const bills = [500, 100, 50, 20, 10, 5, 2, 1];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (final n in bills)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$n:'),
                Text('${change[n] ?? 0}'),
              ],
            ),
          ),
      ],
    );
  }
}