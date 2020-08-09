import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../providers/orders.dart' as OI;
import 'package:intl/intl.dart';
import 'dart:math';

class OrderItem extends StatefulWidget {
  final OI.OrderItem orderItem;

  OrderItem(this.orderItem);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      elevation: 10,
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              '\$ ' + widget.orderItem.amount.toStringAsFixed(2),
              style: TextStyle(fontSize: 20),
            ),
            subtitle: Text(
                DateFormat('dd/MM/yyyy').format(widget.orderItem.dateTime)),
            trailing: IconButton(
              icon: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 35,
              ),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          if (_isExpanded)
            Container(
              padding: EdgeInsets.all(10),
              height: min(widget.orderItem.products.length * 20.0 + 15, 180),
              child: ListView.builder(
                itemBuilder: (ctx, i) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        widget.orderItem.products[i].title,
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        widget.orderItem.products[i].quantity.toString() +
                            ' x  \$' +
                            widget.orderItem.products[i].price
                                .toStringAsFixed(2),
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  );
                },
                itemCount: widget.orderItem.products.length,
              ),
            ),
        ],
      ),
    );
  }
}
