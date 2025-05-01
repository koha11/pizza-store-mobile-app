import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/controller_home.dart';

class PageHome extends StatelessWidget {
  const PageHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pizza Store"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: GetBuilder(
        id: "home",
        init: HomePizzaStoreController.get(),
        builder: (controller) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Image.network("https://ilmio.vn/uploads/slider/10.png"),
                    Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                Text("Your location"),
                                Text("Nha Trang City"),
                              ],
                            ),
                            Icon(Icons.search),
                            Icon(Icons.notifications),
                          ],
                        ),
                        Text("Provide the best"),
                        Text("food for you"),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
