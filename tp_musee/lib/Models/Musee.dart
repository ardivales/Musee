// To parse this JSON data, do
//
//     final musee = museeFromJson(jsonString);

import 'dart:convert';

Musee museeFromJson(String str) => Musee.fromJson(json.decode(str));

String museeToJson(Musee data) => json.encode(data.toJson());

class Musee {
    Musee({
        required this.numMus,
        required this.nomMus,
        required this.nblivres,
        required this.codePays,
    });

    int numMus;
    String nomMus;
    int nblivres;
    String codePays;

    factory Musee.fromJson(Map<String, dynamic> json) => Musee(
        numMus: json["numMus"],
        nomMus: json["nomMus"],
        nblivres: json["nblivres"],
        codePays: json["codePays"],
    );

    Map<String, dynamic> toJson() => {
        // "numMus": numMus,
        "nomMus": nomMus,
        "nblivres": nblivres,
        "codePays": codePays,
    };

    Map<String, dynamic> toJsonWithNumMus() => {
        "numMus": numMus,
        "nomMus": nomMus,
        "nblivres": nblivres,
        "codePays": codePays,
    };
}
