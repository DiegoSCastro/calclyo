import 'package:calclyo/src/features/rule_of_three/data/rule_of_three_repository.dart';
import 'package:calclyo/src/features/rule_of_three/domain/rule_of_three_input.dart';
import 'package:calclyo/src/features/rule_of_three/presentation/cubit/rule_of_three_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RuleOfThreeView extends StatelessWidget {
  const RuleOfThreeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => RuleOfThreeCubit(ctx.read<RuleOfThreeRepository>()),
      child: const _RuleOfThreeScaffold(),
    );
  }
}

class _RuleOfThreeScaffold extends StatefulWidget {
  const _RuleOfThreeScaffold();

  @override
  State<_RuleOfThreeScaffold> createState() => _RuleOfThreeScaffoldState();
}

class _RuleOfThreeScaffoldState extends State<_RuleOfThreeScaffold> {
  final _a = TextEditingController(text: '2');
  final _b = TextEditingController(text: '10');
  final _c = TextEditingController(text: '7');
  RuleOfThreeKind _kind = RuleOfThreeKind.direct;

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    _c.dispose();
    super.dispose();
  }

  void _onCalculate() {
    final a = double.tryParse(_a.text);
    final b = double.tryParse(_b.text);
    final c = double.tryParse(_c.text);
    if (a == null || b == null || c == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid numbers in all three fields')),
      );
      return;
    }
    context.read<RuleOfThreeCubit>().solve(
          RuleOfThreeInput(a: a, b: b, c: c, kind: _kind),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rule of Three')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<RuleOfThreeKind>(
              segments: const [
                ButtonSegment(
                  value: RuleOfThreeKind.direct,
                  label: Text('Direct'),
                ),
                ButtonSegment(
                  value: RuleOfThreeKind.inverse,
                  label: Text('Inverse'),
                ),
              ],
              selected: {_kind},
              onSelectionChanged: (s) => setState(() => _kind = s.first),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _field(_a, 'a')),
                const SizedBox(width: 8),
                Expanded(child: _field(_b, 'b')),
                const SizedBox(width: 8),
                Expanded(child: _field(_c, 'c')),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _onCalculate,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate x'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<RuleOfThreeCubit, RuleOfThreeState>(
                builder: (context, state) {
                  return switch (state) {
                    RuleOfThreeInitial() => const Center(
                        child: Text('Enter values and tap "Calculate"'),
                      ),
                    RuleOfThreeFailed(:final message) => Center(
                        child: Text('Error: $message'),
                      ),
                    RuleOfThreeSolved(:final result) => _ResultCard(result),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard(this.result);
  final RuleOfThreeResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('x = ${result.x.toStringAsFixed(6)}',
                style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),
            for (final step in result.steps) Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(step),
            ),
          ],
        ),
      ),
    );
  }
}
