import 'package:sprintf/sprintf.dart';

import './base.dart';

final Map<int, String> status = {
  0 /* SUCCESS */ : 'success',

  // 100 ~ 199:

  // 200 ~ 299: Trigger related

  // 300 ~ 399: Project related
  300 /* PROJECT_NOT_FOUND */ : 'No project for \'%s\'.',

  // 400 ~ 499: Config related
  400 /* CONFIG_NOT_FOUND */ : 'No Trigger Configuration for \'%s\'',
  401 /* URL_NOT_MATCH */ : 'Url is not matched.',
  402 /* EVENT_NOT_MATCH */ : 'Event is not matched.',

  // 500 ~ 599: Task related
  500 /* CANNOT_CONVERT_TO_JSON */ : 'Task cannot be converted to json.: %s',

  // 600 ~ 699: runBeaver related
  600 /* TASK_CANNOT_BE_RUN */ : 'Task cannot be run.: %s',

  999: 'Unknown Error: %s'
};

void setStatus(Context context, int statusCode, {List<dynamic> value}) {
  var message = status[statusCode];
  if (value != null) {
    message = sprintf(message, value);
  }
  context.status = statusCode.toString() + ': ' + message;
}
