import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:new_laundry/app/modules/dashboard/views/dashboard_view.dart';
import 'package:new_laundry/app/modules/profile/views/profile_view.dart';
import 'package:new_laundry/app/modules/service/views/service_view.dart';
import 'package:new_laundry/app/modules/trasanction/views/trasanction_view.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

int _selectedIndex = 0;
Widget getBody(){
  switch(_selectedIndex){
    case 0:
      return  DashboardView();
    case 1:
      return  TrasanctionView();
    case 2:
      return ServiceView();
    case 3:
      return const ProfileView();

    default:
      return const Center(
        child: Text('Error'),
      );
  }
}


class _BottomNavbarState extends State<BottomNavbar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
      bottomNavigationBar: ConvexAppBar(
        items: const [
          // make with fontawesome
          TabItem(icon: FontAwesomeIcons.home, title: 'Dashboard'),
          TabItem(icon: FontAwesomeIcons.cashRegister, title: 'Transaksi'),
          TabItem(icon: FontAwesomeIcons.shoppingBag, title: 'Service'),
          TabItem(icon: FontAwesomeIcons.user, title: 'Profile'),
        ],
        onTap: (int i) => setState(() => _selectedIndex = i,),
      )
    );
  }
}
