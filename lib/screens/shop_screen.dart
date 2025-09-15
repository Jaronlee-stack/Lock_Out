import 'package:flutter/material.dart';
import 'package:focuspal/models/player.dart';
import 'package:focuspal/widgets/background.dart';

class RewardsShop extends StatefulWidget {
  final Player player;
  const RewardsShop({Key? key, required this.player}) : super(key: key);

  @override
  _RewardsShopState createState() => _RewardsShopState();
}

class _RewardsShopState extends State<RewardsShop> {
  late Player player;

  final List<Map<String, dynamic>> shopItems = [
    {'name': 'Cool Hat', 'price': 1, 'icon': "assets/images/hat.png"},
    {'name': 'Black Tie', 'price': 10, 'icon': "assets/images/collar.png"},
    {'name': 'Magic Potion', 'price': 15, 'icon': "assets/images/potion.png"},
    {'name': 'Rainbow Fur', 'price': 20, 'icon': "assets/images/rainbow.png"}
  ];

  @override
  void initState() {
    super.initState();
    player = widget.player;
  }

  void _buyItem(String itemName, int price) async {
    if (player.spendCoins(price)) {
      setState(() {
        player.unlockedRewards.add(itemName);
      });
      await player.save();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text("Purchased $itemName!"), duration: Duration(seconds: 1)),
        );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text("Not enough coins!"), duration: Duration(seconds: 1)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            "Coins: ${player.coins}",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: shopItems.map((item) {
                final itemName = item['name'];
                final price = item['price'];
                final alreadyOwned = player.unlockedRewards.contains(itemName);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Image.asset(item['icon'], width: 40, height: 40),
                    title: Text(itemName),
                    subtitle: Text("Price: $price coins"),
                    trailing: alreadyOwned
                        ? const Icon(Icons.check, color: Colors.green)
                        : ElevatedButton(
                            onPressed: () => _buyItem(itemName, price),
                            child: const Text("Buy"),
                          ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
