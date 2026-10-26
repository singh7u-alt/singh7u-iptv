import 'package:flutter/material.dart';
import '../model/channel.dart';
import 'player.dart';

/// One channel row (shared by search results and category screen).
class ChannelTile extends StatelessWidget {
  final Channel channel;
  final bool autofocus;

  const ChannelTile({Key? key, required this.channel, this.autofocus = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      autofocus: autofocus,
      focusColor: Colors.white24,
      leading: Image.network(
        channel.logoUrl,
        width: 50,
        height: 50,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/images/tv-icon.png',
          width: 50,
          height: 50,
          fit: BoxFit.contain,
        ),
      ),
      title: Text(channel.name),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Player(channel: channel)),
      ),
    );
  }
}

/// Channels inside one category.
class CategoryChannels extends StatelessWidget {
  final String category;
  final List<Channel> channels;

  const CategoryChannels(
      {Key? key, required this.category, required this.channels})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$category (${channels.length})')),
      body: ListView.builder(
        itemCount: channels.length,
        itemBuilder: (context, i) =>
            ChannelTile(channel: channels[i], autofocus: i == 0),
      ),
    );
  }
}
