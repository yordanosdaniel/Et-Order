// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_project/screens/delivery_information/checkout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../chapa_payment/chapa_payment initializer.dart';
import '../../provider/cart_and _provider.dart';

class IntermidatePage extends StatelessWidget {
  final double total;
  const IntermidatePage({
    Key? key,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final cartProvider = Provider.of<CartProvider>(context);


    User? user = FirebaseAuth.instance.currentUser;
    final currentUser = user!.uid;
     Uuid uuid = Uuid();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "Payment",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 50,
          ),
          const Center(
            child: Image(
              image: AssetImage(
                "assets/payment.jpg",
              ),
              height: 200,
            ),
          ),
          const SizedBox(
            height: 70,
          ),
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('customers')
                  .doc(currentUser)
                  .snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (!snapshot.hasData) {
                  print("no address found");
                }
                if (snapshot.data == null) {
                  return const Center(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                var addressDoc = snapshot.data!;

                String _fullName = addressDoc["customer information"]['name'];
                List name = _fullName.split(" ");
                String fname = name[0];
                String lname = name[1];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  child: MaterialButton(
                    onPressed: () {
                      var id = uuid.v4();
                      Chapa.paymentParameters(
                        context: context, // context
                        publicKey:
                            'CHASECK_TEST-31TfdtPdKjsH2jQn5LM2mkMa36dtYAxU',
                        currency: 'ETB',
                        amount: total.toString(),
                        email: addressDoc["customer information"]['email'],
                        firstName: fname,
                        lastName: lname,
                        txRef: id,
                        title: 'title',
                        desc: 'desc',
                        namedRouteFallBack:
                            '/fallbackSuccess', // fall back route name
                      );
                    },
                    color: Colors.green[500],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Text(
                            "Go to payment",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 40,
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20,),
              MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Checkout(
                                        total: cartProvider.deliveryFee+cartProvider.subTotal,
                                        deliveryFee: cartProvider.deliveryFee,
                                        subtotal: cartProvider.subTotal,
                                      )));
                    },
                    color: Colors.orange[500],
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 28.0, vertical: 16),
                      child: Text(
                        "Continue without Payment",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
        ],
      ),
    );
  }
}
