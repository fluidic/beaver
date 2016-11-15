class CloudInfo {
  final String type;
  final String region;
  final String projectName;
  final Uri baseUrl;
  final String siteId;

  CloudInfo._internal(
      this.baseUrl, this.type, this.region, this.projectName, this.siteId);

  factory CloudInfo.fromUrl(Uri requestUrl) {
    // TODO: Support the other cloud platforms.
    var type;
    if (requestUrl.host.contains('cloudfunctions.net')) {
      type = 'gcf';
    } if (requestUrl.host.contains('appspot.com')) {
      type = 'gae';
    }else {
      type = 'local';
    }

    switch (type) {
      case 'gcloud':
        final cloudType = 'gcloud';
        final exp = new RegExp(r'^([^-]+[-][^-]+)[-](.*)\..+\..+$');
        final match = exp.firstMatch(requestUrl.host);
        final region = match.group(1);
        final projectName = match.group(2);
        final url = new Uri(
            scheme: requestUrl.scheme,
            host: requestUrl.host,
            port: requestUrl.port,
            path: requestUrl.pathSegments.first);
        final siteId = requestUrl.pathSegments.first.split('-')[2];
        return new CloudInfo._internal(url, cloudType, region, projectName, siteId);
      case 'gae':
        final cloudType = 'gcloud';
        final projectName = requestUrl.host.split('.')[0];
        final url = new Uri(
            scheme: requestUrl.scheme,
            host: requestUrl.host,
            port: requestUrl.port);
        return new CloudInfo._internal(url, cloudType, 'us-central1', projectName, '');
      case 'local':
        final url = new Uri(
            scheme: requestUrl.scheme,
            host: requestUrl.host,
            port: requestUrl.port);
        // FIXME: Don't hardcode.
        return new CloudInfo._internal(
            url, 'gcloud', 'us-central1', 'beaver-ci', '');
      default:
        throw new Exception('Not supported cloud type.');
    }
  }
}
