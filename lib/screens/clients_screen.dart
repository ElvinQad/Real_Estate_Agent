import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/client_queries.dart';
import '../widgets/client_list_item.dart';
import '../widgets/client_form_dialog.dart';
import '../models/client.dart';
import '../constants.dart'; // Add this import

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({Key? key}) : super(key: key);

  void _handleCreateClient(BuildContext context, Map<String, dynamic> data) {
    final client = GraphQLProvider.of(context).value;
    client.mutate(
      MutationOptions(
        document: gql(ClientQueries.createClient),
        variables: {'input': data},
        onCompleted: (dynamic resultData) {
          if (resultData != null) {
            client.query(
                QueryOptions(document: gql(ClientQueries.getAllClients)));
            _showSuccessMessage(context, 'Client created successfully');
            Navigator.pop(context);
          }
        },
        onError: (error) => _showErrorMessage(context, error),
      ),
    );
  }

  void _handleUpdateClient(
      BuildContext context, String id, Map<String, dynamic> data) {
    final client = GraphQLProvider.of(context).value;
    client.mutate(
      MutationOptions(
        document: gql(ClientQueries.updateClient),
        variables: {'id': id, 'input': data},
        onCompleted: (dynamic resultData) {
          if (resultData != null) {
            client.query(
                QueryOptions(document: gql(ClientQueries.getAllClients)));
            _showSuccessMessage(context, 'Client updated successfully');
            Navigator.pop(context);
          }
        },
        onError: (error) => _showErrorMessage(context, error),
      ),
    );
  }

  void _handleDeleteClient(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Client'),
        content: const Text('Are you sure you want to delete this client?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performDelete(context, id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _performDelete(BuildContext context, String id) {
    final client = GraphQLProvider.of(context).value;
    client.mutate(
      MutationOptions(
        document: gql(ClientQueries.deleteClient),
        variables: {'id': id},
        onCompleted: (dynamic resultData) {
          if (resultData != null && resultData['deleteClient'] == true) {
            client.query(
                QueryOptions(document: gql(ClientQueries.getAllClients)));
            _showSuccessMessage(context, 'Client deleted successfully');
          }
        },
        onError: (error) => _showErrorMessage(context, error),
      ),
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(BuildContext context, dynamic error) {
    String errorMessage = "Unknown error";

    if (error != null) {
      if (error.graphqlErrors != null && error.graphqlErrors.isNotEmpty) {
        errorMessage = error.graphqlErrors.first.message;
      } else if (error.linkException != null) {
        errorMessage = "Network error occurred";
      } else {
        errorMessage = error.toString();
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $errorMessage'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showClientForm(BuildContext context, [Client? client]) {
    showDialog(
      context: context,
      builder: (context) => ClientFormDialog(
        client: client,
        onSave: (data) {
          if (client != null) {
            _handleUpdateClient(context, client.id, data);
          } else {
            _handleCreateClient(context, data);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'Clients',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, Routes.settings),
            color: theme.colorScheme.onBackground,
          ),
        ],
      ),
      body: Query(
        options: QueryOptions(
          document: gql(ClientQueries.getAllClients),
          pollInterval: const Duration(seconds: 10),
        ),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return _buildErrorState(result, refetch);
          }

          if (result.isLoading) {
            return _buildLoadingState();
          }

          final clients =
              Client.parseClientsList(result.data?['clients'] as List?);
          return _buildClientsList(clients);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showClientForm(context),
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Client',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildErrorState(QueryResult result, VoidCallback? refetch) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.error.withOpacity(0.2)
                  : theme.colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading clients',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  result.exception.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: refetch,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Loading clients...',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClientsList(List<Client> clients) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);

        if (clients.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline_rounded,
                  size: 64,
                  color: theme.colorScheme.onBackground.withOpacity(0.4),
                ),
                const SizedBox(height: 24),
                Text(
                  'No clients found',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first client using the button below',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: clients.length,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemBuilder: (context, index) => ClientListItem(
            client: clients[index],
            onEdit: () => _showClientForm(context, clients[index]),
            onDelete: () => _handleDeleteClient(context, clients[index].id),
          ),
        );
      },
    );
  }
}
