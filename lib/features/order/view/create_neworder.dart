import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateOrderPage extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const CreateOrderPage(),
      );
  const CreateOrderPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateOrderPageState();
}

class _CreateOrderPageState extends ConsumerState<CreateOrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.close,
            size: 30,
          ),
        ),
        title: const Text(
          'Create New Order',
        ),
      ),
    );
  }
}
