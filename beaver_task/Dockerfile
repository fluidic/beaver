FROM google/dart

WORKDIR /app

ADD beaver_dart_task /beaver_dart_task
ADD beaver_gcloud_task /beaver_gcloud_task
ADD file_helper /file_helper
ADD pub_wrapper /pub_wrapper

ADD beaver_task/pubspec.* /app/
RUN pub get

ADD beaver_task /app
RUN pub get --offline

CMD []
ENTRYPOINT ["/usr/bin/dart", "bin/beaver_task_server.dart"]

EXPOSE 8080

