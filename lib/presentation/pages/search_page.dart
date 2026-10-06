import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../widgets/schedule_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    Provider.of<ScheduleProvider>(context, listen: false).search(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search subjects, professors...',
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
          autofocus: true,
        ),
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, child) {
          if (_searchController.text.isEmpty) {
            return const Center(child: Text('Type to search'));
          }

          if (provider.searchResults.isEmpty) {
            return const Center(child: Text('No results found.'));
          }

          return ListView.builder(
            itemCount: provider.searchResults.length,
            itemBuilder: (context, index) {
              return ScheduleCard(schedule: provider.searchResults[index]);
            },
          );
        },
      ),
    );
  }
}
