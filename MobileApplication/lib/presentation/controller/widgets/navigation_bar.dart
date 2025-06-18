import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rrgbm/presentation/shared/extensions/context_extensions.dart';

class ShopNavigationBar extends StatefulWidget {
  final void Function(int) onIndexChange;

  const ShopNavigationBar({Key? key, required this.onIndexChange}) : super(key: key);

  @override
  State<ShopNavigationBar> createState() => _ShopNavigationBarState();
}

class _ShopNavigationBarState extends State<ShopNavigationBar> {
  int _currentIndex = 0;


  void _onIndexChange(int index) {
    if (index == _currentIndex) return;

    widget.onIndexChange(index);

    setState(() {
      _currentIndex = index;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(12),
            topLeft: Radius.circular(12)
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onIndexChange,
        backgroundColor: context.colorScheme.primary,
        selectedItemColor: context.colorScheme.onPrimary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.gamepad),
              label: "Controller",
          ),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.gears),
              label: "Automation"
          )
        ],
      ),
    );
  }
}
