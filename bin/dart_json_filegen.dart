import 'package:dart_json_filegen/dart_json_filegen.dart';

/// The main entry point of the command-line application.
///
/// This function is responsible for processing command-line arguments
/// and invoking the file generation logic.
void main(List<String> arguments) async {
  // Check if the user provided the required arguments (path, file name, class name, folder, and JSON)
  if (arguments.length < 5) {
    print(
        'Usage: dart create_file.dart <path> <file_name> <class_name> <folder> <json>');
    return;
  }

  // Extract the arguments
  final pathSegment = arguments[0];
  final fileName = arguments[1];
  final className = arguments[2];
  final folder = arguments[3];
  final jsonString = arguments[4];

  // Instantiate and use the FileGenerator class
  final generator = FileGenerator();
  await generator.createFile(
    pathSegment: pathSegment,
    fileName: fileName,
    className: className,
    folder: folder,
    jsonString: jsonString,
  );
}
