import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

Widget dropdown(
  BuildContext context,
  List<String> parentLocations,
  void Function(String?)? onChangedFunction,
  String label,
  Icon icon,
  {double border_radius = 5,
    Color container_color= Colors.white
  }
) {
  return Container(
    width: MediaQuery.of(context).size.width / 1.5,
    color: container_color,
    child: Theme(
      data: ThemeData(
        textTheme: const TextTheme(titleMedium: TextStyle(color: Colors.black)),
      ),
      // child:const Text('dropdown is commented '),
      child: DropdownSearch<String>(
        // popupBackgroundColor: Colors.white,
        popupProps: PopupProps.menu(
          showSelectedItems: true,
          showSearchBox: true,
        ),
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration (
              labelText: 'Select an item',
              labelStyle: TextStyle(color: Colors.black),
              floatingLabelStyle: TextStyle(color: Colors.black),
              prefixStyle: TextStyle(color: Colors.black),
              fillColor: Colors.deepOrange,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(border_radius)),
                borderSide: BorderSide(
                  color: Colors.blue,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(border_radius)),
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              prefixIcon: icon
          ),
        ),
        // dropdownSearchDecoration: InputDecoration (
        //     labelStyle: TextStyle(color: Colors.black),
        //     floatingLabelStyle: TextStyle(color: Colors.black),
        //     prefixStyle: TextStyle(color: Colors.black),
        //     fillColor: Colors.deepOrange,
        //     enabledBorder: OutlineInputBorder(
        //       borderRadius: BorderRadius.all(Radius.circular(border_radius)),
        //       borderSide: BorderSide(
        //         color: Colors.blue,
        //         width: 2,
        //       ),
        //     ),
        //     focusedBorder: OutlineInputBorder(
        //       borderRadius: BorderRadius.all(Radius.circular(border_radius)),
        //       borderSide: BorderSide(
        //         color: Colors.red,
        //         width: 2,
        //       ),
        //     ),
        //     prefixIcon: icon
        // ),
        // showAsSuffixIcons: true,
        // showClearButton: true,
        // showSelectedItems: true,
        items: parentLocations,
        // items: [
        //   "Brazil",
        //   "Italia (Disabled)",
        //   "Tunisia",
        //   "Canada"
        // ],
        // label: label,
        // popupItemDisabled: (String s) => s.startsWith('I'),
        onChanged: onChangedFunction,
        // selectedItem: "Brazil"
      ),
    ),
  );
}
