
import 'package:flutter/material.dart';

import 'item_details_screen.dart';
import 'items.dart';


class ItemUIDesignWidget extends StatefulWidget
{
  Items? itemsInfo;
  BuildContext? context;

  ItemUIDesignWidget({
    this.itemsInfo,
    this.context,
  });

  @override
  State<ItemUIDesignWidget> createState() => _ItemUIDesignWidgetState();
}




class _ItemUIDesignWidgetState extends State<ItemUIDesignWidget>
{
  @override
  Widget build(BuildContext context)
  {
    return InkWell(
      onTap: ()
      {
        //send user to the item detail screen
        Navigator.push(context, MaterialPageRoute(builder: (c)=> ItemDetailsScreen(
          clickedItemInfo: widget.itemsInfo,
        )));
      },
      splashColor: Colors.purple,
      child: Container(

        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration:  BoxDecoration(
          border: Border.all(color: Colors.black12, width: 2),
          borderRadius: BorderRadius.circular(5),
          color: Colors.grey.shade200
        ),

        width: MediaQuery.of(context).size.width,
        child:Image.network(
          widget.itemsInfo!.itemImage.toString(),
          width: 140,
          height: 140,
        ),
      ),
    );
  }
}
