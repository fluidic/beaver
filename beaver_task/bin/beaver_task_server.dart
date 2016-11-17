import 'package:beaver_task/beaver_task_server.dart' as server;

// FIXME: We need a way to specify these dependencies programmatically.
/// [PubTask] import.
import 'package:beaver_dart_task/beaver_dart_task.dart';
/// [DockerTask] import
import 'package:beaver_docker_task/beaver_docker_task.dart';
/// [GCloudStorageUploadTask] import.
import 'package:beaver_gcloud_task/beaver_gcloud_task.dart';

void main() {
  server.serve();
}
