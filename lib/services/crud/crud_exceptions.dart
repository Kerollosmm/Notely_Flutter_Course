// lib/services/crud/crud_exceptions.dart

// General Database Exceptions
class DatabaseIsNotOpen implements Exception {}

class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentsDirectory implements Exception {}

// User-related Exceptions
class CouldNotFindUser implements Exception {}

class CouldNotDeleteUser implements Exception {}

class UserAlreadyExists implements Exception {}

// Note-related Exceptions
class CouldNotFindNote implements Exception {}

class CouldNotUpdateNote implements Exception {}

class CouldNotDeleteNote implements Exception {}
