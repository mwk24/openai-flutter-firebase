# Flutter app that talks to OpenAI.


[See demo here](http://aihelper.app) (message me for access)

<img src="https://i.imgur.com/yNGDEyy.png" width="50%">


Three parts to this:
1. Firebase Cloud Firestore database
2. Firebase Cloud Function that calls OpenAI (/firebase/functions)
3. Simple Flutter app (/flutter-app)

<br />
Important: This doesn't include auth, so don't make it public without being approved.

<br />

### Setup process: (for flutter web app)

1. Create a firebase project with Cloud Firestore, Cloud Functions (and Hosting if you want to host the web app on firebase)
2. Create Firestore database with structure:
    - conversations
    - settings/openai_config (populate document with values for: preamble, first_question)
3. Add your OpenAI API key to firebase/functions/index.js
4. Deploy cloud functions ("flutter deploy --only functions" from within firebase directory)
5. Build flutter app (flutter build web). Can also build for iOS and Android
6. Host web app [Guide](https://flutter.dev/docs/deployment/web)

<br/>
To host on firebase:

6. Move/copy flutter-app/build/web into firebase directory
7. Setup firebase hosting
8. firebase deploy --only hosting
<br />

Note: if you host elsewhere, you will need to use a slightly different setup in the app [Guide](https://firebase.google.com/docs/web/setup)
