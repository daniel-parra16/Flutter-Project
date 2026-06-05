import 'package:flutter/material.dart';

class Calculadora extends StatefulWidget {
  const Calculadora({super.key});

  @override
  State<Calculadora> createState() => _CalculadoraState();
}

class _CalculadoraState extends State<Calculadora> {
  String operacion = "";
  String numeroActual = "";
  String resultado = "0";
  List<String> elementos = [];

  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 24, 24, 24),
      body: SafeArea(
        child: Column(
          children: [
            //Expanded es para children,
            Expanded(
              flex: 2,
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
                      operacion == "" ? "0" : operacion,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),
                    Text(
                      resultado,
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [boton("CA"), boton("CE"), boton(""), boton("")],
                  ),
                  Row(
                    children: [boton("7"), boton("8"), boton("9"), boton("/")],
                  ),
                  Row(
                    children: [boton("4"), boton("5"), boton("6"), boton("*")],
                  ),
                  Row(
                    children: [boton("1"), boton("2"), boton("3"), boton("-")],
                  ),
                  Row(
                    children: [
                      boton("hola"),
                      boton("0"),
                      boton("="),
                      boton("+"),
                    ],
                  ),
                ],
              ),
            ),
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
            switch (texto) {
              case "CA":
                operacion = "";
                resultado = "0";
                numeroActual = "";
                elementos.clear();
                break;

              case "CE":
                operacion = "";
                numeroActual = "";
                elementos.clear();
                break;

              case "<-":
                if (operacion.isNotEmpty) {
                  operacion = operacion.substring(0, operacion.length - 1);
                }
                break;

              case "=":
                /* try {
                  if (operacion.contains("+")) {
                    var partes = operacion.split("+");
                    resultado =
                        (double.parse(partes[0]) + double.parse(partes[1]))
                            .toString();
                  } else if (operacion.contains("-")) {
                    var partes = operacion.split("-");
                    resultado =
                        (double.parse(partes[0]) - double.parse(partes[1]))
                            .toString();
                  } else if (operacion.contains("*")) {
                    var partes = operacion.split("*");
                    resultado =
                        (double.parse(partes[0]) * double.parse(partes[1]))
                            .toString();
                  } else if (operacion.contains("/")) {
                    var partes = operacion.split("/");
                    resultado =
                        (double.parse(partes[0]) / double.parse(partes[1]))
                            .toString();
                  }
                } catch (e) {
                  resultado = "Error";
                } */

                if (numeroActual.isNotEmpty) {
                  elementos.add(numeroActual);
                }

                try {
                  List<dynamic> temp = List.from(elementos);

                  // Primero * y /
                  for (int i = 0; i < temp.length; i++) {
                    if (temp[i] == "*" || temp[i] == "/") {
                      double a = double.parse(temp[i - 1]);
                      double b = double.parse(temp[i + 1]);

                      double res = temp[i] == "*" ? a * b : a / b;

                      temp.replaceRange(i - 1, i + 2, [res.toString()]);
                      i--;
                    }
                  }

                  // Luego + y -
                  for (int i = 0; i < temp.length; i++) {
                    if (temp[i] == "+" || temp[i] == "-") {
                      double a = double.parse(temp[i - 1]);
                      double b = double.parse(temp[i + 1]);

                      double res = temp[i] == "+" ? a + b : a - b;

                      temp.replaceRange(i - 1, i + 2, [res.toString()]);
                      i--;
                    }
                  }

                  resultado = temp.first.toString();
                } catch (e) {
                  resultado = "Error";
                }

                break;

              case "+":
              case "-":
              case "*":
              case "/":
                if (numeroActual.isNotEmpty) {
                  elementos.add(numeroActual);
                  elementos.add(texto);
                  numeroActual = "";
                  operacion += texto;
                  print("Resultado: $elementos");
                }

              default:
                operacion += texto;
                numeroActual += texto;
                break;
            }
          });
        },
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
