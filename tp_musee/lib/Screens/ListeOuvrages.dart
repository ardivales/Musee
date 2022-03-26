import 'package:flutter/material.dart';
import 'package:tp_musee/Bloc/OuvrageBloc.dart';
import 'package:tp_musee/Dao/OuvrageDao.dart';
import 'package:tp_musee/Models/Ouvrage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Bloc/PaysBloc.dart';
import '../Models/Pays.dart';
import '../main.dart';

class ListeOuvrages extends StatefulWidget {
  const ListeOuvrages({ Key? key }) : super(key: key);

  @override
  State<ListeOuvrages> createState() => _ListeOuvragesState();
}

class _ListeOuvragesState extends State<ListeOuvrages> {
  TextEditingController txtISBN = TextEditingController();
  TextEditingController txtNbPage = TextEditingController();
  TextEditingController txtTitre = TextEditingController();
  bool validate_isbn = true;
  bool validate_nbpage = true;
  bool validate_titre = true;
  bool enabledTxt = true;
  String saveOrUpdateText = '';
  String messageErreur = "";
  bool erreurTextVisible = false;
  String codePays = '';
  final OuvrageBloc ouvrageBloc= OuvrageBloc();
  final PaysBloc paysBloc = PaysBloc();
  List<Pays> listPays = [];
  late Ouvrage selectedOuvrage ;

  @override
  void initState() {
    var list = paysBloc.getPays().then((value){
      listPays = value;
      codePays = listPays[0].codePays;
      print('Liste des ouvrages ${listPays[0].codePays}');
    });
    
    super.initState();

  }
  @override
  void dispose(){
    //DatabaseProvider.databaseProvider.close();
    super.dispose();
  }

  Widget getOuvrageWidget(AsyncSnapshot<List<Ouvrage>> snapshot) {
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
                                snapshot.data![index].titre,
                                style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(snapshot.data![index].isbn.toString(),style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),),
                                    Text(snapshot.data![index].nbPage.toString(),style: const TextStyle(fontSize: 12.0),),
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
                                selectedOuvrage = snapshot.data![index];
                                txtTitre.text = snapshot.data![index].titre;
                                txtNbPage.text = snapshot.data![index].nbPage.toString();
                                txtISBN.text = snapshot.data![index].isbn.toString();
                                codePays = snapshot.data![index].codePays.toString();
                                saveOrUpdateText = 'Modifier';
                                enabledTxt = false;
                              });
                              _showDialog();
                              },),

                              IconButton(icon: const Icon(
                              Icons.delete, size: 20,
                            ), 
                            onPressed: () {
                              setState(() {
                                selectedOuvrage = snapshot.data![index];
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
                const Text("Aucun ouvrage n'a encore été ajouté", style: TextStyle(fontSize: 20, fontWeight:FontWeight.bold,)),
                const SizedBox(height: 5,),
                Text("Cliquez sur le bouton du bas pour ajouter un ouvrage", style: TextStyle(color: Colors.grey[600]),),
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
                        child: const Text('Liste des ouvrages', style: TextStyle(fontWeight: FontWeight.bold),)
                      ),
                      
                    ],
                  ),
                ),
          ),
          
          StreamBuilder(
            stream: ouvrageBloc.ouvrage,
            builder: (BuildContext context, AsyncSnapshot<List<Ouvrage>> snapshot) {
              return getOuvrageWidget(snapshot);
            }
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: myColor,
        onPressed: () {
          setState(() {
            txtISBN.text = "";
            txtNbPage.text = "";
            txtTitre.text = "";
            saveOrUpdateText = 'Enregistrer';
            enabledTxt = true;
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
              title: const Text("Ouvrage"),
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
                        enabled: enabledTxt,
                        controller: txtISBN,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(fontSize: 14,),
                          hintText: 'ISBN',
                          errorStyle: const TextStyle(color: Color(0xFFFDA384)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: myColor),
                          ),
                          errorText: validate_isbn == false ? 'Le champs est obligatoire ' : null,
                        ),
                        cursorColor: myColor,
                      ),                    
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      width: 300,
                      height: 40,
                      child:TextFormField(
                        controller: txtTitre,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(fontSize: 14,),
                          hintText: 'Titre',
                          errorStyle: const TextStyle(color: Color(0xFFFDA384)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: myColor),
                          ),
                          errorText: validate_titre == false ? 'Le champs est obligatoire ' : null,
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
                        controller: txtNbPage,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(fontSize: 14,),
                          hintText: "Nombre de pages",
                          errorText: validate_nbpage == false ? 'Le champs est obligatoire ' : null,
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
                            setState(() {
                              txtISBN.text.trim().isEmpty
                                  ? validate_isbn = false
                                  : validate_isbn = true;
                              txtNbPage.text.trim().isEmpty
                                  ? validate_nbpage = false
                                  : validate_nbpage = true;
                              txtTitre.text.trim().isEmpty
                                  ? validate_titre = false
                                  : validate_titre = true;
                            });
                            if (validate_isbn && validate_nbpage && validate_titre) {
                              save();
                              Navigator.pop(context);
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
                        delete(selectedOuvrage);
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
    
      Ouvrage ouvrage= Ouvrage(
        isbn: txtISBN.text.trim(),
        titre: txtTitre.text.trim(), 
        nbPage:  int.parse(txtNbPage.text.trim()),
        codePays: codePays,
      );
      if (saveOrUpdateText == 'Enregistrer'){
        ouvrageBloc.addOuvrage(ouvrage);
      }else{
        ouvrageBloc.updateOuvrage(ouvrage);
      }
     
    
  }

  @override
  void delete(Ouvrage ouvrage) {
    var data = ouvrageBloc.getOuvrageFromOtherTables(ouvrage.isbn).then((value) {
      print('value $value');
      if (value == false){
        ouvrageBloc.deleteOuvrage(ouvrage);
      }else{
        Fluttertoast.showToast(
          msg: "Désolé, vous ne pouvez pas supprimer cet ouvrage car il est utilisé pour d'autres enregistrement",
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
  void delete(Ouvrage ouvrage);
}