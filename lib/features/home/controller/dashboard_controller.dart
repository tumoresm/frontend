import 'package:fieldforce/features/home/controller/navbar_controller.dart';
import 'package:fieldforce/features/home/view/widgets/dialog_screens.dart';
import 'package:fieldforce/features/home/view/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:fieldforce/theme/theme.dart';

class DashBoardController extends StatefulWidget {
  const DashBoardController({super.key});

  static Route<void> route() => MaterialPageRoute(
        builder: (context) => const DashBoardController(),
      );

  @override
  State<DashBoardController> createState() => _DashBoardControllerState();
}

class _DashBoardControllerState extends State<DashBoardController> {
  int _page = 0;

  void _onAddNew() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: kSecondary,
      builder: (context) => const AddNewDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navPages[_page],
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddNew,
        backgroundColor: Colours.selectedIndex,
        child: const Icon(
          Icons.add,
          color: Colours.whiteColor,
          size: 28,
        ),
      ),
      bottomNavigationBar: HomeNavBar(
        selectedIndex: _page,
        onDestinationSelected: (index) => setState(() => _page = index),
      ),
    );
  }
}

// final List<Widget> navPages = [
//   const Text('Home Page'),
  
//   const Text('Notifications Page'),
  
// ];
