import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Raul Enrique Gonzalez Bondarchuk - App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 10, 107, 13)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var elements = ["elem1", "elem2", "elem3", "elem4", "elem5"];
  var currentIndex = 0;
  var history = <String>[];

  var lastRemovalErrorShown = false; //  para rastrear la visualización del mensaje


  GlobalKey? historyListKey;

  void getNext() {
    history.insert(0, elements[currentIndex]);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    currentIndex = (currentIndex + 1) % elements.length; // Looping index
    notifyListeners();
  }

  void getPrevious() {
    if (history.isNotEmpty) {
      history.removeAt(0);
      var animatedList = historyListKey?.currentState as AnimatedListState?;
      animatedList?.removeItem(0, (context, animation) => Container());
      currentIndex = (currentIndex - 1) % elements.length; // Looping index
      notifyListeners();
    }
  }

  var favorites = <String>[];

  void toggleFavorite([String? element]) {
    element = element ?? elements[currentIndex];
    if (favorites.contains(element)) {
      favorites.remove(element);
    } else {
      favorites.add(element);
    }
    notifyListeners();
  }

  void removeFavorite(String element) {
    favorites.remove(element);
    notifyListeners();
  }
  
  void addElement() {
  var newElement = "New Element ${elements.length + 1}"; // Crea un nuevo elemento
  elements.add(newElement);//Añadir un nuevo elemento a la lista
  notifyListeners(); // Notificar a los oyentes sobre los cambios
  }

  void removeElement(String element, BuildContext context) {
    if (elements.length > 1) {
      elements.remove(element);
      if (currentIndex == elements.length) {
        currentIndex = 0;
      }
      // Restablece la bandera tras una eliminación exitosa
      lastRemovalErrorShown = false;
      notifyListeners();

      // Establece un temporizador de 10 segundos para establecer lastRemovalErrorShown en falso
      Future.delayed(Duration(seconds: 10), () {
        lastRemovalErrorShown = false;
        notifyListeners();
      });
    } else {
      if (!lastRemovalErrorShown) {
        // Mostrar un mensaje sólo si la bandera no fue configurada
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se puede eliminar el último elemento de una lista.'),
          ),
        );
        lastRemovalErrorShown = true; // Establece la bandera después de que se muestra el mensaje
        notifyListeners();

        // Establece un temporizador de 10 segundos para establecer lastRemovalErrorShown en falso
        Future.delayed(Duration(seconds: 10), () {
          lastRemovalErrorShown = false;
          notifyListeners();
        });
      }
    }
  }

  void showAddElementDialog(BuildContext context) {
  TextEditingController controller = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Agregar elemento'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Introduzca el nombre del artículo'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              String newElement = controller.text;
              if (newElement.isNotEmpty) {
                elements.add(newElement);
                notifyListeners();
                Navigator.of(context).pop(); //Cerrar el cuadro de diálogo
              }
            },
            child: Text('Añadir'),
          ),
        ],
      );
    },
  );
}


}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = AllItemsPage(); // Add new case for AllItemsPage
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            return Column(
              children: [
                Expanded(child: mainArea),
                SafeArea(
                  child: BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Inicio',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite),
                        label: 'Favoritos',
                      ),
                      BottomNavigationBarItem( // Add new item for Lista
                        icon: Icon(Icons.list),
                        label: 'Lista',
                      ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                )
              ],
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Inicio'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite),
                        label: Text('Favoritos'),
                      ),
                      NavigationRailDestination( // Add new destination for Lista
                        icon: Icon(Icons.list),
                        label: Text('Lista'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var element = appState.elements[appState.currentIndex];

    IconData icon;
    if (appState.favorites.contains(element)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: HistoryListView(),
          ),
          SizedBox(height: 10),
          BigCard(element: element),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Me Gusta'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Siguiente'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getPrevious();
                },
                child: Text('Anterior'),
              ),
            ],
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.element,
  }) : super(key: key);

  final String element;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSize(
          duration: Duration(milliseconds: 200),
          child: MergeSemantics(
            child: Wrap(
              children: [
                Text(
                  element,
                  style: style.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No hay favoritos'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text('Tienes '
              '${appState.favorites.length} favoritos:'),
        ),
        Expanded(
          child: GridView(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 400 / 80,
            ),
            children: [
              for (var element in appState.favorites)
                ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.delete_outline, semanticLabel: 'Eliminar'),
                    color: theme.colorScheme.primary,
                    onPressed: () {
                      appState.removeFavorite(element);
                    },
                  ),
                  title: Text(
                    element,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class AllItemsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceVariant,
        title: Text('Todos los elementos'),
      ),
      body: ColoredBox(
        color: colorScheme.surfaceVariant,
        child: ListView.builder(
          itemCount: appState.elements.length,
          itemBuilder: (context, index) {
            var element = appState.elements[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              child: ListTile(
                title: Text(
                  element,
                  style: TextStyle(fontSize: 18),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    appState.removeElement(element, context); // Elimina un elemento de la lista
                  },
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          appState.showAddElementDialog(context);
        },
        // ignore: sort_child_properties_last
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 85, 157, 239),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  final _key = GlobalKey();

  static const Gradient _maskingGradient = LinearGradient(
    colors: [Colors.transparent, Colors.black],
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top: 100),
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) {
          final element = appState.history[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  appState.toggleFavorite(element);
                },
                icon: appState.favorites.contains(element)
                    ? Icon(Icons.favorite, size: 12)
                    : SizedBox(),
                label: Text(
                  element,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
