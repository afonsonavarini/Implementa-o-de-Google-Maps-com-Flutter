import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'api_client.dart';
import 'response_data.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


void main() {
  runApp(const MyApp());
}

class SecondScreen extends StatefulWidget {
  final List<String> text;
  const SecondScreen({Key? key, required this.text}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
     int _likes = 0;

    void _incrementLikes() {
    setState(() {
      _likes++;
    });
  }
  final Map<String, Marker> _markers = {};
  Future<void> _onMapCreated(GoogleMapController controller) async {
    final double longitude = double.parse(widget.text[1]);
    final double latitude = double.parse(widget.text[0]);
    final String nome = widget.text[2];
    final String descricao = widget.text[3];

    setState(() {
      _markers.clear();
      final marker = Marker(
          markerId: MarkerId(nome),
          position: LatLng(latitude, longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          infoWindow: InfoWindow(
            title: nome,
            snippet: 'Pressione para mais detalhes.',
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(nome),
                  content: Text(descricao),
                  actions: [
                    TextButton(
                      child: const Text("Voltar"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        );
        _markers[nome] = marker;
    });
  }


  @override
  Widget build(BuildContext context) {
    
    final double longitude = double.parse(widget.text[1]);
    final double latitude = double.parse(widget.text[0]);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          title: Text(widget.text[2]),
          backgroundColor: Colors.deepPurple,
        ),
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.terrain,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(latitude, longitude),
                zoom: 10,
              ),
              markers: _markers.values.toSet(),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.favorite, color: Colors.white),
              onPressed: () {
                _incrementLikes();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(height: 8),
                          Text('Você deu like!'),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 18),
                          Text('Total de likes: $_likes'),
                        ],
                      ),
                  actions: [
                    TextButton(
                      child: const Text("Voltar"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
                // Adicione aqui a função que será executada quando o botão for pressionado
              },
            ),
          ),
          ]
      )
          ,
        ) ,
    );
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Localizações'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: _buildBody(context),
    );
  }
  

  FutureBuilder<ResponseData> _buildBody(BuildContext context) {
    final client = ApiClient(Dio(BaseOptions(contentType: "application/json")));
    return FutureBuilder<ResponseData>(
      future: client.getEndpoint(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {

          final ResponseData? posts = snapshot.data;

          

          return posts == null ? const Text("Erro ao carregar as localizações.") : _buildListView(context, posts);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  List<String>_positions = [];

  void _setPositions(List<String> newPositions) {
    setState(() {
      _positions = newPositions;
    });
  }

  void _sendDataToSecondScreen(BuildContext context) {
    List<String> textToSend = _positions;
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SecondScreen(text: textToSend),
        ));
  }

  
  Widget _buildListView(BuildContext context, ResponseData posts) {
    return
      ListView.builder(
        itemBuilder: (context,index){
        return Card(
          child: ListTile(
            leading: const Icon(Icons.location_on, color: Colors.deepPurple ,size: 50),
            title: Text(posts.data[index]['name'],style: const TextStyle(fontSize: 20),),
            subtitle: Text(posts.data[index]['location']),
            onTap: () {
               _setPositions([posts.data[index]['long'], posts.data[index]['lat'], posts.data[index]['name'], posts.data[index]['description']]);
               _sendDataToSecondScreen(context);
            },
          ),
        );
      },itemCount: posts.data.length,
      );
  }

}
