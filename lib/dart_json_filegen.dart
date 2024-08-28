import 'dart:convert';
import 'dart:io';


/// Export the file generator class for use in other parts of the package.
export 'dart_json_filegen.dart';

/// A utility class that generates Dart files from JSON input.
///
/// The [FileGenerator] class provides methods to create a Dart file with
/// JSON serializable classes based on the provided JSON structure.
class FileGenerator {
  /// Creates a Dart file at the specified location with the given class name and JSON structure.
  ///
  /// - [pathSegment]: The path segment where the file will be created (e.g., "users").
  /// - [fileName]: The name of the file to create (without extension).
  /// - [className]: The name of the Dart class to generate.
  /// - [folder]: The folder within the path segment where the file will be placed.
  /// - [jsonString]: The JSON string that defines the fields and their types.
  Future<void> createFile({
    required String pathSegment,
    required String fileName,
    required String className,
    required String folder,
    required String jsonString,
  }) async {
    // Parse the JSON to extract field definitions
    Map<String, dynamic> fields;
    try {
      fields = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Invalid JSON format: $e');
      return;
    }

    // Construct the full directory path where the file will be created
    final directoryPath = 'lib/features/$pathSegment/data/$folder';
    // Construct the full file path with the .dart extension
    final filePath = '$directoryPath/$fileName.dart';

    // Generate field definitions based on the JSON structure
    final fieldDefinitions = fields.entries.map((entry) {
      final type = _mapJsonTypeToDartType(entry.value);
      final camelCaseKey = _toCamelCase(entry.key);
      final jsonKey = '@JsonKey(name: \'${entry.key}\')';
      return '''
  $jsonKey
  $type $camelCaseKey;
      ''';
    }).join('\n\n');

    // Generate constructor parameters based on the JSON structure
    final constructorParameters = fields.entries.map((entry) {
      final camelCaseKey = _toCamelCase(entry.key);
      return 'required this.$camelCaseKey';
    }).join(',\n    ');

    // Define the content of the Dart file
    final content = '''
import 'package:json_annotation/json_annotation.dart';

part '${fileName}.g.dart'; // This line is needed for build_runner to generate the .g.dart file

@JsonSerializable()
class $className {
  // Fields
  $fieldDefinitions

  // Constructor
  $className({
    $constructorParameters
  });

  // Factory methods
  factory $className.fromJson(Map<String, dynamic> json) => _\$${className}FromJson(json);
  
  Map<String, dynamic> toJson() => _\$${className}ToJson(this);
}
''';

    // ANSI escape codes for colored text
    const String green = '\x1B[32m';
    const String resetColor = '\x1B[0m';
    const String red = '\x1B[31m';

    try {
      // Ensure the directory exists
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Create the file with the specified content
      final file = File(filePath);
      await file.writeAsString(content);

      // Print a success message in green
      print(
          '${green}File "$fileName.dart" created successfully at "$filePath" with content:${resetColor}');

      // Run build_runner to generate the .g.dart file
      await _runBuildRunner();
    } catch (e) {
      // Print an error message in red if an exception occurs
      print('${red}An error occurred: $e${resetColor}');
    }
  }

  /// Maps JSON types to corresponding Dart types.
  ///
  /// - [value]: A value from the JSON structure to determine its type.
  /// - Returns: A string representing the Dart type.
  String _mapJsonTypeToDartType(dynamic value) {
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is bool) return 'bool';
    if (value is String) return 'String';
    if (value is List) return 'List<dynamic>'; // or specify more precisely if you know the type
    if (value is Map) return 'Map<String, dynamic>'; // For nested objects
    return 'dynamic'; // Default case if the type is not recognized
  }

  /// Converts snake_case to camelCase.
  ///
  /// - [key]: A string in snake_case format.
  /// - Returns: A string converted to camelCase format.
  String _toCamelCase(String key) {
    final parts = key.split('_');
    final camelCase = parts[0] +
        parts
            .skip(1)
            .map((part) => part[0].toUpperCase() + part.substring(1))
            .join('');
    return camelCase;
  }

  /// Runs the build_runner tool to generate the .g.dart file for JSON serialization.
  ///
  /// This method runs the `build_runner` command, which is necessary to generate
  /// the part file containing the `fromJson` and `toJson` methods.
  Future<void> _runBuildRunner() async {
    // ANSI escape codes for colored text
    const String green = '\x1B[32m';
    const String resetColor = '\x1B[0m';
    const String red = '\x1B[31m';

    print('${resetColor}Running build_runner to generate .g.dart file...');
    final result = await Process.run(
      'dart',
      ['run', 'build_runner', 'build'],
      workingDirectory: Directory.current.path,
    );

    if (result.exitCode == 0) {
      print('${green}build_runner completed successfully.${resetColor}');
    } else {
      print('${red}build_runner failed with exit code ${result.exitCode}');
      print(result.stderr);
    }
  }
}

