import 'package:flutter/material.dart';
import 'package:tp_musee/Bloc/MomentBloc.dart';
import 'package:tp_musee/Bloc/VisiterBloc.dart';
import 'package:tp_musee/Models/Moment.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Bloc/MuseeBloc.dart';
import '../Models/Musee.dart';
import '../Models/Visiter.dart';
import '../main.dart';

class ListeVisites extends StatefulWidget {
  const ListeVisites({ Key? key }) : super(key: key);

  @override
  State<ListeVisites> createState() => _ListeVisitesState();
}

class _ListeVisitesState extends State<ListeVisites> implements AlertDialogCallback{
  TextEditingController txtNbVisiteurs = TextEditingController();
  bool validate_nbVisiteurs = true;
  String saveOrUpdateText = '';
  int museeNum = 0;
  String museeNom = '';
  Musee? museeSelected;
  final VisiterBloc visiterBloc= VisiterBloc();
  final MomentBloc momentBloc = MomentBloc();
  final MuseeBloc museeBloc = MuseeBloc();
  DateTime selectedDate = DateTime.now();
  String dateText = "";
  List<Musee> listMusee = [];
  List<Moment> listMoment = [];
  late dynamic selectedVisite ;
  String jour = "";
  bool enableMusee = true;
  bool enableMoment = true;

  @override
  void initState() {
    var listMu = museeBloc.getMusees().then((value){
      listMusee = value;
      if (listMusee.isNotEmpty){
        museeSelected = listMusee[0];
      museeNum = listMusee[0].numMus;
      museeNom = listMusee[0].nomMus;
      }
      print('Liste des Musées $value');
    });
    
    // var listMo = momentBloc.getMoment().then((value){
    //   listMoment = value;
    //   jour = listMoment[0].jour;
      
    // });

    super.initState();

  }
  @override
  void dispose(){
    super.dispose();
  }

  

  Widget getVisiteWidget(AsyncSnapshot<List> snapshot) {
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
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      elevation: 0,
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
                              Text(snapshot.data![index]['jour'].toString(), style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),),
                              Visibility(
                                visible: false,
                                child: Text(snapshot.data![index]['numMus'].toString(),
                                  style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(height: 5,)
                            ],
                          ),
                          subtitle: Text(snapshot.data![index]['nbvisiteurs'].toString(),style: const TextStyle(fontSize: 12.0),),
                          trailing: Wrap(
                            children: [
                              IconButton(icon: const Icon(
                                Icons.edit, size: 20,
                              ), 
                              onPressed: () {
                  
                                setState(() {
                                  selectedVisite = snapshot.data![index];
                                  txtNbVisiteurs.text = snapshot.data![index]['nbvisiteurs'].toString();
                                  museeNum = int.parse(snapshot.data![index]['numMus'].toString());
                                  jour = snapshot.data![index]['jour'].toString();
                                  enableMoment = false;
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
                                  selectedVisite = snapshot.data![index];
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
                ),
              );
            },
          )
        : Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Aucune visite n'a encore été enregistrée", style: TextStyle(fontSize: 20, fontWeight:FontWeight.bold,)),
                const SizedBox(height: 5,),
                Text("Cliquez sur le bouton du bas pour enregistrer une visite", style: TextStyle(color: Colors.grey[600]),),
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
                        child: const Text('Liste des visites', style: TextStyle(fontWeight: FontWeight.bold),)
                      ),
                      
                    ],
                  ),
                ),
          ),
          
          StreamBuilder(
            stream: visiterBloc.visites,
            builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
              return getVisiteWidget(snapshot);
            }
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: myColor,
        onPressed: () {
          setState(() {
            txtNbVisiteurs.text = "";
            enableMoment = true;
            enableMusee = true;
            saveOrUpdateText = 'Enregistrer';
            // enabledTxt = true;
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
              title: const Text("Visites"),
              content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                          const Text("Moment"),
                          const Spacer(),

                          //Date
                          Text(dateText,
                            style: const TextStyle(color: Colors.black),
                            
                          ),
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
                    const SizedBox(height: 10,),
                    SizedBox(
                      width: 300,
                      height: 40,
                      child:TextFormField(
                        controller: txtNbVisiteurs,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(fontSize: 14,),
                          hintText: 'Nombre de visiteurs',
                          errorStyle: const TextStyle(color: Color(0xFFFDA384)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: myColor),
                          ),
                          errorText: validate_nbVisiteurs == false ? 'Le champs est obligatoire ' : null,
                        ),
                        cursorColor: myColor,
                      ),                    
                    ),
                    const SizedBox(height: 20,),
                    SizedBox(
                      width: 300,
                      height: 40,
                      child: ElevatedButton(
                          onPressed: () async {
                            if (listMusee.isNotEmpty){
                              save();
                              Navigator.pop(context);
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
                        delete(jour, museeNum);
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
    setState(() {
      txtNbVisiteurs.text.trim().isEmpty
          ? validate_nbVisiteurs = false
          : validate_nbVisiteurs = true;
    });
    if (validate_nbVisiteurs) {
      Visiter visiter= Visiter(
        jour: dateText,
        numMus: museeNum, 
        nbvisiteurs: int.parse(txtNbVisiteurs.text.trim()),
      );

      //Enregistrer le moment
      Moment moment = Moment(jour: dateText);
      momentBloc.addMoment(moment);
      
      if (saveOrUpdateText == 'Enregistrer'){
        visiterBloc.addVisite(visiter);
      }else{
        print(visiter.jour);
        visiterBloc.updateVisite(visiter);
      }
    }
     
  }

  @override
  void delete(String jour, int numMus) {
    visiterBloc.deleteVisite(jour, numMus);
  }
}

abstract class AlertDialogCallback {
  void save();
  void delete(String jour, int numMus);
}