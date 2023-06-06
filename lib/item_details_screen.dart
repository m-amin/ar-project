
import 'package:ar_example/virtual_ar_view_screen.dart';
import 'package:flutter/material.dart';

import 'items.dart';

class ItemDetailsScreen extends StatefulWidget
{
  Items? clickedItemInfo;

  ItemDetailsScreen({this.clickedItemInfo,});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}




class _ItemDetailsScreenState extends State<ItemDetailsScreen>
{
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.clickedItemInfo!.itemName.toString(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.pinkAccent,
        onPressed: ()
        {
          //try item virtually (arview)
          Navigator.push(context, MaterialPageRoute(builder: (c)=> VirtualARViewScreen(
            clickedItemImageLink: widget.clickedItemInfo!.itemImage.toString(),
          )));
        },
        label: const Text(
          "Try Virtually (AR View)",
        ),
        icon: const Icon(
          Icons.mobile_screen_share_rounded,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Image.network(
                widget.clickedItemInfo!.itemImage.toString(),
              ),
              Divider(thickness: 2, color: Colors.black12,)
            ],
          ),
        ),
      ),
    );
  }
}
