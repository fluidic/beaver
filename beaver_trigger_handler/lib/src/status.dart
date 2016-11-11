final Map<int, String> status = {
  0 /* SUCCESS */: 'success',

  // 100 ~ 199:

  // 200 ~ 299: Trigger related

  // 300 ~ 399: Project related
  300 /* PROJECT_NOT_FOUND */: 'No project for \'%s\'.',

  // 400 ~ 499: Config related
  400 /* CONFIG_NOT_FOUND */: 'No Trigger Configuration for \'%s\'',
  401 /* URL_NOT_MATCH */: 'Url is not matched.',
  402 /* EVENT_NOT_MATCH */: 'Event is not matched.',

  // 500 ~ 599: Task related

  // 600 ~ 699: runBeaver related

  999: 'Unknown Error: %s'
};
