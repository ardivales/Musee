import 'package:flutter/material.dart';
import 'package:tp_musee/Bloc/BibliothequeBloc.dart';
import 'package:tp_musee/Bloc/OuvrageBloc.dart';
import 'package:tp_musee/Models/Bibliotheque.dart';
import 'package:tp_musee/Models/Musee.dart';
import 'package:tp_musee/Models/Ouvrage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Bloc/MuseeBloc.dart';
import '../main.dart';

class ListeBibliotheques extends StatefulWidget {
  const ListeBibliotheques({ Key? key }) : super(key: key);

  @override
  State<ListeBibliotheques> createState() => _ListeBibliothequesState();
}

class _ListeBibliothequesState extends State<ListeBibliotheques> implements AlertDialogCallback{
  TextEditingController txtDateAchat = TextEditingController();
  bool validate_dateAchat = true;
  String saveOrUpdateText = '';
  String messageErreur = "";
  bool erreurTextVisible = false;
  String ouvrageISBN = '';
  String ouvrageTitre = '';
  int museeNum = 0;
  String museeNom = '';
  Musee? museeSelected;
  Ouvrage? ouvrageSelected;
  final BibliothequeBloc bibliothequeBloc= BibliothequeBloc();
  final OuvrageBloc ouvrageBloc = OuvrageBloc();
  final MuseeBloc museeBloc = MuseeBloc();

  List<Musee> listMusee = [];
  List<Ouvrage> listOuvrage = [];
  late dynamic selectedBibliotheque ;
  String date = "";
  DateTime selectedDate = DateTime.now();
  String dateText = "";
  bool enableOuvrage = true;
  bool enableMusee = true;

  @override
  void initState() {
    dateText = "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
    var listM = museeBloc.getMusees().then((value){
      listMusee = value;
      if(listMusee.isNotEmpty){
        museeSelected = listMusee[0];
      museeNum = listMusee[0].numMus;
      museeNom = listMusee[0].nomMus;
      print('Liste des Musées ${listMusee[0].codePays}');
      }
      
    });

    var listO = ouvrageBloc.getOuvrage().then((value){
      listOuvrage= value;
      if (listOuvrage.isNotEmpty){
        ouvrageSelected = listOuvrage[0];
        ouvrageISBN = listOuvrage[0].isbn;
        ouvrageTitre = listOuvrage[0].titre + ' ('+ listOuvrage[0].isbn + ')';
        print('Liste des Ouvrages ${listOuvrage[0].codePays}');
      }
    });
    
    super.initState();

  }
  @override
  void dispose(){
    super.dispose();
  }

