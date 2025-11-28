import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/buy_in_section_widget.dart';
import './widgets/game_header_widget.dart';
import './widgets/game_notes_widget.dart';
import './widgets/payment_tracking_widget.dart';
import './widgets/player_card_widget.dart';

class GameDetail extends StatefulWidget {
  const GameDetail({super.key});

  @override
  State<GameDetail> createState() => _GameDetailState();
}

class _GameDetailState extends State<GameDetail> {
  // Game status enum
  GameStatus _gameStatus = GameStatus.scheduled;

  // Mock game data
  final Map<String, dynamic> _gameData = {
    "gameId": "game_001",
    "date": DateTime(2025, 11, 28, 19, 0),
    "location": "Mike's House",
    "address": "123 Poker Lane, Austin, TX 78701",
    "host": "Mike Rodriguez",
    "hostId": "user_001",
    "currentUserId": "user_001", // Current user is the host
    "status": "scheduled",
    "buyInAmount": 100.0,
    "totalPot": 0.0,
  };

  // Mock players data
  List<Map<String, dynamic>> _players = [
    {
      "playerId": "user_001",
      "name": "Mike Rodriguez",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1dc64ab65-1763293842844.png",
      "semanticLabel":
          "Profile photo of Mike Rodriguez with short brown hair and beard",
      "buyIn": 100.0,
      "cashOut": 0.0,
      "currentStack": 100.0,
      "rebuys": 0,
      "netProfit": 0.0,
    },
    {
      "playerId": "user_002",
      "name": "Sarah Chen",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1438c87e8-1763295755784.png",
      "semanticLabel": "Profile photo of Sarah Chen with long black hair",
      "buyIn": 100.0,
      "cashOut": 0.0,
      "currentStack": 100.0,
      "rebuys": 0,
      "netProfit": 0.0,
    },
    {
      "playerId": "user_003",
      "name": "James Wilson",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_13f4b3d4d-1763295780084.png",
      "semanticLabel":
          "Profile photo of James Wilson with glasses and short hair",
      "buyIn": 100.0,
      "cashOut": 0.0,
      "currentStack": 100.0,
      "rebuys": 0,
      "netProfit": 0.0,
    },
  ];

  // Mock payment tracking data
  List<Map<String, dynamic>> _payments = [
    {
      "from": "Sarah Chen",
      "to": "Mike Rodriguez",
      "amount": 50.0,
      "status": "pending",
      "method": "venmo",
    },
  ];

  // Mock game notes
  List<Map<String, dynamic>> _gameNotes = [
    {
      "author": "Mike Rodriguez",
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
      "note": "Don't forget to bring chips and cards!",
    },
  ];

