import 'dart:async';
import 'dart:mirrors';

import 'package:googleapis/compute/v1.dart';
import 'package:uuid/uuid.dart';

import './annotation.dart';
import './base.dart';
import './context.dart';
import './logger.dart';
import './utils/reflection.dart';

enum TaskStatus { Success, Failure }

class TaskRunResult {
  final Config config;

  final TaskStatus status;

  final String log;

  TaskRunResult._internal(this.config, this.status, this.log);
}

Future<TaskRunResult> _runTask(
    Context context, /* Task|ExecuteFunc */ task) async {
  task = task is Task ? task : new Task.fromFunc(task);
  var status = TaskStatus.Success;
  final logger = context.logger;
  try {
    await task.execute(context);
  } on TaskException catch (e) {
    logger.error(e);
    status = TaskStatus.Failure;
  } catch (e) {
    logger.error(e);
    status = TaskStatus.Failure;
  }
  return new TaskRunResult._internal(context.config, status, logger.toString());
}

String taskStatusToString(TaskStatus status) {
  switch (status) {
    case TaskStatus.Success:
      return 'success';
    case TaskStatus.Failure:
      return 'failure';
  }
}

Map<String, ClassMirror> _loadClassMapByAnnotation(ClassMirror annotation) {
  final taskClassMap = {};
  final cms = queryClassesByAnnotation(annotation);
  for (final cm in cms) {
    cm.metadata.forEach((md) {
      InstanceMirror metadata = md as InstanceMirror;
      String name = metadata.getField(#name).reflectee;
      taskClassMap[name] = cm;
    });
  }
  return taskClassMap;
}

void _dumpClassMap(String prefix, Map<String, ClassMirror> taskClassMap) {
  print(prefix);
  taskClassMap.forEach((name, cm) {
    print('  ${name} -> ${cm.qualifiedName}');
  });
}

Future<Map<String, ContextPart>> _createContextPartMap(Config config) async {
  final contextPartClassMap =
      _loadClassMapByAnnotation(reflectClass(ContextPartClass));
  _dumpClassMap('List of ContextPart classes:', contextPartClassMap);

  final partMap = {};
  contextPartClassMap.forEach((String name, ClassMirror contextParClass) {
    partMap[name] = newInstance('', contextParClass, []);
  });
  await Future
      .wait(partMap.values.map((ContextPart part) => part.setUp(config)));
  return partMap;
}

Future<Logger> _createLogger() async {
  // FIXME: Don't hardcode logger
  final logger = new ConsoleLogger();
  return new MemoryLogger(logger);
}

Future<Context> _createGCloudContext(Config config) async {
  final logger = await _createLogger();
  final partMap = await _createContextPartMap(config);
  final context = new GCloudContext(config, logger, partMap);
  await context.setUp();

  return context;
}

enum CreateVMStatus { Success, Error }

class CreateVMResult {
  // Status of CreateVM.
  final CreateVMStatus status;

  // Name of the instance resource.
  final String name;

  // The name of the zone for the instance.
  final String zone;

  CreateVMResult(this.status, this.name, this.zone);
}

Future<CreateVMResult> createVM(GCloudContext context, String zone) async {
  final name = 'beaver-worker-${new Uuid().v4()}';

  final instance = new Instance.fromJson({
    'name': name,
    'machineType':
        'projects/beaver-ci/zones/${zone}/machineTypes/n1-standard-1',
    "disks": [
      {
        "type": "PERSISTENT",
        "boot": true,
        "mode": "READ_WRITE",
        "autoDelete": true,
        "deviceName": name,
        "initializeParams": {
          "sourceImage":
              "https://www.googleapis.com/compute/v1/projects/debian-cloud/global/images/debian-8-jessie-v20160803",
          "diskType": "projects/beaver-ci/zones/${zone}/diskTypes/pd-standard",
          "diskSizeGb": "10"
        }
      }
    ],
    "networkInterfaces": [
      {
        "network": "projects/beaver-ci/global/networks/default",
        "subnetwork":
            "projects/beaver-ci/regions/us-central1/subnetworks/default",
        "accessConfigs": [
          {"name": "External NAT", "type": "ONE_TO_ONE_NAT"}
        ]
      }
    ],
  });
  Operation op =
      await context.compute.instances.insert(instance, 'beaver-ci', zone);
  CreateVMStatus status =
      op.error == null ? CreateVMStatus.Success : CreateVMStatus.Error;
  return new CreateVMResult(status, name, zone);
}

enum DeleteVMStatus { Success, Error }

class DeleteVMResult {
  // Status of DeleteVM.
  final DeleteVMStatus status;

  DeleteVMResult(this.status);
}

Future<DeleteVMResult> deleteVM(GCloudContext context, String name, String zone) async {
  Operation op =
      await context.compute.instances.delete('beaver-ci', zone, name);
  DeleteVMStatus status =
      op.error == null ? DeleteVMStatus.Success : DeleteVMStatus.Error;
  return new DeleteVMResult(status);
}

Future<TaskRunResult> runBeaver(
    String taskName, List<String> taskArgs, Config config,
    {bool newVM: false}) async {
  final taskClassMap = _loadClassMapByAnnotation(reflectClass(TaskClass));
  _dumpClassMap('List of Task classes:', taskClassMap);

  Context context;
  switch (config['cloud_type']) {
    case 'gcloud':
      context = await _createGCloudContext(config);
      break;
    default:
      throw new AssertionError(); // Unreachable
  }

  if (newVM) {
    const zone = 'us-central1-a';
    CreateVMResult result = await createVM(context, zone);
    // FIXME: Execute the task in the vm and return the result.
    await deleteVM(context, result.name, zone);
    return null;
  } else {
    final task = newInstance('fromArgs', taskClassMap[taskName], [taskArgs]);
    return _runTask(context, task);
  }
}
