import 'package:flutter/material.dart';

class Calculadora extends StatefulWidget {
  const Calculadora({super.key});

  @override
  State<Calculadora> createState() => _CalculadoraState();
}

class _CalculadoraState extends State<Calculadora> {
  String operacion = "";

  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            //Expanded es para children,
            Expanded(
              child: Container(
                //Es un atributo de un input, no se puede colocar un double infinity en el children, solo en el child
                width: double.infinity,

                //20 se refiere a puntos no a pixeles (medida usada en desarrollo móvil)
                padding: const EdgeInsets.all(20),
                child: Column(
                  //Alinea al ancho
                  mainAxisAlignment: MainAxisAlignment.end,

                  //Alinea al alto
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "5 + 7",
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),

                    SizedBox(height: 10),
                    Text(
                      operacion,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(children: [boton("7"), boton("8"), boton("9"), boton("/")]),
            Row(children: [boton("4"), boton("5"), boton("6"), boton("*")]),
            Row(children: [boton("1"), boton("2"), boton("3"), boton("+")]),
            Row(children: [boton("hola"), boton("0"), boton(","), boton("-")]),
          ],
        ),
      ),
    );
  }

  Widget boton(String texto) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            operacion += texto;
          });
        },
        child: Text(texto),
      ),
    );
  }
}
