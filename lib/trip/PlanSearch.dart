import 'dart:io';

import 'package:flutter/material.dart';

class PlanSearchResults extends StatelessWidget {
  final List<Plan> searchResults;

  PlanSearchResults(this.searchResults);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final plan = searchResults[index];
        return InkWell(
            onTap: () {
              Navigator.of(context).pushNamed("path");
            },
            child: ListTile(
              title: Text(plan.title),
              subtitle: Text(plan.description),
            ));
      },
    );
  }
}

class Plan {
  String title;
  String description;
  String id; 
  String? image;

  Plan({
    required this.title,
    required this.description,
    required this.id,
    this.image,
  });
}

class PlanSearch extends SearchDelegate<String> {
  final List<Plan> plans;

  PlanSearch(this.plans);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, query);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = plans.where((plan) {
      return plan.title.contains(query) || plan.description.contains(query);
    }).toList();

    return PlanSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = plans
        .where((plan) => plan.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestionList[index].title),
          onTap: () {
            query = suggestionList[index].title;
            showResults(context);
          },
        );
      },
    );
  }
}

class PlanDetailScreen extends StatelessWidget {
  final Plan plan;

  PlanDetailScreen(this.plan);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plan.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Title: ${plan.title}'),
          Text('description: ${plan.description}'),
        ],
      ),
    );
  }
}
