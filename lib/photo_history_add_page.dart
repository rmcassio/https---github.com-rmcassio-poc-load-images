// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:http/http.dart' as http;

const Color kDarkGray = Color(0xFFA3A3A3);
const Color kLightGray = Color(0xFFF1F0F5);

class PhotosHistoryAddPage extends StatelessWidget {
  const PhotosHistoryAddPage({super.key});

  @override
  Widget build(BuildContext context) => const ImagePickerWidget();
}

enum PageStatus { loading, error, loaded }

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({super.key});

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final _photos = <Image>[];
  Image? image;
  PageStatus _pageStatus = PageStatus.loaded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar images')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _photos.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      child: _buildAddPhoto(),
                    );
                  }
                  var image = _photos[index - 1];
                  return Stack(
                    children: <Widget>[
                      InkWell(
                        onTap: () => pickImage(image),
                        child: Container(margin: const EdgeInsets.all(2), height: 100, width: 100, color: kLightGray, child: image),
                      ),
                    ],
                  );
                },
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Visibility(
                  visible: image != null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Column(
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: image ?? Container(),
                          ),
                          const Text(
                            'Miniatura',
                            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          SizedBox(
                            width: 300,
                            height: 300,
                            child: image ?? Container(),
                          ),
                          const Text(
                            'Normal',
                            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 500,
                            height: 500,
                            child: image ?? Container(),
                          ),
                          const Text(
                            'Grande',
                            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InkWell _buildAddPhoto() {
    if (_pageStatus == PageStatus.loading) {
      return InkWell(
        onTap: () {},
        child: Container(
          height: 100,
          width: 100,
          color: kDarkGray,
          child: const Center(child: Text('Aguarde..')),
        ),
      );
    } else {
      return InkWell(
        onTap: () => _onAddPhotoClicked(context),
        child: Container(
          height: 100,
          width: 100,
          color: kDarkGray,
          child: const Center(
            child: Icon(
              Icons.add_to_photos,
              color: kLightGray,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _onAddPhotoClicked(context) async {
    String? url;
    setState(() {
      _pageStatus = PageStatus.loading;
    });

    final result = await showDialog(
      barrierColor: Colors.white,
      context: context,
      builder: (context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final image = await ImagePickerWeb.getImageAsWidget();

                    if (image != null) {
                      setState(() {
                        _photos.add(image);
                        _pageStatus = PageStatus.loaded;
                      });
                    } else {
                      setState(() {
                        _pageStatus = PageStatus.loaded;
                      });
                    }
                  },
                  child: const Text('Selecionar imagem local')),
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          actions: [
                            const Center(child: Text('Insira a URL:', textAlign: TextAlign.left)),
                            TextField(
                              onSubmitted: (value) {
                                setState(() {
                                  url = value;
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                    if (url != null) {
                      String imageUrl = url!;
                      Uint8List response = await http.get(Uri.parse(imageUrl)).then((value) => value.bodyBytes);

                      if (response.isNotEmpty) {
                        setState(() {
                          _photos.add(Image.memory(response));
                        });
                      }
                    }
                  },
                  child: const Text('Selecionar imagem via url')),
            ],
          ),
        );
      },
    ) as bool?;

    if (result == null || !result) {
      setState(() {
        _pageStatus = PageStatus.loaded;
      });
    }
  }

  Future<void> pickImage(Image imageSelected) async {
    showModalBottomSheet(
      constraints: const BoxConstraints(
        maxHeight: 200,
        maxWidth: 400,
        minWidth: 400,
      ),
      context: context,
      builder: (context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    image = imageSelected;
                  });
                },
                child: const Text(
                  'Visualizar imagem',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                )),
            TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() {
                    _photos.remove(imageSelected);
                    if (image == imageSelected) {
                      image = null;
                    }
                  });
                },
                child: const Text(
                  'Remover imagem',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                )),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _photos.remove(imageSelected);
                    if (image == imageSelected) {
                      image = null;
                    }
                  });

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Ok!'),
                        content: const Text('Upload finalizado com sucesso!'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ok')),
                        ],
                      );
                    },
                  );
                },
                child: const Text(
                  'Fazer upload da imagem',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                )),
          ],
        );
      },
    );
  }
}