  Widget getOuvrageWidget(AsyncSnapshot<List> snapshot) {
    if (snapshot.hasData) {
      return snapshot.data!.isNotEmpty
        ? ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: snapshot.data!.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext ctxt, int index) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: InkWell(
                  highlightColor: myColor,
                  onTap: () {
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snapshot.data![index]['nomMus'].toString(),
                              style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
                            ),
                            Text(snapshot.data![index]['titre'].toString()+ ' ('+snapshot.data![index]['isbn'].toString()+ ')',style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),),
                            Visibility(
                              visible: false,
                              child: Text(snapshot.data![index]['numMus'].toString(),
                                style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 5,)
                          ],
                        ),
                        subtitle: Text(snapshot.data![index]['dateAchat'].toString(),style: const TextStyle(fontSize: 12.0),),
                        trailing: Wrap(
                          children: [
                            IconButton(icon: const Icon(
                              Icons.edit, size: 20,
                            ), 
                            onPressed: () {

                              setState(() {
                                selectedBibliotheque = snapshot.data![index];
                                txtDateAchat.text = snapshot.data![index]['dateAchat'].toString();
                                ouvrageISBN= snapshot.data![index]['isbn'].toString();
                                ouvrageTitre= snapshot.data![index]['titre'].toString();
                                museeNum = int.parse(snapshot.data![index]['numMus'].toString());
                                museeNom = snapshot.data![index]['nomMus'].toString();
                                enableOuvrage = false;
                                enableMusee = false;
                                saveOrUpdateText = 'Modifier';
                              });
                              _showDialog();
                              },),

                              IconButton(icon: const Icon(
                              Icons.delete, size: 20,
                            ), 
                            onPressed: () {
                              setState(() {
                                selectedBibliotheque = snapshot.data![index];
                              });
                              _showDialogConfirmation();
                            },),
                          ],
                        ),
                      ),
                      const Divider()
                    ],
                  ),
                ),
              );
            },
          )
        : Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Aucune bibliothèque n'a encore été ajouté", style: TextStyle(fontSize: 20, fontWeight:FontWeight.bold,)),
                const SizedBox(height: 5,),
                Text("Cliquez sur le bouton du bas pour ajouter une bibliothèque", style: TextStyle(color: Colors.grey[600]),),
              ],
            ),
          );

    }else{
      return const Center(child: CircularProgressIndicator());
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
                  height: 35,
                  width: double.infinity,
                  color: const Color(0xFFE6E6E6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        child: const Text('Liste des bibliothèques', style: TextStyle(fontWeight: FontWeight.bold),)
                      ),
                      
                    ],
                  ),
                ),
          ),
          
          StreamBuilder(
            stream: bibliothequeBloc.bibliotheque,
            builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
              return getOuvrageWidget(snapshot);
            }
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: myColor,
        onPressed: () {
          setState(() {
            txtDateAchat.text = "";
            enableOuvrage = true;
            enableMusee = true;
            saveOrUpdateText = 'Enregistrer';
          });
          _showDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  _showDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Bibiothèque"),
              content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: erreurTextVisible,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(10),
                          child: Center(
                              child: Text(messageErreur,
                                style: const TextStyle(
                                  color: Color(0xFFFF0000),
                                  shadows: [
                                    Shadow(
                                      blurRadius: 1,
                                      color: Colors.black26,
                                      offset: Offset(0.5, 0.5),
                                    ),
                                  ],
                                ),)),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFCD7CD),
                            borderRadius: BorderRadius.all(
                                Radius.circular(3)
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      height: 40,
                      child:Row(
                        children: [
                          const Text("Musée"),
                          const Spacer(),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<Musee>(
                              isExpanded: false,
                              items: listMusee.map((Musee musee) {
                                return DropdownMenuItem<Musee>(
                                  value: musee,
                                  child: SizedBox(
                                    width: 150, //expand here
                                    child: Text(
                                      musee.nomMus,
                                      style: const TextStyle(fontSize: 15),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: enableMusee ? (newValue) {
                                setState(() {
                                  museeNum = newValue!.numMus;
                                  museeNom = newValue.nomMus.toString();
                                });
                                // onPaysChange(newValue.toString());
                              }
                              : null,
                              hint: const SizedBox(
                                width: 150, //and here
                                child: Text(
                                  "Musée",
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              style: TextStyle(color: myColor, decorationColor: Colors.red),
                              value: museeSelected,
                            ),
                          ),
                        ],
                      ),
                            
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      width: 300,
                      height: 40,
                      child:Row(
                        children: [
                          const Text("Ouvrage"),
                          const Spacer(),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<Ouvrage>(
                              isExpanded: false,
                              items: listOuvrage.map((Ouvrage ouvrage) {
                                return DropdownMenuItem<Ouvrage>(
                                  value: ouvrage,
                                  child: SizedBox(
                                    width: 150, //expand here
                                    child: Text(
                                      ouvrage.titre + ' ('+ ouvrage.isbn+ ')',
                                      style: const TextStyle(fontSize: 15),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: enableOuvrage ? (newValue) {
                                setState(() {
                                  ouvrageTitre= newValue!.titre.toString();
                                  ouvrageISBN = newValue.isbn.toString();
                                });
                                // onPaysChange(newValue.toString());
                              }
                              : null,
                              hint: const SizedBox(
                                width: 150, //and here
                                child: Text(
                                  "Ouvrage",
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              style: TextStyle(color: myColor, decorationColor: Colors.red),
                              value: ouvrageSelected,
                            ),
                          ),
                        ],
                      ),
                            
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      width: 300,
                      height: 40,
                      child: Row(
                        children: [
                          Text(dateText,
                            style: const TextStyle(color: Colors.black),
                            
                          ),
                          Spacer(),
                          IconButton(onPressed: () async {
                            final DateTime? selected = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2025), 
                            );
                            if (selected != null && selected != selectedDate) {
                              setState(() {
                                selectedDate = selected;
                                dateText = "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                              });
                            }
                          }, 
                          icon: Icon(Icons.arrow_drop_down)
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20,),
                    SizedBox(
                      width: 300,
                      height: 40,
                      child: ElevatedButton(
                          onPressed: () async {
                            if(listMusee.isNotEmpty){
                              if (listOuvrage.isNotEmpty){
                                save();
                                Navigator.pop(context);
                              }else{
                                Fluttertoast.showToast(
                                  msg: "Veuillez enregistrer d'abord un ouvrage",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor: Colors.blue,
                                  textColor: Colors.white,
                                  fontSize: 13.0
                                );
                              }
                            }else{
                              Fluttertoast.showToast(
                                msg: "Veuillez enregistrer d'abord un musée",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 2,
                                backgroundColor: Colors.blue,
                                textColor: Colors.white,
                                fontSize: 13.0
                              );
                            }
                            
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(myColor),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                //side: BorderSide(color: Colors.red)
                              ))),
                          //color: const Color(0xFF390047),
                          child: Text(
                            saveOrUpdateText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                    ),
                    const SizedBox(height: 20,),
                   ],
                )
            );
          }
        ));
  }

  _showDialogConfirmation(){
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirmation de suppression', style: TextStyle(fontSize: 25), textAlign: TextAlign.center,),
            content: const Text("Voulez-vous vraiment supprimer cet enregistrement?", textAlign: TextAlign.center,),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                        Navigator.pop(context);
                    });
                  },
                  child: Text('Non', style: TextStyle(color: myColor),),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      )
                    )
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                        delete(ouvrageISBN, museeNum);
                        Navigator.pop(context);
                    });
                  },
                  child: const Text(
                    'Oui',
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(myColor),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      )
                    )
                  ),
                ),
              ),
            ],
          );
        });
  }


  @override
  void save() {
      Bibliotheque bibliotheque= Bibliotheque(
        isbn: ouvrageISBN,
        numMus: museeNum, 
        dateAchat: dateText,
      );
      if (saveOrUpdateText == 'Enregistrer'){
        bibliothequeBloc.addBibliotheque(bibliotheque);
      }else{
        bibliothequeBloc.updateBibliotheque(bibliotheque);
      }
     
  }

  @override
  void delete(String isbn, int numMus) {
    bibliothequeBloc.deleteBibliotheque(isbn, numMus);
  }

}

abstract class AlertDialogCallback {
  void save();
  void delete(String isbn, int numMus);
}