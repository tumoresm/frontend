import 'package:fieldforce/constants/constants.dart';
import 'package:fieldforce/features/companies/view/add_company.dart';
import 'package:fieldforce/features/order/view/create_neworder.dart';
import 'package:flutter/material.dart';
import 'package:fieldforce/theme/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static Route<void> route() => MaterialPageRoute(
        builder: (context) => const HomePage(),
      );

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _page = 0;

  void _onAddNew() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); // Close the dialog first
                  await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: CreateOrderPage(),
                    ),
                  );
                },
                child: const Text('New Order'),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); // Close the dialog first
                  await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: AddCompanyPage(),
                    ),
                  );
                },
                child: const Text('Add Company'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UIConstants.appBar(),
      body: IndexedStack(
        index: _page,
        children: UIConstants.navPages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddNew,
        backgroundColor: Colours.selectedIndex,
        child: const Icon(
          Icons.add,
          color: Colours.whiteColor,
          size: 28,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _page,
        onDestinationSelected: (index) => setState(() => _page = index),
        indicatorColor: Colours.selectedIndex,
        backgroundColor: Colours.backgroundColor,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
