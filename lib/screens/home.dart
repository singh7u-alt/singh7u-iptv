import 'dart:async';

import 'package:flutter/material.dart';
import '../model/channel.dart';
import '../provider/channels_provider.dart';
import 'category_channels.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Channel> filteredChannels = [];
  TextEditingController searchController = TextEditingController();
  final ChannelsProvider channelsProvider = ChannelsProvider();
  bool _isLoading = true;
  String _query = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final data = await channelsProvider.fetchM3UFile();
      if (!mounted) return;
      setState(() {
        filteredChannels = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('There was a problem finding the data')));
    }
  }

  void filterChannels(String query) {
    setState(() => _query = query.trim());
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      final data = channelsProvider.filterChannels(query);
      if (mounted) setState(() => filteredChannels = data);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }

  IconData _icon(String c) {
    switch (c) {
      case 'News': return Icons.article;
      case 'Entertainment': return Icons.live_tv;
      case 'Movies': return Icons.movie;
      case 'Sports': return Icons.sports_cricket;
      case 'Music': return Icons.music_note;
      case 'Kids': return Icons.child_care;
      case 'Devotional': return Icons.self_improvement;
      case 'Knowledge': return Icons.school;
      case 'Regional': return Icons.language;
      default: return Icons.tv;
    }
  }

  Widget _categories() {
    final entries = channelsProvider.categories.entries.toList();
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            autofocus: i == 0,
            focusColor: Colors.white24,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    CategoryChannels(category: e.key, channels: e.value),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_icon(e.key), size: 40),
                const SizedBox(height: 8),
                Text(e.key,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${e.value.length} channels'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _searchResults() {
    return ListView.builder(
      itemCount: filteredChannels.length,
      itemBuilder: (context, i) => ChannelTile(channel: filteredChannels[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            onChanged: filterChannels,
            decoration: const InputDecoration(
              labelText: 'Search',
              hintText: 'Search channels...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : (_query.isEmpty ? _categories() : _searchResults()),
        ),
      ],
    );
  }
}
