import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

Widget dropdown(BuildContext context, List<String> parentLocations,
    void Function(String?)? onChangedFunction, String label, Icon icon,
    {double border_radius = 5, Color container_color = Colors.white}) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.72,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.0),
      color: container_color,
    ),
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
          dropdownSearchDecoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Colors.black,fontSize: 16,),
              floatingLabelStyle: TextStyle(color: Colors.black),
              prefixStyle: TextStyle(color: Colors.black),
              fillColor: Colors.deepOrange,
             
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(border_radius)),
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              prefixIcon: icon
          ),
        ),
        items: parentLocations,
       
        onChanged: onChangedFunction,
       
      ),
    ),
  );
}
