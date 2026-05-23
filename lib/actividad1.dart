import 'package:flutter/material.dart';

class Actividad1 extends StatelessWidget {
  const Actividad1({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Actividad 1',
      home: Scaffold(
        appBar: AppBar(title: const Text('Tarjeta Información')),
        body: Center(
          child: Container(
            width: 500,
            height: 250,
            margin: EdgeInsets.all(50),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 210, 174, 161),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Icon(Icons.person, size: 80, color: Colors.black),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: const [
                        Text(
                          "Daniel Parra",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Icon(Icons.email, size: 30, color: Colors.black),
                            Text("Danielestebanparraruiz22@gmail.com"),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 30, color: Colors.black),
                            Text("3105069404"),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 30,
                              color: Colors.black,
                            ),
                            Text("Bogota"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
