import 'package:fieldforce/features/home/view/navbar_pages/home_page.dart';
import 'package:fieldforce/features/home/view/navbar_pages/orders_page.dart';
import 'package:fieldforce/features/home/view/navbar_pages/user_profile_page.dart';
import 'package:fieldforce/features/home/view/navbar_pages/wallet_page.dart';
import 'package:flutter/material.dart';

List<Widget> navPages = [
  const HomePage(),
  const OrdersPage(),
  //const OrderTrackingPage(),
  const WalletPage(),
  const UserProfilePage(),
];
