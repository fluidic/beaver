import 'dart:async';
import 'dart:io';

import 'package:beaver_core/beaver_core.dart' as beaver_core;
import 'package:path/path.dart' as path;
import 'package:pub_wrapper/pub_wrapper.dart';
import 'package:yaml/yaml.dart';

import './base.dart';
import './utils/reflection.dart';

const String jobDescriptionKey = 'job';

class JobDescription {
  final YamlList jobs;
  final Uri descriptionFile;
  final Uri customJobFile;
  final Uri packageDescriptionFile;

  JobDescription(this.jobs, this.descriptionFile, this.customJobFile,
      this.packageDescriptionFile);
}

class JobDescriptionLoader {
  final Context _context;
  final TriggerConfig _triggerConfig;

  JobDescriptionLoader(this._context, this._triggerConfig);

  Future<JobDescription> load() async {
    final dest = path.join(Directory.systemTemp.path, _triggerConfig.id);
    await new Directory(dest).create(recursive: true);

    // FIXME: If triggerConfig has a valid token, use it to get JobDescription.
    final jobDescriptionUrl = _getJobDescriptionUrl(_triggerConfig.sourceUrl);
    final httpClient = new HttpClient();
    var request = await httpClient.getUrl(jobDescriptionUrl);
    var response = await request.close();
    final jobDescriptionFile =
        new File(path.join(dest, jobDescriptionUrl.pathSegments.last));
    await response.pipe(jobDescriptionFile.openWrite());

    final jobs =
        loadYaml(await jobDescriptionFile.readAsString())[jobDescriptionKey];

    final customJobUrl = _getCustomJobUrl(_triggerConfig.sourceUrl);
    var customJobFile;
    try {
      request = await httpClient.getUrl(customJobUrl);
      response = await request.close();
      customJobFile = new File(path.join(dest, customJobUrl.pathSegments.last));
      await response.pipe(customJobFile.openWrite());
    } catch (e) {
      // FIXME: logging.
      customJobFile = null;
    }

    final packageDescriptionUrl =
        _getPackageDescriptionUrl(_triggerConfig.sourceUrl);
    request = await httpClient.getUrl(packageDescriptionUrl);
    response = await request.close();
    final packageDescriptionFile =
        new File(path.join(dest, packageDescriptionUrl.pathSegments.last));
    await response.pipe(packageDescriptionFile.openWrite());

    httpClient.close();

    return new JobDescription(
        jobs,
        Uri.parse(jobDescriptionFile.path),
        customJobFile != null ? Uri.parse(customJobFile.path) : null,
        Uri.parse(packageDescriptionFile.path));
  }

  Uri _getJobDescriptionUrl(Uri baseUrl) {
    // FIXME: Don't hardcode.
    return Uri.parse(baseUrl.toString() + '/beaver/beaver.yaml');
  }

  Uri _getCustomJobUrl(Uri baseUrl) {
    // FIXME: Don't hardcode.
    return Uri.parse(baseUrl.toString() + '/beaver/beaver.dart');
  }

  Uri _getPackageDescriptionUrl(Uri baesUrl) {
    // FIXME: Don't hardcode.
    return Uri.parse(baesUrl.toString() + '/../pubspec.yaml');
  }
}

class JobRunner {
  final Context _context;
  final String _event;
  final JobDescription _jobDescription;

  JobRunner(this._context, this._event, this._jobDescription);

  Future<JobRunResult> run() async {
    // FIXME: Get a log.
    final workingDir = path.dirname(_jobDescription.customJobFile.toFilePath());

    final job = _jobDescription.jobs.firstWhere(
        (YamlMap job) => job['event'] == _event,
        orElse: () => null);
    if (job == null) {
      throw new Exception('No job for ${_event} event.');
    }

    await _getDependencies(workingDir);

    var result;
    if (job['custom']) {
      // We assume there is only one task if custom is true.
      result = await _runCustomJob(workingDir, job['tasks'].first['name']);
    } else {
      result = await _runJob(job['tasks'], job['concurrency'] ?? false,
          _jobDescription.descriptionFile.toFilePath());
    }

    return result;
  }

  static Future<Object> _getDependencies(String workingDir) =>
      runPub(['get'], processWorkingDir: workingDir);

  static Future<JobRunResult> _runCustomJob(
      String workingDir, String taskName) async {
    final result = await Process.run('dart', ['beaver.dart', taskName],
        workingDirectory: workingDir, runInShell: true);

    return new JobRunResult.fromProcessResult(result);
  }

  static Future<JobRunResult> _runJob(Iterable<YamlList> tasks,
      bool concurrency, String jobDescriptionPath) async {
    final taskClassMap = loadClassMapByAnnotation(beaver_core.TaskClass);

    final config = new beaver_core.YamlConfig.fromFile(jobDescriptionPath);
    // FIXME: Don't use NoneLogger.
    final logger = new beaver_core.NoneLogger();
    // FIXME: Pass ContextPart.
    final context = new beaver_core.DefaultContext(config, logger, {});

    final List<beaver_core.Task> taskList = tasks.map((task) {
      final args = task['arguments']
          ? (task['arguments'] as YamlList).toList(growable: false)
          : [];
      return newInstance(taskClassMap[task['name']], args);
    });

    beaver_core.Task task;
    if (concurrency) {
      task = beaver_core.par(taskList);
    } else {
      task = beaver_core.seq(taskList);
    }

    var status = JobStatus.success;
    try {
      await task.execute(context);
    } catch (e) {
      logger.error(e);
      status = JobStatus.failure;
    }

    return new JobRunResult(status, logger.toString());
  }
}

enum JobStatus { success, failure }

class JobRunResult {
  JobStatus status;
  String log;

  JobRunResult(this.status, this.log);

  JobRunResult.fromProcessResult(ProcessResult result) {
    status = JobStatus.success;
    if (result.exitCode != 0) {
      status = JobStatus.failure;
    }

    StringBuffer buffer = new StringBuffer();
    buffer
      ..write('stdout: ')
      ..write(result.stdout)
      ..write(', stderr: ')
      ..write(result.stderr);
    log = buffer.toString();
  }
}
