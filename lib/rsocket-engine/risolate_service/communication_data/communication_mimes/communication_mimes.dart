
import 'dart:typed_data';

const String HEADER_POST_ACCOUNTNAME_MIME = "message/post.creator.accountname";
const String HEADER_LAST_STORY_INSTANT = "message/last.story.instant";
const String HEADER_POST_CAPTION_MIME = "message/post.creator.caption";
const String MIME_FILE_EXTENSION = "message/x.upload.file.extension";
const String MIME_FILE_NAME = "message/x.upload.file.name";
const String MIME_STORY_ISMEMORY = "message/story.ismemory";
final Uint8List imageEXT = Uint8List.fromList("jpg".codeUnits);