import 'package:flutter/material.dart';
import 'package:flutter_gym/network_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location/location.dart' as loc;
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // set config
  late GoogleMapController _controller;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Location _location = Location();

  // penampung data
  final List<Marker> _marker = [];
  List<LatLng> polyPoints = [];
  Set<Polyline> polyLines = {};

  // inisial data
  final LatLng _initialcameraposition = const LatLng(-1.6434716, 103.6001137);
  Marker sourceMarker = const Marker(
    markerId: MarkerId('sourceLoc'),
    position: LatLng(-1.6434716, 103.6001137),
    infoWindow: InfoWindow(title: 'My location'),
  );
  double startLat = -1.6434716;
  double startLng = 103.6001137;
  double endLat = -1.616497;
  double endLng = 103.5648949;
  final List<Map> _dataMap = const [
    {'title': 'Apotik A', 'latlng': LatLng(-1.6402679, 103.6003826)},
    {'title': 'Gym B', 'latlng': LatLng(-1.6411038, 103.6004302)},
    {'title': 'Taman C', 'latlng': LatLng(-1.616497, 103.5648949)},
    {'title': 'Kolam Renang', 'latlng': LatLng(-1.6480879, 103.5996136)},
  ];
  var data;

  // inisial data logic
  bool isClickMarker = false;
  double _panelHeightOpen = 0;
  double _panelHeightClosed = 0;

  // primary method
  void _onMapCreated(GoogleMapController cntlr) {
    _controller = cntlr;
    _location.changeSettings(accuracy: loc.LocationAccuracy.high);

    // jika location berubah
    _location.onLocationChanged.listen(
      (l) {
        if (mounted) {
          setState(() {
            startLat = l.latitude!.toDouble();
            startLng = l.longitude!.toDouble();
            sourceMarker = Marker(
              markerId: const MarkerId('sourceLoc'),
              position: LatLng(startLat, startLng),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueMagenta),
              infoWindow: const InfoWindow(title: 'My location'),
            );
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadDataMarker();
  }

  @override
  Widget build(BuildContext context) {
    var maxHeight = MediaQuery.of(context).size.height;
    _panelHeightOpen = maxHeight;
    _panelHeightClosed = maxHeight * 0.4;

    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialcameraposition,
                zoom: 15,
              ),
              mapType: MapType.normal,
              onMapCreated: _onMapCreated,
              markers: {sourceMarker, ..._marker},
              polylines: polyLines,
              myLocationEnabled: true,
              zoomControlsEnabled:
                  false, // btn zoom dimatikan (kita buat custom)
              myLocationButtonEnabled:
                  false, // btn my loc dimatikan (kita buat custom)
              mapToolbarEnabled:
                  false, // btn gmap dimatikan silahkan ubah jadi true klo bingung
              onTap: (_) {
                if (isClickMarker == true) {
                  resetPolyLines();
                  setState(() {
                    isClickMarker = false;
                    _searchController.text = "";
                  });
                }
              },
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 45,
              ),
              color: Colors.white,
              child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: "Search here",
                    contentPadding: EdgeInsets.all(16),
                  ),
                  onChanged: (value) {
                    if (value.isEmpty && isClickMarker == true) {
                      resetPolyLines();
                      setState(() {
                        isClickMarker = false;
                      });
                    }
                  },
                  onSubmitted: (value) {
                    print('SUBMITTED ${value}');
                  }),
            ),
            isClickMarker == true
                ? SlidingUpPanel(
                    snapPoint: 0.5,
                    maxHeight: _panelHeightOpen,
                    minHeight: _panelHeightClosed,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18.0),
                      topRight: Radius.circular(18.0),
                    ),
                    color: Colors.white,
                    panel: ListView(
                      controller: _scrollController,
                      scrollDirection: Axis.vertical,
                      children: <Widget>[
                        const SizedBox(
                          height: 12.0,
                        ),
                        Center(
                          child: Container(
                            width: 30,
                            height: 5,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(12.0))),
                          ),
                        ),
                        const SizedBox(
                          height: 18.0,
                        ),
                        Center(
                          child: Text(
                            "Explore Pittsburgh",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 24.0,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 36.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FloatingActionButton(
                              onPressed: () {
                                resetPolyLines();
                                getJsonData();
                              },
                              child: Icon(Icons.access_time),
                            ),
                            FloatingActionButton(
                              onPressed: () {},
                              child: Icon(Icons.access_time),
                              backgroundColor: Colors.red,
                            ),
                            FloatingActionButton(
                              onPressed: () {},
                              child: Icon(Icons.call_outlined),
                              backgroundColor: Colors.green,
                            ),
                            FloatingActionButton(
                              onPressed: () {},
                              child: Icon(Icons.info_outline),
                              backgroundColor: Colors.amber,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 36.0,
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: <Widget>[
                              Image.network(
                                "https://images.fineartamerica.com/images-medium-large-5/new-pittsburgh-emmanuel-panagiotakis.jpg",
                                height: 120.0,
                                width:
                                    (MediaQuery.of(context).size.width - 48) /
                                            2 -
                                        2,
                                fit: BoxFit.cover,
                              ),
                              Image.network(
                                "https://cdn.pixabay.com/photo/2016/08/11/23/48/pnc-park-1587285_1280.jpg",
                                width:
                                    (MediaQuery.of(context).size.width - 48) /
                                            2 -
                                        2,
                                height: 120.0,
                                fit: BoxFit.cover,
                              ),
                              Image.network(
                                "https://cdn.pixabay.com/photo/2016/08/11/23/48/pnc-park-1587285_1280.jpg",
                                width:
                                    (MediaQuery.of(context).size.width - 48) /
                                            2 -
                                        2,
                                height: 120.0,
                                fit: BoxFit.cover,
                              ),
                              Image.network(
                                "https://cdn.pixabay.com/photo/2016/08/11/23/48/pnc-park-1587285_1280.jpg",
                                width:
                                    (MediaQuery.of(context).size.width - 48) /
                                            2 -
                                        2,
                                height: 120.0,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 36.0,
                        ),
                        Text(
                          'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32. The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from "de Finibus Bonorum et Malorum" by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.',
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  )
                : Positioned(
                    bottom: 50,
                    right: 40,
                    child: FloatingActionButton(
                      onPressed: () {
                        getLocation();
                      },
                      child: const Icon(Icons.my_location),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void resetPolyLines() {
    polyPoints = [];
    polyLines = {};
  }

  void loadDataMarker() {
    for (int i = 0; i < _dataMap.length; i++) {
      _marker.add(
        Marker(
          markerId: MarkerId(i.toString()),
          position: _dataMap[i]['latlng'],
          infoWindow: InfoWindow(
            title: 'This is title ${_dataMap[i]['title']} $i',
          ),
          onTap: () {
            setState(() {
              isClickMarker = true;
              _searchController.text =
                  "This is title ${_dataMap[i]['title']} $i";
            });
            resetPolyLines();
            endLat = _dataMap[i]['latlng'].latitude;
            endLng = _dataMap[i]['latlng'].longitude;
          },
        ),
      );
    }
    setState(() {});
  }

  void getLocation() async {
    var myLocation = await _location.getLocation();
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            myLocation.latitude!.toDouble(),
            myLocation.longitude!.toDouble(),
          ),
          zoom: 15,
        ),
      ),
    );
  }

  void getJsonData() async {
    NetworkHelper network = NetworkHelper(
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
    );

    try {
      data = await network.getData();
      LineString ls =
          LineString(data['features'][0]['geometry']['coordinates']);

      for (int i = 0; i < ls.lineString.length; i++) {
        polyPoints.add(LatLng(ls.lineString[i][1], ls.lineString[i][0]));
      }
      setPolyLines();
    } catch (e) {
      print(e);
    }
  }

  setPolyLines() {
    Polyline polyline = Polyline(
      polylineId: const PolylineId("polyline"),
      color: Colors.lightBlue,
      points: polyPoints,
    );
    polyLines.add(polyline);
    setState(() {});
  }
}

class LineString {
  LineString(this.lineString);
  List<dynamic> lineString;
}
