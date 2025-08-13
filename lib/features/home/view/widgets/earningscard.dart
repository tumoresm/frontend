import 'package:fieldforce/theme/app_colours.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class EarningsCard extends StatelessWidget {
  const EarningsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 160,
        width: 350,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(children: [
            Expanded(
              flex: 2,
              child: Container(
                color: kBlack,
                child: const Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(14.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Symbols.money_bag),
                                  SizedBox(width: 10),
                                  Text('Total Earnings')
                                ],
                              ),
                              SizedBox(height: 25),
                              //TODO fetch and display the Total Amount Earned by Rep here
                              Text(
                                'R25,058.00',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              )
                            ],
                          ),
                          VerticalDivider(
                            thickness: 2,
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Symbols.monetization_on),
                                  SizedBox(width: 10),
                                  Text('Total Paid')
                                ],
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              //TODO fetch and display the Total Amount Paid to Rep here
                              Text(
                                'R10,200.00',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ]),
        ));
  }
}
