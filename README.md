# carbonvoice_audio

Flutter audio plugin

https://pub.dev/packages/carbonvoice_audio

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Publishing a new version

Update CHANGELOG.md with release notes

Update pubspec.yaml with release number

Update /ios/carbonvoice_audio.podspec with release number (also if there were any changes on the external ios library)

Check for warnings before publishing
`flutter pub publish --dry-run`
 
Publish
`flutter pub publish`
