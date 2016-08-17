import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:pub_wrapper/pub_wrapper.dart';
import 'package:yaml/yaml.dart';

import 'base.dart';

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

    final jobMap =
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
        jobMap,
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

  Future<Object> run() async {
    // FIXME: Get a log.
    final workingDir = path.dirname(_jobDescription.customJobFile.toFilePath());
    await runPub(['get'], processWorkingDir: workingDir);

    var result = await Process.run('dart', ['beaver.dart', '${_event}'],
        workingDirectory: workingDir, runInShell: true);

    return new JobRunResult(result.stdout, result.stderr, result.exitCode);
  }
}

class JobRunResult {
  final String stdout;
  final String stderr;
  final int exitCode;

  JobRunResult(this.stdout, this.stderr, this.exitCode);

  @override
  String toString() {
    final buff = new StringBuffer();
    buff.write('stdout: ' + stdout);
    buff.write(', ');
    buff.write('stderr: ' + stderr);
    buff.write(', ');
    buff.write('exitcode: ${exitCode}');
    return buff.toString();
  }
}
