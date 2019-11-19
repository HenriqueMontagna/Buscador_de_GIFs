import 'dart:async' as prefix0;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'dart:async';
import 'package:transparent_image/transparent_image.dart';

import 'gif_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset;

  Future<Map> _getGifs() async {
    http.Response response;
    if (_search == null)
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=9VIEFrc21Wlm0BHl30FIcCGqiDFovLq2&limit=20&rating=G");
    else
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=9VIEFrc21Wlm0BHl30FIcCGqiDFovLq2&q=$_search&limit=19&offset=$_offset&rating=G&lang=pt");
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    _getGifs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.network(
            "https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif"),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Divider(),
          TextField(
            decoration: InputDecoration(
              labelText: "Pesquise Aqui",
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              border: OutlineInputBorder(),
            ),
            style: TextStyle(color: Colors.white, fontSize: 18.0),
            textAlign: TextAlign.center,
            onSubmitted: (text) {
              setState(() {
                _search = text;
                _offset = 0;
              });
            },
          ),
          Divider(),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Container(
                        alignment: Alignment.center,
                        child: Text("Serviço Indisponível"),
                      );
                    } else
                      return _createGifTable(context, snapshot);
                }
              },
            ),
          )
        ],
      ),
    );
  }

  int _getCount(List data) {
    if (_search == null || _search.isEmpty) {
      return data.length;
    } else if (_offset >= 19) {
      return data.length + 2;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          if (_search == null || index < snapshot.data["data"].length) {
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: snapshot.data["data"][index]["images"]["fixed_height"]
                      ["url"],
                  height: 300.0,
                  fit: BoxFit.cover),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          GifPage(snapshot.data["data"][index])),
                );
              },
              onLongPress: () {
                Share.share(snapshot.data["data"][index]["images"]
                    ["fixed_height"]["url"]);
              },
            );
          } else if (_search != null && index == 19) {
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 70.0,
                    ),
                    Text(
                      "Carregar mais...",
                      style: TextStyle(color: Colors.white, fontSize: 22.0),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    _offset += 19;
                  });
                },
              ),
            );
          } else {
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 70.0,
                    ),
                    Text(
                      "Voltar",
                      style: TextStyle(color: Colors.white, fontSize: 22.0),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    _offset -= 19;
                  });
                },
              ),
            );
          }
        });
  }
}
