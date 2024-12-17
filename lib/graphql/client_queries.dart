class ClientQueries {
  static const String _clientFields = '''
    id
    name
    email
    phone
    budgetMin
    budgetMax
    preferredLocations
    preferredRooms
    propertyTypes
    minSquareMeters
    preferredStyle
    hasParking
    notes
    desiredMoveInDate
    amenities
  ''';

  static const String getAllClients = '''
    query GetAllClients {
      clients {
        $_clientFields
      }
    }
  ''';

  static const String createClient = '''
    mutation CreateClient(\$input: CreateClientInput!) {
      createClient(input: \$input) {
        $_clientFields
      }
    }
  ''';

  static const String updateClient = '''
    mutation UpdateClient(\$id: ID!, \$input: UpdateClientInput!) {
      updateClient(id: \$id, input: \$input) {
        $_clientFields
      }
    }
  ''';

  static String deleteClient = r'''
    mutation DeleteClient($id: ID!) {
      deleteClient(id: $id)
    }
  ''';
}
