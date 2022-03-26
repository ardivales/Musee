import 'package:flutter/material.dart';
import 'package:tp_musee/Screens/ListeBibliotheques.dart';
import 'package:tp_musee/Screens/ListeMusees.dart';
import 'package:tp_musee/Screens/ListePays.dart';
import 'package:tp_musee/Screens/ListeVisites.dart';
import 'package:tp_musee/main.dart';

import '../Database/DatabaseProvider.dart';
import 'ListeOuvrages.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var currentPage = DrawerSections.listeVisites;
  
  @override
  void initState() {
    DatabaseProvider museeDatabase= DatabaseProvider.databaseProvider;
    super.initState();
  }

  toggleDrawer() async {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openEndDrawer();
    } else {
      _scaffoldKey.currentState!.openDrawer();
    }
  }
  @override
  Widget build(BuildContext context) {
    var container;
    if (currentPage == DrawerSections.listePays){
      container = const ListePays();
    }else if (currentPage == DrawerSections.listeMusees){
      container = const ListeMusees();
    }else if (currentPage == DrawerSections.listeOuvrages){
      container = const ListeOuvrages();
    }else if (currentPage == DrawerSections.listeBibliotheques){
      container = const ListeBibliotheques();
    }else if (currentPage == DrawerSections.listeVisites){
      container = const ListeVisites();
    }

    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(backgroundColor: myColor,
          leading: Builder(
            builder: (context) => // Ensure Scaffold is in context
                IconButton(
                  icon: const Icon(
                    Icons.menu,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  }
                ),
          ),
      ),
        drawer: Drawer(
          child: Container(
            padding: const EdgeInsets.only(top: 40, left: 10),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    // Important: Remove any padding from the ListView.
                    padding: EdgeInsets.zero,
                    children: [
                      MyDrawerList(),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: Column(
                        children: const [
                      Divider(),
                      Text('Made by Aurlic & Emile')
                        ],
                      )
                  ),
                )
              ],
            ),
          ),
        ),
        body: container,
      ),
    );
  }

  Widget MyDrawerList() {
    return Container(
      padding: const EdgeInsets.only(
        top: 15,
      ),
      child: Column(
        // shows the list of menu drawer
        children: [
          menuItem(1, "Pays",
              currentPage == DrawerSections.listePays ? true : false),
          Divider(),
          menuItem(2, "Musées",
              currentPage == DrawerSections.listeMusees ? true : false),
          Divider(),
          menuItem(3, "Ouvrages",
              currentPage == DrawerSections.listeOuvrages ? true : false),
          Divider(),
          menuItem(4, "Bibliothèques",
              currentPage == DrawerSections.listeBibliotheques ? true : false),
          Divider(),
          menuItem(5, "Visites",
              currentPage == DrawerSections.listeVisites ? true : false),
        ],
      ),
    );
  }

  Widget menuItem(int id, String title, bool selected){
    return Material(
      child: InkWell(
        onTap: (){
          toggleDrawer();
          setState(() {
            if (id == 1){
              currentPage = DrawerSections.listePays;
            }else if (id == 2){
              currentPage = DrawerSections.listeMusees;
            }else if (id == 3){
              currentPage = DrawerSections.listeOuvrages;
            }else if (id == 4){
              currentPage = DrawerSections.listeBibliotheques;
            }else if (id == 5){
              currentPage = DrawerSections.listeVisites;
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

enum DrawerSections{
  listePays,
  listeBibliotheques,
  listeOuvrages,
  listeMusees,
  listeVisites,
}