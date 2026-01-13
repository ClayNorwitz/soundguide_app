import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soundguide_app/constants/app_colors.dart';
import 'package:soundguide_app/models/event_models.dart';
import 'package:soundguide_app/providers/explorer_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.cardBg,
        elevation: 0,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
      ),
      body: Consumer<ExplorerProvider>(
        builder: (context, explorerProvider, _) {
          final unapprovedEvents = explorerProvider.unapprovedEvents;
          return ListView.builder(
            itemCount: unapprovedEvents.length,
            itemBuilder: (context, index) {
              final event = unapprovedEvents[index];
              return _buildEventCard(event, explorerProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildEventCard(Event event, ExplorerProvider explorerProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${event.dateTime.day}/${event.dateTime.month}/${event.dateTime.year}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.accent, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  event.venue.name,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              explorerProvider.approveEvent(event.id);
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }
}
