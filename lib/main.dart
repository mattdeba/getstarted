import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final tabs = [
    MyHomePage(),
    PlaceholderWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Matchs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Paris',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Page des paris à implémenter'),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Games App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  Future<List<Game>> fetchGames() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3001/games'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((game) => Game.fromJson(game)).toList();
    } else {
      throw Exception('Failed to load games');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Games App'),
      ),
      body: FutureBuilder<List<Game>>(
        future: fetchGames(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return GameTile(game: snapshot.data![index]);
              },
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }
}

class Game {
  final int id;
  final String homeTeam;
  final String awayTeam;
  final DateTime dateTimeUTC;
  final bool isClosed;
  final int? homeTeamScore;
  final int? awayTeamScore;

  Game({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.dateTimeUTC,
    required this.isClosed,
    this.homeTeamScore,
    this.awayTeamScore,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      homeTeam: json['homeTeam'],
      awayTeam: json['awayTeam'],
      dateTimeUTC: DateTime.parse(json['dateTimeUTC']),
      isClosed: json['isClosed'],
      homeTeamScore: json['homeTeamScore'],
      awayTeamScore: json['awayTeamScore'],
    );
  }
}

class GameTile extends StatelessWidget {
  final Game game;

  GameTile({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            DateFormat('dd/MM/yyyy HH:mm').format(game.dateTimeUTC),
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(color: Colors.grey),
          Text(
            '${game.homeTeam} vs ${game.awayTeam}',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(color: Colors.grey),
          game.isClosed
              ? Text(
            'Score: ${game.homeTeamScore} - ${game.awayTeamScore}',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.red[700],
              fontWeight: FontWeight.bold,
            ),
          )
              : Text(
            'Match not yet played',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
