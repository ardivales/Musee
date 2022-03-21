import 'package:flutter/material.dart';
import 'package:tp_musee/Bloc/PaysBloc.dart';
import 'package:tp_musee/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Models/Pays.dart';

class ListePays extends StatefulWidget {

  const ListePays({ Key? key }) : super(key: key);
  @override
  State<ListePays> createState() => _ListePaysState();
}

class _ListePaysState extends State<ListePays> implements AlertDialogCallback{
  bool isLoading = false;
  TextEditingController txtCodePays = TextEditingController();
  TextEditingController txtNbHabitant = TextEditingController();
  bool validate_code = true;
  bool validate_nbhabitant = true;
  bool enabledTxtCodePays = true;
  bool btnSupprimerVisibility = false;
  String saveOrUpdateText = '';
  String messageErreur = "";
  bool erreurTextVisible = false;
  late Pays selectedPays;

  final PaysBloc paysBloc = PaysBloc();

  @override
  void initState() {
    super.initState();

  }
  @override
  void dispose(){
    //DatabaseProvider.databaseProvider.close();
    super.dispose();
  }

  Widget getPaysWidget(AsyncSnapshot<List<Pays>> snapshot) {
    if (snapshot.hasData) {
      return snapshot.data!.isNotEmpty
        ? Expanded(
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: snapshot.data!.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext ctxt, int index) {
                return Padding(
                  padding: const EdgeInsets.all(0),
                  child: InkWell(
                    highlightColor: myColor,
                    onTap: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(builder: (_)=> PaysScreen(pays : snapshot.data![index])),);
                        //.then((val)=>getPays());
                        
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: ListTile(
                            title: Text(
                                    snapshot.data![index].codePays,
                                    style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
                                   ),
                                   subtitle: Text(snapshot.data![index].nbhabitant.toString(),style: const TextStyle(fontSize: 12.0),),
                            trailing: Wrap(
                              children: [
                                IconButton(icon: const Icon(
                                  Icons.edit, size: 20,
                                ), 
                                onPressed: () { 
                                  setState(() {
                                    selectedPays = snapshot.data![index];
                                    txtCodePays.text = snapshot.data![index].codePays;
                                    txtNbHabitant.text = snapshot.data![index].nbhabitant.toString();
                                    saveOrUpdateText = 'Modifier';
                                    enabledTxtCodePays = false;
                                    btnSupprimerVisibility = true;
                                  });
                                  _showDialog();
                                 },),

                                 IconButton(icon: const Icon(
                                  Icons.delete, size: 20,
                                ), 
                                onPressed: () {
                                  setState(() {
                                    selectedPays = snapshot.data![index];
                                  });
                                  _showDialogConfirmation();
                                },),
                              ],
                            ),
                          ),
                              
                        ),
                        const Divider()
                      ],
                    ),
                  ),
                );
              },
            ),
        )
        : Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Aucun pays n'a encore été ajouté", style: TextStyle(fontSize: 20, fontWeight:FontWeight.bold,)),
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
                        child: const Text('Liste des pays', style: TextStyle(fontWeight: FontWeight.bold),)
                      ),
                      
                    ],
                  ),
                ),
          ),
          
          StreamBuilder(
            stream: paysBloc.pays,
            builder: (BuildContext context, AsyncSnapshot<List<Pays>> snapshot) {
              return getPaysWidget(snapshot);
            }
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: myColor,
        onPressed: () {
          setState(() {
            txtCodePays.text = "";
            txtNbHabitant.text = "";
            saveOrUpdateText = 'Enregistrer';
            enabledTxtCodePays = true;
            btnSupprimerVisibility = false;
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
        builder: (context) => AlertDialog(
              title: const Text("Pays"),
              content: Center(
        child: StatefulBuilder(
          builder: (context, snapshot) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                SizedBox(
                  width: 300,
                  height: 40,
                  child:TextFormField(
                    enabled: enabledTxtCodePays,
                    controller: txtCodePays,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(fontSize: 14,),
                      hintText: 'Code du pays',
                      errorStyle: const TextStyle(color: Color(0xFFFDA384)),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: myColor),
                      ),
                      errorText: validate_code == false ? 'Le champs est obligatoire ' : null,
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
                    controller: txtNbHabitant,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(fontSize: 14,),
                      hintText: "Nombre d'habitants",
                      errorText: validate_nbhabitant == false ? 'Le champs est obligatoire ' : null,
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
                        save();
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(myColor),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ))),
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
            );
          }
        ),
      )
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
                        delete(selectedPays);
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
      txtCodePays.text.trim().isEmpty
          ? validate_code = false
          : validate_code = true;
      txtNbHabitant.text.trim().isEmpty
          ? validate_nbhabitant = false
          : validate_nbhabitant = true;
    });
    if (validate_code && validate_nbhabitant) {
      Pays pays = Pays(
        codePays: txtCodePays.text.trim(), 
        nbhabitant: int.parse(txtNbHabitant.text.trim()),
      );
      if (saveOrUpdateText == 'Enregistrer'){
        paysBloc.addPays(pays);
      }else{
        paysBloc.updatePays(pays);
      }
     
    }
  }

  @override
  void delete(Pays pays) {
    var data = paysBloc.getPaysFromOtherTables(pays.codePays).then((value) {
      print('value $value');
      if (value == false){
        paysBloc.deletePays(pays);
      }else{
        Fluttertoast.showToast(
          msg: "Désolé, vous ne pouvez pas supprimer ce pays car il est utilisé pour d'autres enregistrement",
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
  void delete(Pays pays);
}