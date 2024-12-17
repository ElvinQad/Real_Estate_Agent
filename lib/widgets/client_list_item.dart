import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/client.dart';

class ClientListItem extends StatelessWidget {
  final Client client;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ClientListItem({
    Key? key,
    required this.client,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  String _formatCurrency(double? value) {
    if (value == null) return '';
    return NumberFormat.currency(symbol: '\$').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 0,
        color: isDark ? theme.cardColor : theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
          ),
        ),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Text(
              client.name[0].toUpperCase(),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            client.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            client.email,
            style: theme.textTheme.bodyMedium,
          ),
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surface
                    : theme.colorScheme.surface.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoTile(
                      icon: Icons.phone,
                      title: 'Phone',
                      value: client.phone,
                    ),
                    _buildInfoTile(
                      icon: Icons.attach_money,
                      title: 'Budget',
                      value:
                          '${_formatCurrency(client.budgetMin)} - ${_formatCurrency(client.budgetMax)}',
                    ),
                    if (client.preferredLocations?.isNotEmpty ?? false)
                      _buildInfoTile(
                        icon: Icons.location_on,
                        title: 'Locations',
                        value: client.preferredLocations!.join(', '),
                      ),
                    if (client.desiredMoveInDate != null)
                      _buildInfoTile(
                        icon: Icons.calendar_today,
                        title: 'Move-in Date',
                        value: DateFormat.yMMMd()
                            .format(client.desiredMoveInDate!),
                      ),
                    if (client.preferredRooms?.isNotEmpty ?? false)
                      _buildInfoTile(
                        icon: Icons.door_front_door,
                        title: 'Preferred Rooms',
                        value: client.preferredRooms!
                            .map((rooms) => '$rooms rooms')
                            .join(', '),
                      ),
                    if (client.propertyTypes?.isNotEmpty ?? false)
                      _buildInfoTile(
                        icon: Icons.house,
                        title: 'Property Types',
                        value: client.propertyTypes!.join(', '),
                      ),
                    if (client.preferredStyle != null)
                      _buildInfoTile(
                        icon: Icons.style,
                        title: 'Style',
                        value: client.preferredStyle!,
                      ),
                    if (client.minSquareMeters != null)
                      _buildInfoTile(
                        icon: Icons.square_foot,
                        title: 'Minimum Size',
                        value: '${client.minSquareMeters} m²',
                      ),
                    if (client.hasParking ?? false)
                      _buildInfoTile(
                        icon: Icons.local_parking,
                        title: 'Parking',
                        value: 'Required',
                      ),
                    if (client.notes?.isNotEmpty ?? false)
                      _buildInfoTile(
                        icon: Icons.notes,
                        title: 'Notes',
                        value: client.notes!,
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit'),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete'),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    String? value,
  }) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.surface.withOpacity(0.3)
                      : theme.colorScheme.surface.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
