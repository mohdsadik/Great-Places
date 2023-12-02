import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/place.dart';
import 'package:provider/provider.dart';
import '../providers/great_places.dart';
import '../widgets/image_input.dart';
import '../widgets/location_input.dart';

class AddPlaceScreen extends StatefulWidget {
  static const routeName = '/add-place';

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _titleController = TextEditingController();
  String _imageAssetPath = ''; // Change this to your asset path
  late PlaceLocation _pickedLocation;

  void _selectImage(String imageAssetPath) {
    setState(() {
      _imageAssetPath = imageAssetPath;
    });
  }

  void _selectPlace(double lat, double lng) {
    _pickedLocation = PlaceLocation(
      latitude: lat,
      longitude: lng,
    );
  }

  void _savePlace() async {
    if (_titleController.text.isEmpty || _pickedLocation == null) {
      return;
    }

    final ByteData bytecode = await rootBundle.load(_imageAssetPath);
    final List<int> int8List = bytecode.buffer.asUint8List();
    final Uint8List uint8list = Uint8List.fromList(int8List);
    final File file = await _write(uint8list, _imageAssetPath);

    Provider.of<GreatPlaces>(context, listen: false)
        .addPlace(_titleController.text, file, _pickedLocation);
    Navigator.of(context).pop();
  }

  Future<File> _write(Uint8List uint8list, String filename) async {
    final temp = await getTemporaryDirectory();
    final file = File('${temp.path}/$filename');
    await file.writeAsBytes(uint8list);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add a new place')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(labelText: 'Title'),
                      controller: _titleController,
                    ),
                    SizedBox(height: 10),
                    ImageInput(_selectImage),
                    SizedBox(height: 10),
                    LocationInput(_selectPlace),
                  ],
                ),
              ),
            ),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text('Add Place'),
            onPressed: _savePlace,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).hintColor,
              elevation: 0,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
