import 'package:dart_json_filegen/dart_json_filegen.dart';

/// The main entry point of the command-line application.
///
/// This function is responsible for processing command-line arguments
/// and invoking the file generation logic.
void main(List<String> arguments) async {
  // Check if the user provided the required arguments (path, file name, class name, folder, and JSON)
  if (arguments.length < 6) {
    print(
        'Usage: dart create_file.dart <app> <path> <file_name> <class_name> <folder> <json>');
    return;
  }

  // Extract the arguments
  final app = arguments[0];
  final pathSegment = arguments[1];
  final fileName = arguments[2];
  final className = arguments[3];
  final folder = arguments[4];
  final jsonString = arguments[5];

  // Instantiate and use the FileGenerator class
  final generator = FileGenerator();
  await generator.createFile(
    app: app,
    pathSegment: pathSegment,
    fileName: fileName,
    className: className,
    folder: folder,
    jsonString: jsonString,
  );
}