  // Controllers
  final TextEditingController _buyInController = TextEditingController();
  final TextEditingController _cashOutController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateGameStatus();
  }

  @override
  void dispose() {
    _buyInController.dispose();
    _cashOutController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _updateGameStatus() {
    final status = _gameData["status"] as String;
    setState(() {
      if (status == "scheduled") {
        _gameStatus = GameStatus.scheduled;
      } else if (status == "in_progress") {
        _gameStatus = GameStatus.inProgress;
      } else {
        _gameStatus = GameStatus.completed;
      }
    });
  }

  void _startGame() {
    setState(() {
      _gameData["status"] = "in_progress";
      _gameStatus = GameStatus.inProgress;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Game started!')),
    );
  }

  void _endGame() {
    setState(() {
      _gameData["status"] = "completed";
      _gameStatus = GameStatus.completed;
      // Calculate final results
      for (var player in _players) {
        player["netProfit"] =
            (player["cashOut"] as double) - (player["buyIn"] as double);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Game ended! Results calculated.')),
    );
  }

  void _addRebuy(String playerId) {
    showDialog(
      context: context,
      builder: (context) => _buildRebuyDialog(playerId),
    );
  }

  void _cashOutPlayer(String playerId) {
    showDialog(
      context: context,
      builder: (context) => _buildCashOutDialog(playerId),
    );
  }

  void _editStack(String playerId) {
    showDialog(
      context: context,
      builder: (context) => _buildEditStackDialog(playerId),
    );
  }

  void _addLatePlayer() {
    showDialog(
      context: context,
      builder: (context) => _buildAddPlayerDialog(),
    );
  }

  void _sendWhatsAppReminder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('WhatsApp reminder sent to all players!')),
    );
  }

  void _addGameNote() {
    if (_noteController.text.trim().isEmpty) return;

    setState(() {
      _gameNotes.insert(0, {
        "author": "Mike Rodriguez",
        "timestamp": DateTime.now(),
        "note": _noteController.text.trim(),
      });
      _noteController.clear();
    });
  }

  Widget _buildRebuyDialog(String playerId) {
    final theme = Theme.of(context);
    final player = _players.firstWhere((p) => p["playerId"] == playerId);

    return AlertDialog(
      title: Text('Add Rebuy - ${player["name"]}',
          style: theme.textTheme.titleLarge),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _buyInController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Rebuy Amount',
              prefixText: '\$ ',
              hintText: '${_gameData["buyInAmount"]}',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_buyInController.text) ??
                _gameData["buyInAmount"] as double;
            setState(() {
              player["buyIn"] = (player["buyIn"] as double) + amount;
              player["currentStack"] =
                  (player["currentStack"] as double) + amount;
              player["rebuys"] = (player["rebuys"] as int) + 1;
              _buyInController.clear();
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Rebuy added: \$${amount.toStringAsFixed(2)}')),
            );
          },
          child: const Text('Add Rebuy'),
        ),
      ],
    );
  }

  Widget _buildCashOutDialog(String playerId) {
    final theme = Theme.of(context);
    final player = _players.firstWhere((p) => p["playerId"] == playerId);

    return AlertDialog(
      title: Text('Cash Out - ${player["name"]}',
          style: theme.textTheme.titleLarge),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _cashOutController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Cash Out Amount',
              prefixText: '\$ ',
              hintText: '0.00',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_cashOutController.text) ?? 0.0;
            setState(() {
              player["cashOut"] = amount;
              player["currentStack"] = 0.0;
              _cashOutController.clear();
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Cash out recorded: \$${amount.toStringAsFixed(2)}')),
            );
          },
          child: const Text('Cash Out'),
        ),
      ],
    );
  }

  Widget _buildEditStackDialog(String playerId) {
    final theme = Theme.of(context);
    final player = _players.firstWhere((p) => p["playerId"] == playerId);
    final stackController =
        TextEditingController(text: player["currentStack"].toString());

    return AlertDialog(
      title: Text('Edit Stack - ${player["name"]}',
          style: theme.textTheme.titleLarge),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: stackController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Current Stack',
              prefixText: '\$ ',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(stackController.text) ?? 0.0;
            setState(() {
              player["currentStack"] = amount;
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Stack updated: \$${amount.toStringAsFixed(2)}')),
            );
          },
          child: const Text('Update'),
        ),
      ],
    );
  }

  Widget _buildAddPlayerDialog() {
    final theme = Theme.of(context);
    final nameController = TextEditingController();

    return AlertDialog(
      title: Text('Add Late Player', style: theme.textTheme.titleLarge),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Player Name',
              hintText: 'Enter player name',
            ),
          ),
          SizedBox(height: 2.h),
          TextField(
            controller: _buyInController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Buy-in Amount',
              prefixText: '\$ ',
              hintText: '${_gameData["buyInAmount"]}',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.trim().isEmpty) return;

            final amount = double.tryParse(_buyInController.text) ??
                _gameData["buyInAmount"] as double;
            setState(() {
              _players.add({
                "playerId": "user_${DateTime.now().millisecondsSinceEpoch}",
                "name": nameController.text.trim(),
                "avatar":
                    "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
                "semanticLabel":
                    "Profile photo of ${nameController.text.trim()}",
                "buyIn": amount,
                "cashOut": 0.0,
                "currentStack": amount,
                "rebuys": 0,
                "netProfit": 0.0,
              });
              _buyInController.clear();
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('${nameController.text.trim()} added to game')),
            );
          },
          child: const Text('Add Player'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHost = _gameData["currentUserId"] == _gameData["hostId"];

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Game Details',
        showBackButton: true,
        actions: isHost
            ? [
                AppBarAction(
                  icon: Icons.edit,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit game details')),
                    );
                  },
                  tooltip: 'Edit Game',
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game Header
            GameHeaderWidget(
              gameData: _gameData,
              gameStatus: _gameStatus,
            ),

            SizedBox(height: 2.h),

            // Players Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Players (${_players.length})',
                    style: theme.textTheme.titleLarge,
                  ),
                  if (_gameStatus == GameStatus.inProgress)
                    IconButton(
                      icon: CustomIconWidget(
                        iconName: 'person_add',
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      onPressed: _addLatePlayer,
                      tooltip: 'Add Late Player',
                    ),
                ],
              ),
            ),

            SizedBox(height: 1.h),

            // Players List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _players.length,
              itemBuilder: (context, index) {
                final player = _players[index];
                return Slidable(
                  enabled: _gameStatus == GameStatus.inProgress,
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) =>
                            _addRebuy(player["playerId"] as String),
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                        icon: Icons.add_circle,
                        label: 'Rebuy',
                      ),
                      SlidableAction(
                        onPressed: (context) =>
                            _cashOutPlayer(player["playerId"] as String),
                        backgroundColor: theme.colorScheme.tertiary,
                        foregroundColor: theme.colorScheme.onTertiary,
                        icon: Icons.attach_money,
                        label: 'Cash Out',
                      ),
                      SlidableAction(
                        onPressed: (context) =>
                            _editStack(player["playerId"] as String),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                    ],
                  ),
                  child: PlayerCardWidget(
                    player: player,
                    gameStatus: _gameStatus,
                  ),
                );
              },
            ),

            SizedBox(height: 2.h),

            // Buy-in/Cash-out Section
            if (_gameStatus == GameStatus.inProgress)
              BuyInSectionWidget(
                players: _players,
                gameData: _gameData,
              ),

            SizedBox(height: 2.h),

            // Payment Tracking Section
            if (_gameStatus == GameStatus.completed)
              PaymentTrackingWidget(
                payments: _payments,
              ),

            SizedBox(height: 2.h),

            // Game Notes Section
            GameNotesWidget(
              gameNotes: _gameNotes,
              noteController: _noteController,
              onAddNote: _addGameNote,
            ),

            SizedBox(height: 2.h),

            // WhatsApp Reminder Button
            if (_gameStatus == GameStatus.scheduled)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _sendWhatsAppReminder,
                    icon: CustomIconWidget(
                      iconName: 'message',
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    label: const Text('Send WhatsApp Reminder'),
                  ),
                ),
              ),

            SizedBox(height: 10.h),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_gameStatus == GameStatus.scheduled) {
            _startGame();
          } else if (_gameStatus == GameStatus.inProgress) {
            _endGame();
          } else {
            Navigator.pushNamed(context, '/player-stats');
          }
        },
        icon: CustomIconWidget(
          iconName: _gameStatus == GameStatus.scheduled
              ? 'play_arrow'
              : _gameStatus == GameStatus.inProgress
                  ? 'stop'
                  : 'bar_chart',
          color: theme.colorScheme.onPrimary,
          size: 24,
        ),
        label: Text(
          _gameStatus == GameStatus.scheduled
              ? 'Start Game'
              : _gameStatus == GameStatus.inProgress
                  ? 'End Game'
                  : 'View Results',
        ),
      ),
    );
  }
}

enum GameStatus {
  scheduled,
  inProgress,
  completed,
}
