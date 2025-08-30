import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class LudoGamePage extends StatefulWidget {
  const LudoGamePage({super.key});

  @override
  State<LudoGamePage> createState() => _LudoGamePageState();
}

class _LudoGamePageState extends State<LudoGamePage> {
  final _supabase = Supabase.instance.client;
  int _diceValue = 1;
  bool _isRolling = false;

  Future<void> _rollDice() async {
    setState(() => _isRolling = true);
    
    for (var i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() => _diceValue = (i % 6) + 1);
    }
    
    setState(() {
      _diceValue = Random().nextInt(6) + 1;
      _isRolling = false;
    });
  }

  Future<void> _endGame(bool won) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return;

      if (won) {
        await _supabase
            .from('profiles')
            .update({'points': 30})
            .eq('id', currentUser.id);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(won ? 'You won! +30 points' : 'Game over!')),
      );

      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ludo Game'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _isRolling ? null : _rollDice,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isRolling
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Center(
                        child: Text(
                          '$_diceValue',
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tap dice to roll',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 30),
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: 9,
                itemBuilder: (context, index) => Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Center(
                    child: Text('${index + 1}'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _endGame(true),
                  child: const Text('Win Game'),
                ),
                ElevatedButton(
                  onPressed: () => _endGame(false),
                  child: const Text('Lose Game'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}