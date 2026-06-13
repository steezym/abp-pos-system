import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:pos_mobile/models/DetailTransaction.dart';
import 'package:pos_mobile/models/Transaction.dart';
import '../services/api_service.dart';

class TransactionScreen extends StatefulWidget{
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}


class _TransactionScreenState extends State<TransactionScreen> {
  late Future<DetailTransaction> productTransasction;
  late Future<List<Transaction>> transactions2;
  List<dynamic> transactions = [];
  var inputSearchTransaction = TextEditingController();
  var inputStartDate = TextEditingController();
  var inputEndDate = TextEditingController();

  String startDate = "";
  String endDate = "";

  String formatDate(String date) {
    List<String> splitDate = date.split("-");
    String formattedDate = "${splitDate[2]}-${splitDate[1]}-${splitDate[0]}";
    return formattedDate;
  }

  String formatTime(String time) {
    String formattedTime = time.substring(0,5);
    return formattedTime;
  }

  String formatRupiah(int amount) {
    return NumberFormat.currency(
        locale: "id",
        symbol: "Rp. "
    ).format(amount);
  }

  @override

  void initState() {
    super.initState();
    inputStartDate.text ="";
    inputEndDate.text ="";
    startDate = "";
    endDate = "";
    transactions2 = ApiService.getTransactions2();
  }

  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Padding(
                padding: EdgeInsets.only(right: 20,left: 20, top: 20),
                child: Column(
                  children: [
                    Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search_rounded),
                              hintText: "Cari ID Transaksi"
                          ),
                          onChanged: (val) {
                            setState(() {
                              inputSearchTransaction.text = val.toString();
                              transactions2 = ApiService.getTransactions2(search: inputSearchTransaction.text);
                            });
                          },
                          controller: inputSearchTransaction,
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 155,
                              child:TextField(
                                decoration: InputDecoration(hintText: "mm/dd/yyyy", suffixIcon:  Icon(Icons.calendar_month)),
                                controller: inputStartDate,
                                readOnly: true,
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100)
                                  );
                                  if(pickedDate != null) {
                                    String formattedDate = DateFormat("MM/dd/yyyy").format(pickedDate);
                                    setState(() {
                                      List<String> splitDate = formattedDate.split("/");
                                      startDate = "${splitDate[2]}-${splitDate[0]}-${splitDate[1]}";
                                      print(startDate);
                                      inputStartDate.text = formattedDate.toString();
                                    });
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            Container(
                              width: 155,
                              child:TextField(
                                decoration: InputDecoration(hintText: "mm/dd/yyyy", suffixIcon: Icon(Icons.calendar_month)),
                                controller: inputEndDate,
                                readOnly: true,
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100)
                                  );
                                  if(pickedDate != null) {
                                    String formattedDate = DateFormat("MM/dd/yyyy").format(pickedDate);
                                    setState(() {
                                      List<String> splitDate = formattedDate.split("/");
                                      endDate = "${splitDate[2]}-${splitDate[0]}-${splitDate[1]}";
                                      print(endDate);
                                      inputEndDate.text = formattedDate;
                                      transactions2 = ApiService.getTransactions2(start: startDate, end: endDate);
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadiusGeometry.circular(12),
                                    ),
                                    side: BorderSide(
                                        width: 1,
                                        color: Colors.black12
                                    )
                                ),
                                onPressed: () {
                                  setState(() {
                                    inputStartDate.text = "";
                                    inputEndDate.text = "";
                                    startDate = "";
                                    startDate = "";
                                    transactions2 = ApiService.getTransactions2();
                                  });
                                },
                                child: Text('Reset'),
                              ),
                            ]
                        )
                      ],
                    ),
                    SizedBox(height: 30),
                    Expanded(
                        child: FutureBuilder(
                            future: transactions2,
                            builder: (context, snapshot) {
                              if(snapshot.hasData) {
                                return ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      String date = snapshot.data![index].date;
                                      List<String> splitDate = date.split("-");
                                      String formattedDate = "${splitDate[2]}-${splitDate[1]}-${splitDate[0]}";

                                      String formattedTime = formatTime(snapshot.data![index].time);

                                      return Container(
                                        margin: EdgeInsets.only(bottom: 15),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black12,
                                                width: 1
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(20))
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              bottom: 25, top: 20, left: 20, right: 20
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                  width: 140,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text("Transaksi-${snapshot.data![index].id}", style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 18
                                                      )),
                                                      Text("${formatRupiah(snapshot.data![index].total)}", style: TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.black54,
                                                          fontSize: 14
                                                      )),
                                                      SizedBox(height: 20),
                                                      Text(snapshot.data![index].payment_method, style: TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 14
                                                      ))
                                                    ],
                                                  )
                                              ),
                                              Container(
                                                  width: 130,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                          "${formattedDate} ${formattedTime}",
                                                          style: TextStyle(
                                                              color: Colors.black45,
                                                              fontSize: 14
                                                          )
                                                      ),
                                                      SizedBox(height: 25),
                                                      TextButton(
                                                        style: TextButton.styleFrom(
                                                            backgroundColor: Colors.black,
                                                            foregroundColor: Colors.white,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(10)
                                                            ),
                                                            padding: EdgeInsets.only(right: 20,left: 20)
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            productTransasction = ApiService.getTransactionDetails(id : snapshot.data![index].id.toString());
                                                          });
                                                          showDialog(
                                                              context: context,
                                                              builder: (BuildContext context) {
                                                                return Dialog(
                                                                    backgroundColor: Colors.white,
                                                                    child: FutureBuilder<DetailTransaction>(
                                                                        future: productTransasction,
                                                                        builder: (context, snapshot) {
                                                                          if(snapshot.hasData) {
                                                                            return (
                                                                                Container(
                                                                                    padding: EdgeInsets.all(30),
                                                                                    child: SingleChildScrollView(
                                                                                      child: Column(
                                                                                        children: [
                                                                                          Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            children: [
                                                                                              Column(
                                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                spacing: 10,
                                                                                                children: [
                                                                                                  Text("ID Transaksi", style: TextStyle(
                                                                                                      fontSize: 16,
                                                                                                      fontWeight: FontWeight.w700
                                                                                                  )),
                                                                                                  Text("Tanggal", style: TextStyle(
                                                                                                      fontSize: 16,
                                                                                                      fontWeight: FontWeight.w700
                                                                                                  )),
                                                                                                  Text("Waktu", style: TextStyle(
                                                                                                      fontSize: 16,
                                                                                                      fontWeight: FontWeight.w700
                                                                                                  ))
                                                                                                ],
                                                                                              ),
                                                                                              Column(
                                                                                                spacing: 10,
                                                                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                                                                children: [
                                                                                                  Text(snapshot.data!.id.toString(), style: TextStyle(
                                                                                                      fontSize: 14,
                                                                                                      fontWeight: FontWeight.w500,
                                                                                                      color: Colors.black54
                                                                                                  )),
                                                                                                  Text(formatDate(snapshot.data!.date), style: TextStyle(
                                                                                                      fontSize: 14,
                                                                                                      fontWeight: FontWeight.w500,
                                                                                                      color: Colors.black54
                                                                                                  )),
                                                                                                  Text(formatTime(snapshot.data!.time), style: TextStyle(
                                                                                                      fontSize: 14,
                                                                                                      fontWeight: FontWeight.w500,
                                                                                                      color: Colors.black54
                                                                                                  ))
                                                                                                ],
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                          SizedBox(
                                                                                            height: 10,
                                                                                          ),
                                                                                          Divider(
                                                                                            color: Colors.black38,
                                                                                            thickness: 1,
                                                                                          ),
                                                                                          SizedBox(
                                                                                            height: 10,
                                                                                          ),
                                                                                          Container(
                                                                                            child: ListView.separated(
                                                                                              shrinkWrap: true,
                                                                                              itemCount: snapshot.data!.products.length,
                                                                                              physics: NeverScrollableScrollPhysics(),
                                                                                              itemBuilder: (context, index){
                                                                                                return Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                  children: [
                                                                                                    Container(
                                                                                                      width: 80,
                                                                                                      child: Text("${snapshot.data!.products[index].name} x${snapshot.data!.products[index].details.quantity}", style: TextStyle(
                                                                                                          fontWeight: FontWeight.w500,
                                                                                                          fontSize: 14,
                                                                                                          color: Colors.black54
                                                                                                      )),
                                                                                                    ),
                                                                                                    Text("${formatRupiah(snapshot.data!.products[index].price)}", style: TextStyle(
                                                                                                        fontWeight: FontWeight.w500,
                                                                                                        fontSize: 14,
                                                                                                        color: Colors.black54
                                                                                                    ))
                                                                                                  ],
                                                                                                );
                                                                                              },
                                                                                              separatorBuilder: (context, index) {
                                                                                                return SizedBox(height: 8);
                                                                                              },
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(
                                                                                            height: 10,
                                                                                          ),
                                                                                          Divider(
                                                                                            color: Colors.black38,
                                                                                            thickness: 1,
                                                                                          ),
                                                                                          SizedBox(
                                                                                            height: 10,
                                                                                          ),
                                                                                          Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            children: [
                                                                                              Text("Total", style: TextStyle(
                                                                                                  fontSize: 16,
                                                                                                  fontWeight: FontWeight.w700
                                                                                              )),
                                                                                              Text(formatRupiah(snapshot.data!.total), style: TextStyle(
                                                                                                  fontSize: 14,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  color: Colors.black54
                                                                                              ))
                                                                                            ],
                                                                                          ),
                                                                                          SizedBox(height: 20),
                                                                                          TextButton(
                                                                                            style: TextButton.styleFrom(
                                                                                                backgroundColor: Colors.black,
                                                                                                foregroundColor: Colors.white,
                                                                                                minimumSize: Size(double.infinity,50),
                                                                                                shape: RoundedRectangleBorder(
                                                                                                    borderRadius: BorderRadiusGeometry.circular(10)
                                                                                                )
                                                                                            ),
                                                                                            onPressed: () {
                                                                                              Navigator.pop(context);
                                                                                            },
                                                                                            child: Text("Tutup", style: TextStyle(
                                                                                                fontWeight: FontWeight.w700,
                                                                                                fontSize: 14
                                                                                            )),
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                    )
                                                                                )
                                                                            );
                                                                          } else {
                                                                            return Container(
                                                                              height: 400,
                                                                              child: Center(
                                                                                child: CircularProgressIndicator(),
                                                                              ),
                                                                            );
                                                                          }
                                                                        }
                                                                    )
                                                                );
                                                              }
                                                          );
                                                        },
                                                        child: Text('Detail'),
                                                      )
                                                    ],
                                                  )
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                );
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            })
                    )
                  ],
                )
            )
        )
    );
  }
}