import 'package:flutter/material.dart';
import 'package:tp_musee/Bloc/MuseeBloc.dart';
import 'package:tp_musee/Bloc/PaysBloc.dart';
import 'package:tp_musee/Models/Musee.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Models/Pays.dart';
import '../main.dart';
import 'MuseeScreen.dart';

class ListeMusees extends StatefulWidget {
  const ListeMusees({ Key? key }) : super(key: key);

  @override
  State<ListeMusees> createState() => _ListeMuseesState();
}

class _ListeMuseesState extends State<ListeMusees> implements AlertDialogCallback {

  TextEditingController txtNomMus = TextEditingController();
  TextEditingController txtNblivres = TextEditingController();
  bool validate_nom = true;
  bool validate_nblivres = true;
  String saveOrUpdateText = '';
  String messageErreur = "";
  bool erreurTextVisible = false;
  String codePays = '';
  final MuseeBloc museeBloc = MuseeBloc();
  final PaysBloc paysBloc = PaysBloc();
  List<Pays> listPays = [];
  late Musee selectedMusee ;
  int numMus = 0;

  @override
  void initState() {
    var list = paysBloc.getPays().then((value){
      listPays = value;
      if(listPays.isNotEmpty){
        codePays = listPays[0].codePays;
        print('Liste des musées ${listPays[0].codePays}');
      }
      
    });
    
    super.initState();

  }
  @override
  void dispose(){
    //DatabaseProvider.databaseProvider.close();
    super.dispose();
  }

  Widget getMuseeWidget(AsyncSnapshot<List<Musee>> snapshot) {
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
                        title: Text(
                                snapshot.data![index].nomMus,
                                style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(snapshot.data![index].numMus.toString(),style: const TextStyle(fontSize: 12.0),),
                                    Text(snapshot.data![index].nblivres.toString(),style: const TextStyle(fontSize: 12.0),),
                                    Text(snapshot.data![index].codePays.toString(),style: const TextStyle(fontSize: 12.0),),
                                  ],
                                ),
                        trailing: Wrap(
                          children: [
                            IconButton(icon: const Icon(
                              Icons.edit, size: 20,
                            ), 
                            onPressed: () {
                              // Navigator.of(context).push(
                              //   MaterialPageRoute(builder: (_)=> MuseeScreen(musee : snapshot.data![index])),).then((val){
                              //     setState(() {
                                    
                              //     });
                              //   }
                              //   );

                              setState(() {
                                selectedMusee = snapshot.data![index];
                                numMus = snapshot.data![index].numMus;
                                txtNomMus.text = snapshot.data![index].nomMus;
                                txtNblivres.text = snapshot.data![index].nblivres.toString();
                                codePays = snapshot.data![index].codePays.toString();
                                saveOrUpdateText = 'Modifier';
                              });
                              _showDialog();
                              },),

                              IconButton(icon: const Icon(
                              Icons.delete, size: 20,
                            ), 
                            onPressed: () {
                              setState(() {
                                selectedMusee = snapshot.data![index];
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
                const Text("Aucun musée n'a encore été ajouté", style: TextStyle(fontSize: 20, fontWeight:FontWeight.bold,)),
                const SizedBox(height: 5,),
                Text("Cliquez sur le bouton du bas pour ajouter un pays", style: TextStyle(color: Colors.grey[600]),),
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
                        child: const Text('Liste des musées', style: TextStyle(fontWeight: FontWeight.bold),)
                      ),
                      
                    ],
                  ),
                ),
          ),
          
          StreamBuilder(
            stream: museeBloc.musees,
            builder: (BuildContext context, AsyncSnapshot<List<Musee>> snapshot) {
              return getMuseeWidget(snapshot);
            }
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: myColor,
        onPressed: () {
          setState(() {
            txtNomMus.text = "";
            txtNblivres.text = "";
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
              title: const Text("Musée"),
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
                          const Text("Pays"),
                          const Spacer(),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: false,
                              items: listPays.map((pays) {
                                return DropdownMenuItem<String>(
                                  value: pays.codePays,
                                  child: SizedBox(
                                    width: 150, //expand here
                                    child: Text(
                                      pays.codePays,
                                      style: const TextStyle(fontSize: 15),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  codePays = newValue.toString();
                                });
                                // onPaysChange(newValue.toString());
                              },
                              hint: const SizedBox(
                                width: 150, //and here
                                child: Text(
                                  "Code du pays",
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              style: TextStyle(color: myColor, decorationColor: Colors.red),
                              value: codePays,
                            ),
                          ),
                        ],
                      ),
                            
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      width: 300,
                      height: 40,
                      child:TextFormField(
                        controller: txtNomMus,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(fontSize: 14,),
                          hintText: 'Nom du musée',
                          errorStyle: const TextStyle(color: Color(0xFFFDA384)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: myColor),
                          ),
                          errorText: validate_nom == false ? 'Le champs est obligatoire ' : null,
                        ),
                        cursorColor: myColor,
                      ),                    
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      width: 300,
                      height: 40,
                      child:
                      TextFormField(
                        controller: txtNblivres,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(fontSize: 14,),
                          hintText: "Nombre de livres",
                          errorText: validate_nblivres == false ? 'Le champs est obligatoire ' : null,
                          errorStyle: const TextStyle(color: Color(0xFFFDA384)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: myColor),
                          ), 
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
                            if (listPays.isNotEmpty){
                              save();
                              Navigator.pop(context);
                            }else{
                              Fluttertoast.showToast(
                                msg: "Veuillez enregistrer d'abord un pays",
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
                        delete(selectedMusee);
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
      txtNomMus.text.trim().isEmpty
          ? validate_nom = false
          : validate_nom = true;
      txtNblivres.text.trim().isEmpty
          ? validate_nblivres = false
          : validate_nblivres = true;
    });
    if (validate_nom && validate_nblivres) {
      try{
        Musee musee = Musee(
          numMus: numMus,
          nomMus: txtNomMus.text.trim(), 
          nblivres:  int.parse(txtNblivres.text.trim()),
          codePays: codePays,
        );
        if (saveOrUpdateText == 'Enregistrer'){
          museeBloc.addMusee(musee);
        }else{
          museeBloc.updateMusee(musee);
        }
      }catch (e){
        print(e);
      }

    }
  }

  @override
  void delete(Musee musee) {
    var data = museeBloc.getMuseeFromOtherTables(musee.numMus).then((value) {
      print('value $value');
      if (value == false){
        museeBloc.deleteMusee(musee);
      }else{
        Fluttertoast.showToast(
          msg: "Désolé, vous ne pouvez pas supprimer ce musée car il est utilisé pour d'autres enregistrement",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 13.0
        );
      }
    });
  }

}

abstract class AlertDialogCallback {
  void save();
  void delete(Musee musee);
}